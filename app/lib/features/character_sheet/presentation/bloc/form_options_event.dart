part of 'form_options_bloc.dart';

/// Evento base do [FormOptionsBloc].
abstract class FormOptionsEvent {}

/// Solicita o carregamento simultâneo de classes e raças da API.
class LoadFormOptionsEvent extends FormOptionsEvent {}
