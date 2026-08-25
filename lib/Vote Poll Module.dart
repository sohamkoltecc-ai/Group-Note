import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> votePoll(String pollId, int optionIndex, List<int> votes) async {
  votes[optionIndex]++;

  await FirebaseFirestore.instance.collection('polls').doc(pollId).update({
    'votes': votes,
  });
}
