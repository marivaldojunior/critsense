import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import 'package:crit_sense/core/presentation/widgets/dnd_icon.dart';
import 'package:crit_sense/core/presentation/widgets/skeleton_bones.dart';
import 'package:crit_sense/di/injection_container.dart';
import 'package:crit_sense/features/compendium/domain/entities/api_reference.dart';

import '../../domain/entities/alignment.dart' as dnd;
import '../../domain/entities/character.dart';
import '../bloc/character_bloc.dart';
import '../bloc/form_options_bloc.dart';
import '../bloc/point_buy_cubit.dart';
import '../widgets/point_buy_section.dart';

/// Tela de criação de um novo personagem via formulário.
///
/// Envolve o formulário em um [BlocProvider] de [FormOptionsBloc] para carregar
/// as listas de raças e classes da API em paralelo assim que a tela é montada.
/// Usa [StatefulWidget] porque precisa manter [TextEditingController]s
/// ativos enquanto o widget existir na árvore.
class CharacterFormScreen extends StatefulWidget {
  const CharacterFormScreen({super.key});

  @override
  State<CharacterFormScreen> createState() => _CharacterFormScreenState();
}

class _CharacterFormScreenState extends State<CharacterFormScreen> {
  // GlobalKey<FormState> cumpre o mesmo papel que ModelState em APIs .NET:
  // é o identificador que permite acionar a validação de todos os campos do
  // Form de uma vez (formKey.currentState!.validate() ≈ ModelState.IsValid).
  // Sem ele, cada TextFormField seria validado de forma independente e seria
  // impossível coordenar um único ponto de disparo de salvamento.
  final _formKey = GlobalKey<FormState>();

  // Controllers mantidos como campos da State para que possam ser
  // inicializados uma vez no ciclo de vida e descartados em dispose().
  // TextEditingController aloca recursos nativos (listeners, streams internos):
  // sem dispose(), esses recursos continuam vivos mesmo após o widget ser
  // removido da árvore — causando memory leaks e callbacks em objetos mortos.
  late final TextEditingController _nameCtrl;
  late final TextEditingController _levelCtrl;
  late final TextEditingController _backgroundCtrl;

  /// Valor selecionado no dropdown de raça; corresponde a [ApiReference.name].
  String? _selectedRace;

  /// Valor selecionado no dropdown de classe; corresponde a [ApiReference.name].
  String? _selectedClass;

  /// Valor selecionado no dropdown de tendência; corresponde a [Alignment.label].
  String? _selectedAlignment;

  /// Arquivo de avatar escolhido pelo usuário; nulo enquanto nenhum for selecionado.
  File? _avatarImage;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController();
    _levelCtrl = TextEditingController();
    _backgroundCtrl = TextEditingController();
  }

  @override
  void dispose() {
    // Libera os recursos nativos de cada controller na ordem inversa de criação.
    _nameCtrl.dispose();
    _levelCtrl.dispose();
    _backgroundCtrl.dispose();
    super.dispose();
  }

  /// Abre a [source] (câmera ou galeria) e persiste a imagem escolhida.
  ///
  /// O [ImagePicker] retorna um arquivo temporário no cache do sistema —
  /// similar a um upload recebido em `IFormFile` no ASP.NET Core, cujo
  /// conteúdo existe apenas durante a requisição. Mover o arquivo para
  /// `getApplicationDocumentsDirectory()` equivale a salvá-lo em
  /// `wwwroot/uploads` no servidor: garante persistência entre sessões,
  /// pois o sistema operacional pode limpar o cache a qualquer momento.
  Future<void> _pickImage(ImageSource source) async {
    final picked = await ImagePicker().pickImage(source: source);
    if (picked == null) return;

    final docsDir = await getApplicationDocumentsDirectory();
    final ext = p.extension(picked.path);
    final fileName = 'avatar_${DateTime.now().millisecondsSinceEpoch}$ext';
    final destPath = p.join(docsDir.path, fileName);

    final saved = await File(picked.path).copy(destPath);
    setState(() => _avatarImage = saved);
  }

  /// Recebe [context] explicitamente em vez de usar `this.context`: o
  /// `context` do próprio [State] é ancestral do [MultiBlocProvider] criado
  /// em [build] (é o `context` recebido por `build`, pai da árvore que ele
  /// retorna), então `context.read<PointBuyCubit>()` com `this.context`
  /// nunca o encontra — `PointBuyCubit` é provido *dentro* dessa árvore,
  /// não acima dela. O `context` do `BlocBuilder` abaixo já é descendente
  /// dos providers, por isso é repassado até aqui.
  void _submit(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;

    final level = int.parse(_levelCtrl.text);
    final attributes = context.read<PointBuyCubit>().state.attributes;
    // HP máximo calculado pela fórmula base: 10 + (Constituição × Nível).
    final maxHp = 10 + attributes.constitution * level;
    // Bônus de proficiência pela progressão padrão do SRD do D&D 5e: +2 do
    // nível 1 ao 4, subindo +1 a cada 4 níveis (5, 9, 13, 17).
    final proficiencyBonus = 2 + (level - 1) ~/ 4;

    final character = Character(
      id: const Uuid().v4(),
      name: _nameCtrl.text.trim(),
      race: _selectedRace!,
      characterClass: _selectedClass!,
      level: level,
      // CA, iniciativa e deslocamento ainda não têm campo próprio no
      // formulário — nascem com os valores-base do SRD (CA 10 sem
      // armadura, iniciativa neutra, 30 pés de deslocamento) e ficam
      // editáveis quando a tela de ficha ganhar esses campos.
      armorClass: 10,
      initiative: 0,
      speed: 30,
      maxHitPoints: maxHp,
      currentHitPoints: maxHp,
      temporaryHitPoints: 0,
      attributes: attributes,
      alignment: _selectedAlignment!,
      background: _backgroundCtrl.text.trim(),
      // Traços de personalidade também ainda não têm campo no formulário.
      personalityTraits: '',
      ideals: '',
      bonds: '',
      flaws: '',
      experiencePoints: 0,
      proficiencyBonus: proficiencyBonus,
      avatarPath: _avatarImage?.path,
    );

    // Dispara o evento original do CharacterBloc — sem alterar seu contrato.
    context.read<CharacterBloc>().add(SaveCharacterEvent(character));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<FormOptionsBloc>(
          create: (_) => sl<FormOptionsBloc>()..add(LoadFormOptionsEvent()),
        ),
        BlocProvider<PointBuyCubit>(create: (_) => sl<PointBuyCubit>()),
      ],
      // O `Scaffold` é montado inteiro dentro do `builder` do BlocBuilder —
      // não só o `body` — porque `bottomNavigationBar` também precisa do
      // `context` descendente do `MultiBlocProvider` acima (o mesmo motivo
      // documentado em `_submit`: o `context` recebido por `build()` é
      // ancestral dos providers, não teria acesso a `PointBuyCubit`).
      child: BlocBuilder<FormOptionsBloc, FormOptionsState>(
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(title: const Text('Novo Personagem')),
            body: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _buildBody(state),
            ),
            // CTA principal fixo na base da tela — fora da ListView, para
            // que "Salvar Personagem" fique sempre alcançável na thumb
            // zone, independente do tamanho do formulário. Só existe
            // quando as opções já carregaram; não faz sentido salvar
            // antes disso.
            bottomNavigationBar: state is FormOptionsLoaded
                ? _buildSaveBar(context)
                : null,
          );
        },
      ),
    );
  }

  /// Resolve o corpo da tela a partir de [state] — usado como `child` do
  /// [AnimatedSwitcher] em [build], daí cada branch carregar uma [ValueKey]
  /// distinta: é o que permite ao Flutter detectar a troca de estado e
  /// disparar o fade de 300ms em vez de substituir a árvore sem transição.
  Widget _buildBody(FormOptionsState state) {
    if (state is FormOptionsLoading) {
      return const _CharacterFormSkeleton(key: ValueKey('loading'));
    }

    if (state is FormOptionsError) {
      return Center(
        key: const ValueKey('error'),
        child: Text(
          'Erro ao carregar opções: ${state.message}',
          textAlign: TextAlign.center,
        ),
      );
    }

    return _buildForm(state as FormOptionsLoaded);
  }

  /// Barra fixa com o CTA "Salvar Personagem", com uma sombra sutil voltada
  /// para cima indicando que há conteúdo rolável por baixo dela.
  Widget _buildSaveBar(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.12),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
          child: SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () => _submit(context),
              icon: const Icon(Icons.save_outlined),
              label: const Text('Salvar Personagem'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Exibe o [CircleAvatar] de avatar e abre o seletor de origem ao toque.
  Widget _buildAvatarPicker() {
    return Center(
      child: GestureDetector(
        onTap: () => showModalBottomSheet<void>(
          context: context,
          builder: (ctx) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.camera_alt_outlined),
                  title: const Text('Tirar Foto'),
                  onTap: () {
                    Navigator.pop(ctx);
                    _pickImage(ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library_outlined),
                  title: const Text('Escolher da Galeria'),
                  onTap: () {
                    Navigator.pop(ctx);
                    _pickImage(ImageSource.gallery);
                  },
                ),
              ],
            ),
          ),
        ),
        child: CircleAvatar(
          radius: 50,
          backgroundColor: Colors.grey.shade300,
          backgroundImage: _avatarImage != null
              ? FileImage(_avatarImage!)
              : null,
          child: _avatarImage == null
              ? const Icon(Icons.camera_alt, size: 36, color: Colors.grey)
              : null,
        ),
      ),
    );
  }

  /// Renderiza o formulário completo com os dropdowns populados por [options].
  ///
  /// Não recebe mais `context` — o CTA "Salvar Personagem" (único ponto que
  /// precisava dele, para chamar [_submit]) agora vive em [_buildSaveBar],
  /// fixo fora da [ListView].
  Widget _buildForm(FormOptionsLoaded options) {
    // `key: _formKey` continua sendo o GlobalKey de validação do formulário
    // (usado por `_submit`) — não uma ValueKey de identidade para o
    // AnimatedSwitcher em `_buildBody`. Não é preciso uma ValueKey aqui: o
    // runtimeType de [Form] já difere de [_CharacterFormSkeleton] e do
    // `Center` de erro, o suficiente para o AnimatedSwitcher detectar a
    // troca de estado sem precisar de uma chave extra.
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          _buildAvatarPicker(),
          const SizedBox(height: 20),
          _SectionHeader(title: 'Informações Básicas'),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _nameCtrl,
            label: 'Nome',
            validator: _requiredValidator,
          ),
          _buildDropdown(
            label: 'Raça',
            items: options.races,
            onChanged: (value) => _selectedRace = value,
          ),
          _buildDropdown(
            label: 'Classe',
            items: options.classes,
            onChanged: (value) => _selectedClass = value,
            leadingIconBuilder: _classIconAsset,
          ),
          _buildTextField(
            controller: _levelCtrl,
            label: 'Nível',
            numeric: true,
            validator: _positiveIntValidator,
          ),
          _buildAlignmentDropdown(),
          _buildTextField(
            controller: _backgroundCtrl,
            label: 'Antecedente',
            validator: _requiredValidator,
          ),
          const SizedBox(height: 24),
          _SectionHeader(title: 'Atributos'),
          const SizedBox(height: 4),
          const PointBuySection(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool numeric = false,
    required String? Function(String?) validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        keyboardType: numeric ? TextInputType.number : TextInputType.text,
        inputFormatters: numeric
            ? [FilteringTextInputFormatter.digitsOnly]
            : null,
        validator: validator,
      ),
    );
  }

  /// Constrói um [DropdownButtonFormField] a partir de uma lista de [ApiReference].
  ///
  /// [leadingIconBuilder], quando informado, retorna o caminho do asset SVG
  /// exibido antes do nome de cada item (usado pelo dropdown de Classe).
  Widget _buildDropdown({
    required String label,
    required List<ApiReference> items,
    required ValueChanged<String?> onChanged,
    String? Function(ApiReference)? leadingIconBuilder,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: DropdownButtonFormField<String>(
        initialValue: null,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        items: items
            .map(
              (ref) => DropdownMenuItem<String>(
                value: ref.name,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (leadingIconBuilder?.call(ref) case final iconPath?) ...[
                      DnDIcon(assetPath: iconPath, size: 22),
                      const SizedBox(width: 10),
                    ],
                    Text(ref.name),
                  ],
                ),
              ),
            )
            .toList(),
        onChanged: onChanged,
        validator: (v) =>
            (v == null || v.isEmpty) ? 'Selecione uma opção.' : null,
      ),
    );
  }

  /// Caminho do ícone de classe (`assets/icons/class/`) correspondente ao
  /// nome retornado pela API do compêndio (ex: "Wizard" -> `wizard.svg`).
  ///
  /// Retorna `null` para classes sem ícone dedicado no pacote, caso em que
  /// o dropdown exibe apenas o nome, sem ícone.
  static const _knownClassIcons = {
    'artificer',
    'barbarian',
    'bard',
    'cleric',
    'druid',
    'fighter',
    'monk',
    'paladin',
    'ranger',
    'rogue',
    'sorcerer',
    'warlock',
    'wizard',
  };

  String? _classIconAsset(ApiReference ref) {
    final key = ref.name.toLowerCase();
    if (!_knownClassIcons.contains(key)) return null;
    return 'assets/icons/class/$key.svg';
  }

  /// Dropdown de tendência (alinhamento) a partir das nove opções fixas do
  /// D&D 5e — diferente de [_buildDropdown], não depende da API do compêndio.
  Widget _buildAlignmentDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: DropdownButtonFormField<String>(
        initialValue: null,
        decoration: const InputDecoration(
          labelText: 'Tendência',
          border: OutlineInputBorder(),
        ),
        items: dnd.Alignment.values
            .map(
              (alignment) => DropdownMenuItem<String>(
                value: alignment.label,
                child: Text(alignment.label),
              ),
            )
            .toList(),
        onChanged: (value) => _selectedAlignment = value,
        validator: (v) =>
            (v == null || v.isEmpty) ? 'Selecione uma opção.' : null,
      ),
    );
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) return 'Campo obrigatório.';
    return null;
  }

  String? _positiveIntValidator(String? value) {
    final n = int.tryParse(value ?? '');
    if (n == null || n < 1) return 'Informe um número maior que zero.';
    return null;
  }
}

/// Esqueleto de carregamento exibido enquanto [FormOptionsBloc] busca as
/// listas de raças/classes: imita o layout do formulário — avatar circular,
/// cabeçalho de seção, um retângulo por campo de texto/dropdown e, mais
/// abaixo, uma linha por atributo da seção de Point Buy — para que a troca
/// pelo formulário real (via [AnimatedSwitcher]) não salte de tamanho.
class _CharacterFormSkeleton extends StatelessWidget {
  const _CharacterFormSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SkeletonShimmer(
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        physics: const NeverScrollableScrollPhysics(),
        children: [
          const Center(child: SkeletonBones.circle(size: 100)),
          const SizedBox(height: 20),
          const SkeletonBones.rect(width: 160, height: 16),
          const SizedBox(height: 16),
          // Um retângulo por campo real: Nome, Raça, Classe, Nível,
          // Tendência e Antecedente.
          for (var i = 0; i < 6; i++)
            const Padding(
              padding: EdgeInsets.only(bottom: 14),
              child: SkeletonBones.rect(
                width: double.infinity,
                height: 56,
                borderRadius: 4,
              ),
            ),
          const SizedBox(height: 8),
          const SkeletonBones.rect(width: 100, height: 16),
          const SizedBox(height: 16),
          // Uma linha por atributo de Point Buy (Força, Destreza...).
          for (var i = 0; i < 6; i++)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 4),
              child: SkeletonBones.rect(
                width: double.infinity,
                height: 32,
                borderRadius: 6,
              ),
            ),
        ],
      ),
    );
  }
}

/// Cabeçalho visual de seção do formulário.
class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Divider(),
      ],
    );
  }
}
