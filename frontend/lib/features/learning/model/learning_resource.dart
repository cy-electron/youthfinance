class LearningResource {
  final String id;
  final String topic;
  final String title;
  final String description;
  final String youtubeUrl;
  final String thumbnailUrl;
  final String duration;
  final String difficulty;

  const LearningResource({
    required this.id,
    required this.topic,
    required this.title,
    required this.description,
    required this.youtubeUrl,
    required this.thumbnailUrl,
    required this.duration,
    required this.difficulty,
  });
}