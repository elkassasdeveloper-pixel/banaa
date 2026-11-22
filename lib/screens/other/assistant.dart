import 'package:educ_student/core/functions.dart';

class Assistant {
  String id;
  bool isMale;
  int minimumAge;
  String emotion;
  String skinTone;
  String fileName;

  bool isNew;
  bool isEdited;

  Assistant({this.id = '', this.isMale = true, this.minimumAge = 0, this.emotion = '', this.skinTone = '', this.fileName = '', this.isNew = false, this.isEdited = false});

  factory Assistant.fromJson(Map<String, dynamic> json) => Assistant(
    id: Functions.getValue('String', json['id'], caller: 'id', initialValue: ''.toString()),
    isMale: Functions.getValue('bool', json['isMale'], caller: 'isMale', initialValue: true.toString()),
    minimumAge: Functions.getValue('int', json['minimumAge'], caller: 'minimumAge', initialValue: 0.toString()),
    emotion: Functions.getValue('String', json['emotion'], caller: 'emotion', initialValue: ''.toString()),
    skinTone: Functions.getValue('String', json['skinTone'], caller: 'skinTone', initialValue: ''.toString()),
    fileName: Functions.getValue('String', json['fileName'], caller: 'fileName', initialValue: ''.toString()),
    isNew: false,
    isEdited: false,
  );

  Map<String, dynamic> toJson() => {'id': id, 'isMale': isMale, 'minimumAge': minimumAge, 'emotion': emotion, 'skinTone': skinTone, 'fileName': fileName};
}
