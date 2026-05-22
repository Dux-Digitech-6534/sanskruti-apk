import 'package:flutter_test/flutter_test.dart';
import 'package:sanskruti_group/core/constants/app_constants.dart';

void main() {
  test('app constants expose the production brand', () {
    expect(AppConstants.appName, 'Sanskruti Developers');
    expect(AppConstants.poweredBy, 'Dux Digitech');
  });
}
