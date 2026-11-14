/// GetUserInfo 返回的个人资料。
class UserProfile {
  const UserProfile({
    this.id,
    this.pictrue = '',
    this.userName = '',
    this.number = '',
    this.name = '',
    this.surname = '',
    this.gender,
    this.enterSchoolYearGradeId,
    this.classId,
    this.enterSchoolYear = '',
    this.gradeName = '',
    this.className = '',
    this.credentialsType,
    this.idNumber = '',
    this.brithDay,
    this.birthplace = '',
    this.nation = '',
    this.homeAddress = '',
    this.mobile,
    this.telephone = '',
    this.schoolRollState,
    this.state,
  });

  final int? id;
  final String pictrue;
  final String userName;
  final String number;
  final String name;
  final String surname;
  final int? gender;
  final int? enterSchoolYearGradeId;
  final int? classId;
  final String enterSchoolYear;
  final String gradeName;
  final String className;
  final int? credentialsType;
  final String idNumber;
  final String? brithDay;
  final String birthplace;
  final String nation;
  final String homeAddress;
  final String? mobile;
  final String telephone;
  final int? schoolRollState;
  final int? state;

  String get fullName => '$surname$name'.trim();

  UserProfile copyWith({String? pictrue, String? surname, String? name}) =>
      UserProfile(
        id: id,
        pictrue: pictrue ?? this.pictrue,
        userName: userName,
        number: number,
        name: name ?? this.name,
        surname: surname ?? this.surname,
        gender: gender,
        enterSchoolYearGradeId: enterSchoolYearGradeId,
        classId: classId,
        enterSchoolYear: enterSchoolYear,
        gradeName: gradeName,
        className: className,
        credentialsType: credentialsType,
        idNumber: idNumber,
        brithDay: brithDay,
        birthplace: birthplace,
        nation: nation,
        homeAddress: homeAddress,
        mobile: mobile,
        telephone: telephone,
        schoolRollState: schoolRollState,
        state: state,
      );

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    int? intValue(Object? value) =>
        value is num ? value.toInt() : int.tryParse('$value');
    String? nullableString(Object? value) {
      if (value == null) return null;
      final text = value.toString().trim();
      return text.isEmpty ? null : text;
    }

    return UserProfile(
      id: intValue(json['id']),
      pictrue: (json['pictrue'] ?? json['picture'] ?? '').toString(),
      userName: (json['userName'] ?? '').toString(),
      number: (json['number'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      surname: (json['surname'] ?? '').toString(),
      gender: intValue(json['gender']),
      enterSchoolYearGradeId: intValue(json['enterSchoolYearGradeId']),
      classId: intValue(json['classId']),
      enterSchoolYear: (json['enterSchoolYear'] ?? '').toString(),
      gradeName: (json['gradeName'] ?? '').toString(),
      className: (json['className'] ?? '').toString(),
      credentialsType: intValue(json['credentialsType']),
      idNumber: (json['idNumber'] ?? '').toString(),
      brithDay: nullableString(json['brithDay'] ?? json['birthDay']),
      birthplace: (json['birthplace'] ?? '').toString(),
      nation: (json['nation'] ?? '').toString(),
      homeAddress: (json['homeAddress'] ?? '').toString(),
      mobile: nullableString(json['mobile']),
      telephone: (json['telephone'] ?? '').toString(),
      schoolRollState: intValue(json['schoolRollState']),
      state: intValue(json['state']),
    );
  }
}
