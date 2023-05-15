// ignore_for_file: constant_identifier_names

enum RequestActionEnum {
  Action,
  List,
  NewFiche,
  ConfirmationAction,
  DefaultFiche,
  GetRow;

  @override
  String toString() => name.toString();
}
