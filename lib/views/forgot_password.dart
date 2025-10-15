import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hole_hse_inspection/config/color.palate.dart';
import 'package:hole_hse_inspection/controllers/forgot_password_controller.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  late final ForgotPasswordController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(ForgotPasswordController());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background image
          Container(
            height: double.infinity,
            width: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                fit: BoxFit.cover,
                opacity: 0.35,
                image: NetworkImage(
                    "https://img.freepik.com/free-vector/gradient-pink-blue-blur-phone-wallpaper-vector_53876-169255.jpg?t=st=1735910993~exp=1735914593~hmac=14b502f8e4f407eccc9565d6890981a00f7b215ce46ae4135549ec6253159101&w=360"),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 20),

                    // Back button
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back,
                            color: ColorPalette.primaryColor),
                        onPressed: () => Get.back(),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Icon
                    const Icon(
                      Icons.lock_reset,
                      size: 80,
                      color: ColorPalette.primaryColor,
                    ),

                    const SizedBox(height: 30),
                    const Text(
                      'Forgot Password?',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: ColorPalette.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Enter your email address and we\'ll send you instructions to reset your password.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Email TextField
                    TextField(
                      controller: controller.emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        hintText: 'Enter your registered email',
                        prefixIcon: const Icon(Icons.email),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 30),

                    // Send Reset Link Button
                    Obx(() => ElevatedButton(
                          onPressed: controller.isLoading.value
                              ? null
                              : () {
                                  controller.sendResetLink();
                                },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            backgroundColor: ColorPalette.primaryColor,
                            disabledBackgroundColor:
                                ColorPalette.primaryColor.withOpacity(0.6),
                          ),
                          child: controller.isLoading.value
                              ? const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Text(
                                      'Sending...',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                )
                              : const Text(
                                  'Send Reset Link',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.white,
                                  ),
                                ),
                        )),

                    const SizedBox(height: 20),

                    // OTP Section (shown after email is sent)
                    Obx(
                      () => controller.showOtpSection.value
                          ? Column(
                              children: [
                                const Divider(height: 40),
                                const Text(
                                  'Enter OTP',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: ColorPalette.primaryColor,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                const Text(
                                  'Please enter the 6-digit code sent to your email',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 20),

                                // OTP TextField
                                TextField(
                                  controller: controller.otpController,
                                  decoration: InputDecoration(
                                    labelText: 'OTP Code',
                                    hintText: 'Enter 6-digit code',
                                    prefixIcon: const Icon(Icons.security),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  keyboardType: TextInputType.number,
                                  maxLength: 6,
                                ),

                                // New Password TextField
                                Obx(() => TextField(
                                      controller:
                                          controller.newPasswordController,
                                      decoration: InputDecoration(
                                        labelText: 'New Password',
                                        hintText: 'Enter new password',
                                        prefixIcon: const Icon(Icons.lock),
                                        suffixIcon: IconButton(
                                          icon: Icon(
                                            controller.obscurePassword.value
                                                ? Icons.visibility_off
                                                : Icons.visibility,
                                          ),
                                          onPressed: () {
                                            controller.obscurePassword.value =
                                                !controller
                                                    .obscurePassword.value;
                                          },
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                      ),
                                      obscureText:
                                          controller.obscurePassword.value,
                                    )),
                                const SizedBox(height: 20),

                                // Confirm Password TextField
                                Obx(() => TextField(
                                      controller:
                                          controller.confirmPasswordController,
                                      decoration: InputDecoration(
                                        labelText: 'Confirm New Password',
                                        hintText: 'Re-enter new password',
                                        prefixIcon:
                                            const Icon(Icons.lock_outline),
                                        suffixIcon: IconButton(
                                          icon: Icon(
                                            controller.obscureConfirmPassword
                                                    .value
                                                ? Icons.visibility_off
                                                : Icons.visibility,
                                          ),
                                          onPressed: () {
                                            controller.obscureConfirmPassword
                                                    .value =
                                                !controller
                                                    .obscureConfirmPassword
                                                    .value;
                                          },
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                      ),
                                      obscureText: controller
                                          .obscureConfirmPassword.value,
                                    )),
                                const SizedBox(height: 20),

                                // Reset Password Button
                                Obx(() => ElevatedButton(
                                      onPressed: controller.isLoading.value
                                          ? null
                                          : () {
                                              controller.resetPassword();
                                            },
                                      style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 15),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        backgroundColor:
                                            ColorPalette.primaryColor,
                                        disabledBackgroundColor: ColorPalette
                                            .primaryColor
                                            .withOpacity(0.6),
                                      ),
                                      child: controller.isLoading.value
                                          ? const Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                SizedBox(
                                                  width: 20,
                                                  height: 20,
                                                  child:
                                                      CircularProgressIndicator(
                                                    color: Colors.white,
                                                    strokeWidth: 2,
                                                  ),
                                                ),
                                                SizedBox(width: 10),
                                                Text(
                                                  'Resetting...',
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ],
                                            )
                                          : const Text(
                                              'Reset Password',
                                              style: TextStyle(
                                                fontSize: 18,
                                                color: Colors.white,
                                              ),
                                            ),
                                    )),

                                const SizedBox(height: 15),

                                // Resend OTP
                                TextButton(
                                  onPressed: controller.isLoading.value
                                      ? null
                                      : () {
                                          controller.sendResetLink();
                                        },
                                  child: const Text(
                                    'Resend OTP',
                                    style: TextStyle(
                                      color: ColorPalette.primaryColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : Container(),
                    ),

                    const SizedBox(height: 20),

                    // Back to Login Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Remember your password? ',
                          style: TextStyle(color: Colors.grey),
                        ),
                        GestureDetector(
                          onTap: () => Get.back(),
                          child: const Text(
                            'Log In',
                            style: TextStyle(
                              color: ColorPalette.primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
