class Book {
  final String title;
  final String author;
  final String genre;
  final String? review;
  final double? rating;

  const Book({
    required this.title,
    required this.author,
    required this.genre,
    this.review,
    this.rating,
  });

  Book copyWith({
    String? title,
    String? author,
    String? genre,
    String? review,
    double? rating,
  }) {
    return Book(
      title: title ?? this.title,
      author: author ?? this.author,
      genre: genre ?? this.genre,
      review: review ?? this.review,
      rating: rating ?? this.rating,
    );
  }
}