class Article {
  final String arxivId;
  final DateTime addedTime;
  final DateTime submittedTime;
  final String title;
  final String abstract;
  final List<String> authors;

  const Article({
    required this.arxivId,
    required this.addedTime,
    required this.submittedTime,
    required this.title,
    required this.abstract,
    required this.authors,
  });

  // Computed property to construct the arXiv link from the arXiv ID
  String get link => 'https://arxiv.org/abs/$arxivId';

  factory Article.fromJson(Map<String, dynamic> json) => Article(
    arxivId: json['arxiv_id'] as String,
    addedTime: DateTime.fromMillisecondsSinceEpoch(json['added_date'] as int),
    submittedTime: DateTime.fromMillisecondsSinceEpoch(
      json['submitted_date'] as int,
    ),
    title: json['title'] as String,
    abstract: json['abstract'] as String,
    authors: List<String>.from(json['authors'] as List),
  );

  Map<String, dynamic> toJson() => {
    'arxiv_id': arxivId,
    'added_time': addedTime.millisecondsSinceEpoch,
    'submitted_time': submittedTime.millisecondsSinceEpoch,
    'title': title,
    'abstract': abstract,
    'authors': authors,
  };
}
