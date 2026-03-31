class GameResult {
  const GameResult({
    required this.score,
    required this.survivedSeconds,
    required this.completedEvents,
    required this.title,
    required this.summary,
    required this.isNewHighScore,
    required this.bestScore,
  });

  final int score;
  final int survivedSeconds;
  final int completedEvents;
  final String title;
  final String summary;
  final bool isNewHighScore;
  final int bestScore;
}
