abstract class LoginValidators {
  static String? usernameValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Kullanıcı adı boş geçilemez';
    }
    return null;
  }

  static String? passwordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Şifre boş geçilemez';
    }
    return null;
  }
}
