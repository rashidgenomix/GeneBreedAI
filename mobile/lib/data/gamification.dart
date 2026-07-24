class CareerRank {
  final String id;
  final String title;
  final int minLevel;
  final String description;
  const CareerRank({required this.id, required this.title, required this.minLevel, required this.description});
}

const List<CareerRank> careerRanks = [
  CareerRank(id: 'student', title: 'Student', minLevel: 1, description: 'Just starting out in the field.'),
  CareerRank(id: 'intern', title: 'Intern', minLevel: 3, description: 'Assisting with routine breeding tasks.'),
  CareerRank(id: 'assistant-breeder', title: 'Assistant Breeder', minLevel: 6, description: 'Running small breeding programs independently.'),
  CareerRank(id: 'research-associate', title: 'Research Associate', minLevel: 10, description: 'Designing experiments and analyzing data.'),
  CareerRank(id: 'scientist', title: 'Scientist', minLevel: 15, description: 'Leading original breeding and genetics research.'),
  CareerRank(id: 'senior-scientist', title: 'Senior Scientist', minLevel: 21, description: 'Mentoring others and driving strategic programs.'),
  CareerRank(id: 'chief-plant-breeder', title: 'Chief Plant Breeder', minLevel: 28, description: "Directing an institution's entire breeding portfolio."),
];

CareerRank rankForLevel(int level) {
  var current = careerRanks.first;
  for (final rank in careerRanks) {
    if (level >= rank.minLevel) current = rank;
  }
  return current;
}

/// XP required to go from level N to N+1 grows quadratically to keep pacing meaningful.
int xpForLevel(int level) => (80 * level * level + 120 * level).round();

class LevelInfo {
  final int level;
  final int xpIntoLevel;
  final int xpForNext;
  const LevelInfo({required this.level, required this.xpIntoLevel, required this.xpForNext});
}

LevelInfo levelForTotalXp(int totalXp) {
  var level = 1;
  var remaining = totalXp;
  while (remaining >= xpForLevel(level)) {
    remaining -= xpForLevel(level);
    level += 1;
  }
  return LevelInfo(level: level, xpIntoLevel: remaining, xpForNext: xpForLevel(level));
}

class Badge {
  final String id;
  final String name;
  final String description;
  final String icon;
  final String category;
  const Badge({required this.id, required this.name, required this.description, required this.icon, required this.category});
}

const List<Badge> badges = [
  Badge(id: 'first-cross', name: 'First Cross', description: 'Performed your first hybridization.', icon: 'git-branch', category: 'breeding'),
  Badge(id: 'first-release', name: 'Variety Releaser', description: 'Released your first new variety.', icon: 'award', category: 'breeding'),
  Badge(id: 'survivor', name: 'Survivor', description: 'Kept a breeding line alive through a high-severity field event.', icon: 'shield-check', category: 'breeding'),
  Badge(id: 'gene-hunter', name: 'Gene Hunter', description: 'Completed your first gene knockout experiment.', icon: 'dna', category: 'genetics'),
  Badge(id: 'detective', name: 'Gene Detective', description: 'Solved your first mystery mutant case.', icon: 'search', category: 'genetics'),
  Badge(id: 'statistician', name: 'Statistician', description: 'Completed an ANOVA analysis in the Virtual Research Lab.', icon: 'bar-chart', category: 'research'),
  Badge(id: 'polyglot-breeder', name: 'Polyglot Breeder', description: 'Used five different breeding methods.', icon: 'layers', category: 'breeding'),
  Badge(id: 'six-crops', name: 'Crop Explorer', description: 'Ran a breeding program in all six crops.', icon: 'sprout', category: 'breeding'),
  Badge(id: 'game-champion', name: 'Game Champion', description: 'Scored full marks on a genetics game.', icon: 'trophy', category: 'games'),
  Badge(id: 'published', name: 'Published Researcher', description: 'Earned your first in-app publication.', icon: 'book-open', category: 'research'),
];
