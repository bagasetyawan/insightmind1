class AnswerOption {
  final String label; // contoh: "Tidak Pernah", "Beberapa Hari"
  final int score; // 0..3

  const AnswerOption({required this.label, required this.score});
}

class Question {
  final String id;
  final String text;
  final List<AnswerOption> options;

  const Question({
    required this.id,
    required this.text,
    required this.options,
  });
}

/////////// 🔹 9 pertanyaan reflektif gaya PHQ/DASS versi InsightMind///////////
const defaultQuestions = <Question>[
  Question(
    id: 'q1',
    text:
    'Dalam 2 minggu terakhir, seberapa sering Anda merasa sedih, murung, atau putus asa?',
    options: [
      AnswerOption(label: 'Tidak Pernah', score: 0),
      AnswerOption(label: 'Beberapa Hari', score: 1),
      AnswerOption(label: 'Lebih dari Separuh Hari', score: 2),
      AnswerOption(label: 'Hampir Setiap Hari', score: 3),
    ],
  ),
  Question(
    id: 'q2',
    text: 'Seberapa sering Anda merasa kehilangan minat atau kesenangan dalam melakukan hal-hal yang biasanya disukai?',
    options: [
      AnswerOption(label: 'Tidak Pernah', score: 0),
      AnswerOption(label: 'Beberapa Hari', score: 1),
      AnswerOption(label: 'Lebih dari Separuh Hari', score: 2),
      AnswerOption(label: 'Hampir Setiap Hari', score: 3),
    ],
  ),
  Question(
    id: 'q3',
    text: 'Apakah Anda kesulitan tidur, sulit untuk tertidur, atau justru tidur terlalu lama?',
    options: [
      AnswerOption(label: 'Tidak Pernah', score: 0),
      AnswerOption(label: 'Beberapa Hari', score: 1),
      AnswerOption(label: 'Lebih dari Separuh Hari', score: 2),
      AnswerOption(label: 'Hampir Setiap Hari', score: 3),
    ],
  ),
  Question(
    id: 'q4',
    text: 'Seberapa sering Anda merasa lelah atau kurang energi untuk beraktivitas?',
    options: [
      AnswerOption(label: 'Tidak Pernah', score: 0),
      AnswerOption(label: 'Beberapa Hari', score: 1),
      AnswerOption(label: 'Lebih dari Separuh Hari', score: 2),
      AnswerOption(label: 'Hampir Setiap Hari', score: 3),
    ],
  ),
  Question(
    id: 'q5',
    text: 'Apakah Anda mengalami perubahan nafsu makan — lebih sedikit atau lebih banyak dari biasanya?',
    options: [
      AnswerOption(label: 'Tidak Pernah', score: 0),
      AnswerOption(label: 'Beberapa Hari', score: 1),
      AnswerOption(label: 'Lebih dari Separuh Hari', score: 2),
      AnswerOption(label: 'Hampir Setiap Hari', score: 3),
    ],
  ),
  Question(
    id: 'q6',
    text: 'Seberapa sering Anda merasa kurang percaya diri, merasa gagal, atau menyalahkan diri sendiri?',
    options: [
      AnswerOption(label: 'Tidak Pernah', score: 0),
      AnswerOption(label: 'Beberapa Hari', score: 1),
      AnswerOption(label: 'Lebih dari Separuh Hari', score: 2),
      AnswerOption(label: 'Hampir Setiap Hari', score: 3),
    ],
  ),
  Question(
    id: 'q7',
    text: 'Apakah Anda merasa sulit untuk fokus atau berkonsentrasi pada hal-hal seperti membaca atau bekerja?',
    options: [
      AnswerOption(label: 'Tidak Pernah', score: 0),
      AnswerOption(label: 'Beberapa Hari', score: 1),
      AnswerOption(label: 'Lebih dari Separuh Hari', score: 2),
      AnswerOption(label: 'Hampir Setiap Hari', score: 3),
    ],
  ),
  Question(
    id: 'q8',
    text: 'Apakah Anda merasa cemas, tegang, atau mudah panik tanpa alasan yang jelas?',
    options: [
      AnswerOption(label: 'Tidak Pernah', score: 0),
      AnswerOption(label: 'Beberapa Hari', score: 1),
      AnswerOption(label: 'Lebih dari Separuh Hari', score: 2),
      AnswerOption(label: 'Hampir Setiap Hari', score: 3),
    ],
  ),
  Question(
    id: 'q9',
    text:
    'Dalam 2 minggu terakhir, apakah Anda merasa kesulitan untuk menjalani kegiatan sehari-hari karena suasana hati Anda?',
    options: [
      AnswerOption(label: 'Tidak Pernah', score: 0),
      AnswerOption(label: 'Beberapa Hari', score: 1),
      AnswerOption(label: 'Lebih dari Separuh Hari', score: 2),
      AnswerOption(label: 'Hampir Setiap Hari', score: 3),
    ],
  ),
];
