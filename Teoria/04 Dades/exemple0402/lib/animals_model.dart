class AnimalsModel {
  final String especie;
  final int longevitat;
  final int numeropotes;

  AnimalsModel({
    required this.especie,
    required this.longevitat,
    required this.numeropotes,
  });

  Map<String, dynamic> toMap() {
    return {
      'especie': especie,
      'longevitat': longevitat,
      'numeropotes': numeropotes,
    };
  }

  factory AnimalsModel.fromMap(Map<String, dynamic> map) {
    return AnimalsModel(
      especie: map['especie'],
      longevitat: map['longevitat'],
      numeropotes: map['numeropotes'],
    );
  }
}
