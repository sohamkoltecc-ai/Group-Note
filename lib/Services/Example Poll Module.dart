class PollModel {
  final String id;
  final String question;
  final List<String> options;
  final List<int> votes;

  PollModel({
    required this.id,
    required this.question,
    required this.options,
    required this.votes,
  });

  Map<String, dynamic> toMap() {
    return {'question': question, 'options': options, 'votes': votes};
  }

  factory PollModel.fromMap(String id, Map<String, dynamic> map) {
    return PollModel(
      id: id,
      question: map['question'],
      options: List<String>.from(map['options']),
      votes: List<int>.from(map['votes']),
    );
  }
}
