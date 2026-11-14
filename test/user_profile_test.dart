import 'package:flutter_test/flutter_test.dart';
import 'package:zhongyu_toolbox/data/models/user_profile.dart';

void main() {
  test('解析 GetUserInfo 字段及空值', () {
    final profile = UserProfile.fromJson({
      'id': 30875,
      'pictrue': 'https://example.com/profile.png',
      'userName': '24wangpeng',
      'number': '920241532',
      'name': '鹏',
      'surname': '王',
      'gender': 1,
      'enterSchoolYearGradeId': 15,
      'classId': 1336,
      'enterSchoolYear': '2024',
      'gradeName': '高三',
      'className': '（15）班',
      'idNumber': '',
      'brithDay': null,
      'mobile': null,
      'schoolRollState': 0,
      'state': 1,
    });

    expect(profile.pictrue, 'https://example.com/profile.png');
    expect(profile.id, 30875);
    expect(profile.fullName, '王鹏');
    expect(profile.gender, 1);
    expect(profile.enterSchoolYearGradeId, 15);
    expect(profile.classId, 1336);
    expect(profile.brithDay, isNull);
    expect(profile.mobile, isNull);
    expect(profile.schoolRollState, 0);
    expect(profile.state, 1);
  });
}
