class Mission {
  final String id;
  final String title;
  final String description;
  final int xp;
  final String type; // 'daily' | 'weekly'
  const Mission({required this.id, required this.title, required this.description, required this.xp, required this.type});
}

const List<Mission> missions = [
  Mission(id: 'm-cross', title: 'Perform a Cross', description: 'Hybridize two parents in the Breeder Simulator.', xp: 20, type: 'daily'),
  Mission(id: 'm-gene-edit', title: 'Run a Gene Edit', description: 'Complete one gene editing experiment in the Gene Function Lab.', xp: 20, type: 'daily'),
  Mission(id: 'm-viva', title: 'Answer 3 Viva Questions', description: 'Complete three questions in the AI Viva Examiner.', xp: 25, type: 'daily'),
  Mission(id: 'm-release', title: 'Release a Variety', description: 'Take a breeding program all the way to variety release.', xp: 60, type: 'weekly'),
  Mission(id: 'm-case', title: 'Solve a Detective Case', description: 'Correctly resolve one Gene Detective mystery case.', xp: 45, type: 'weekly'),
  Mission(id: 'm-analysis', title: 'Run a Statistical Analysis', description: 'Complete a heritability or ANOVA analysis in the Virtual Research Lab.', xp: 40, type: 'weekly'),
];
