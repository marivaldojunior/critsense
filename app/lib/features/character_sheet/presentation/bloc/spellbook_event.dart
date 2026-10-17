part of 'spellbook_bloc.dart';

sealed class SpellbookEvent {
  const SpellbookEvent();
}

/// Carrega o grimório do personagem [characterId].
final class LoadSpellbookEvent extends SpellbookEvent {
  final String characterId;

  const LoadSpellbookEvent(this.characterId);
}

/// Marca ou desmarca [spell] como preparada.
final class TogglePreparedEvent extends SpellbookEvent {
  final CharacterSpell spell;

  const TogglePreparedEvent(this.spell);
}

/// Remove [spell] do grimório.
final class DeleteSpellEvent extends SpellbookEvent {
  final CharacterSpell spell;

  const DeleteSpellEvent(this.spell);
}
