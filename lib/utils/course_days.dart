/// Jours de cours sur une période — même règle que le serveur
/// (`AttendanceController::countExpectedCourseDays`, CDC §8.6, doc/audit.md
/// F6) : chaque jour calendaire de [from] à [to] inclus, compté s'il fait
/// partie des jours de cours du Markaz ([workingDays] : 'mon'…'sun'),
/// lundi-vendredi par défaut si rien n'est configuré.
int countCourseDays(DateTime from, DateTime to, List<String> workingDays) {
  const keys = ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'];
  final days = workingDays.isEmpty
      ? const {'mon', 'tue', 'wed', 'thu', 'fri'}
      : workingDays.toSet();

  var day = DateTime(from.year, from.month, from.day);
  final last = DateTime(to.year, to.month, to.day);
  var count = 0;
  while (!day.isAfter(last)) {
    if (days.contains(keys[day.weekday - 1])) count++;
    day = DateTime(day.year, day.month, day.day + 1);
  }
  return count;
}
