import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:crit_sense/di/injection_container.dart';

import '../../domain/entities/voice_command.dart';
import '../../domain/services/on_device_ai.dart';
import '../cubit/voice_command_cubit.dart';

/// Abre a escuta e devolve o comando que o jogador confirmou, ou `null` se
/// ele cancelou.
Future<VoiceCommand?> showVoiceCommandSheet(
  BuildContext context, {
  required VoiceScope scope,
}) {
  return showModalBottomSheet<VoiceCommand>(
    context: context,
    isScrollControlled: true,
    builder: (_) => BlocProvider<VoiceCommandCubit>(
      create: (_) => sl<VoiceCommandCubit>(param1: scope)..listen(),
      child: const VoiceCommandSheet(),
    ),
  );
}

/// Botão de microfone para a AppBar.
class VoiceCommandButton extends StatelessWidget {
  const VoiceCommandButton({
    super.key,
    required this.onPressed,
    this.tooltip = 'Comando por voz',
  });

  final VoidCallback onPressed;
  final String tooltip;

  @override
  Widget build(BuildContext context) => IconButton(
    tooltip: tooltip,
    icon: const Icon(Icons.mic_none),
    onPressed: onPressed,
  );
}

/// Exemplos de frases para cada lugar.
List<String> voiceExamples(VoiceScope scope) => switch (scope) {
  VoiceScope.character => const [
    '"Levei 8 de dano"',
    '"Curar 5"',
    '"Rolar 2d6 mais 3"',
    '"Descanso curto"',
    '"Concentrar em Bless"',
    '"Anotar o rei mentiu"',
  ],
  VoiceScope.combat => const [
    '"O lobo leva 8 de dano"',
    '"Cura o goblin em 3"',
    '"Próximo turno"',
  ],
  VoiceScope.dictation => const ['Fale a nota. O texto vai para o diário.'],
};

/// Mostra o que o jogador fala e o comando entendido. "Aplicar" fecha a
/// folha e devolve o comando.
class VoiceCommandSheet extends StatefulWidget {
  const VoiceCommandSheet({super.key});

  @override
  State<VoiceCommandSheet> createState() => _VoiceCommandSheetState();
}

class _VoiceCommandSheetState extends State<VoiceCommandSheet> {
  final _typed = TextEditingController();

  @override
  void dispose() {
    _typed.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        child: BlocBuilder<VoiceCommandCubit, VoiceCommandState>(
          builder: (context, state) {
            final cubit = context.read<VoiceCommandCubit>();
            final listening = state.status == VoiceStatus.listening;
            final command = state.command;
            final dictation = cubit.scope == VoiceScope.dictation;

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    dictation ? 'Ditar nota' : 'Comando por voz',
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: IconButton.filled(
                      iconSize: 36,
                      tooltip: listening ? 'Parar de ouvir' : 'Falar',
                      onPressed: listening ? cubit.stop : cubit.listen,
                      icon: Icon(listening ? Icons.mic : Icons.mic_none),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    switch (state.status) {
                      VoiceStatus.listening => 'Ouvindo...',
                      VoiceStatus.interpreting => 'Entendendo...',
                      _ => 'Toque no microfone para falar.',
                    },
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall,
                  ),
                  if (state.transcript.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      '"${state.transcript}"',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                  if (state.status == VoiceStatus.interpreting)
                    const Padding(
                      padding: EdgeInsets.only(top: 12),
                      child: LinearProgressIndicator(),
                    ),
                  if (command != null) ...[
                    const SizedBox(height: 16),
                    Card(
                      color: theme.colorScheme.primaryContainer,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          command.description,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.titleMedium,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: cubit.listen,
                            child: const Text('Falar de novo'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton(
                            onPressed: () => Navigator.pop(context, command),
                            child: const Text('Aplicar'),
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (state.message != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      state.message!,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.error,
                      ),
                    ),
                  ],
                  if (command == null) _AiStatusLine(state: state),
                  if (command == null) ...[
                    const SizedBox(height: 16),
                    Text('Exemplos', style: theme.textTheme.labelLarge),
                    const SizedBox(height: 4),
                    Text(
                      voiceExamples(cubit.scope).join('\n'),
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                  const SizedBox(height: 16),
                  TextField(
                    controller: _typed,
                    textInputAction: TextInputAction.send,
                    decoration: InputDecoration(
                      labelText: dictation
                          ? 'Ou digite a nota'
                          : 'Ou digite o comando',
                      suffixIcon: IconButton(
                        tooltip: 'Enviar',
                        icon: const Icon(Icons.send),
                        onPressed: () => cubit.submit(_typed.text),
                      ),
                    ),
                    onSubmitted: cubit.submit,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Mostra o estado da IA do aparelho e o botão para baixar o modelo.
class _AiStatusLine extends StatelessWidget {
  const _AiStatusLine({required this.state});

  final VoiceCommandState state;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return switch (state.aiStatus) {
      OnDeviceAiStatus.available => Padding(
        padding: const EdgeInsets.only(top: 12),
        child: Text(
          'IA do aparelho ativa para frases livres.',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodySmall,
        ),
      ),
      OnDeviceAiStatus.downloadable => Padding(
        padding: const EdgeInsets.only(top: 12),
        child: TextButton.icon(
          onPressed: context.read<VoiceCommandCubit>().downloadAi,
          icon: const Icon(Icons.download),
          label: const Text('Baixar a IA do aparelho (Gemini Nano)'),
        ),
      ),
      OnDeviceAiStatus.downloading => const Padding(
        padding: EdgeInsets.only(top: 12),
        child: Column(
          children: [
            Text('Baixando a IA do aparelho...'),
            SizedBox(height: 4),
            LinearProgressIndicator(),
          ],
        ),
      ),
      OnDeviceAiStatus.unavailable || null => const SizedBox.shrink(),
    };
  }
}
