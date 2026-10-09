import '../models/class_model.dart';
import '../models/student.dart';

/// Filtre de groupe "tous les élèves".
const String studentFilterAllGroups = '__all__';

/// Filtre de groupe "élèves sans groupe".
const String studentFilterNoGroup = '__none__';

/// Recherche et filtrage des élèves (CDC §8.3 : "recherche, filtrage").
///
/// - [query] : correspond au nom (sans tenir compte des majuscules ni des
///   accents) ou au numéro de téléphone (chiffres seuls, espaces ignorés) ;
/// - [groupFilter] : [studentFilterAllGroups], [studentFilterNoGroup] ou
///   l'identifiant d'un groupe ([classes] donne leur composition).
List<Student> filterStudents(
  List<Student> students, {
  String query = '',
  String groupFilter = studentFilterAllGroups,
  List<ClassModel> classes = const [],
}) {
  final text = _normalize(query.trim());
  final digits = query.replaceAll(RegExp(r'\D'), '');

  Set<String>? allowed;
  if (groupFilter == studentFilterNoGroup) {
    final grouped = classes.expand((c) => c.studentIds).toSet();
    allowed = students.map((s) => s.id).where((id) => !grouped.contains(id)).toSet();
  } else if (groupFilter != studentFilterAllGroups) {
    allowed = classes
            .where((c) => c.id == groupFilter)
            .firstOrNull
            ?.studentIds
            .toSet() ??
        <String>{};
  }

  return students.where((student) {
    if (allowed != null && !allowed.contains(student.id)) return false;
    if (text.isEmpty) return true;
    if (_normalize(student.name).contains(text)) return true;
    return digits.isNotEmpty &&
        student.parentPhone.replaceAll(RegExp(r'\D'), '').contains(digits);
  }).toList();
}

String _normalize(String value) {
  const from = 'àâäáãéèêëíìîïóòôöõúùûüçñÀÂÄÁÃÉÈÊËÍÌÎÏÓÒÔÖÕÚÙÛÜÇÑ';
  const to = 'aaaaaeeeeiiiiooooouuuucnAAAAAEEEEIIIIOOOOOUUUUCN';
  final buffer = StringBuffer();
  for (final rune in value.runes) {
    final char = String.fromCharCode(rune);
    final index = from.indexOf(char);
    buffer.write(index >= 0 ? to[index] : char);
  }
  return buffer.toString().toLowerCase();
}
