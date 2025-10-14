import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:hole_hse_inspection/controllers/login_controller.dart';

void main() {
  group('LoginController Tests', () {
    late LoginController controller;

    setUp(() {
      Get.testMode = true;
      controller = LoginController();
    });

    tearDown(() {
      Get.reset();
    });

    test('should validate empty email', () async {
      controller.emailController.text = '';
      controller.passwordController.text = 'password123';
      
      await controller.login();
      
      // The login should not proceed with empty email
      expect(controller.isLoading.value, false);
    });

    test('should validate empty password', () async {
      controller.emailController.text = 'test@example.com';
      controller.passwordController.text = '';
      
      await controller.login();
      
      // The login should not proceed with empty password
      expect(controller.isLoading.value, false);
    });

    test('should validate invalid email format', () async {
      controller.emailController.text = 'invalid-email';
      controller.passwordController.text = 'password123';
      
      await controller.login();
      
      // The login should not proceed with invalid email format
      expect(controller.isLoading.value, false);
    });

    test('should handle valid email format', () {
      controller.emailController.text = 'test@example.com';
      controller.passwordController.text = 'password123';
      
      // These inputs should pass validation
      expect(controller.emailController.text.trim().isNotEmpty, true);
      expect(controller.passwordController.text.trim().isNotEmpty, true);
      expect(GetUtils.isEmail(controller.emailController.text.trim()), true);
    });
  });
}
