import 'package:chat_app/controller/auth_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChangePasswardController extends GetxController {
  final AuthController _authController = Get.find<AuthController>();
  final TextEditingController currentPasswardController =
      TextEditingController();
  final TextEditingController newPasswardController = TextEditingController();
  final TextEditingController confirmPasswardController =
      TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final RxBool _isLoading = false.obs;
  final RxString _error = ''.obs;
  final RxBool _obscureCurrentPassward = true.obs;
  final RxBool _obscureNewPassward = true.obs;
  final RxBool _obscureConfirmPassward = true.obs;
  bool get isLoading => _isLoading.value;
  String get error => _error.value;
  bool get obscureCurrentPassward => _obscureCurrentPassward.value;
  bool get obscureNewPassward => _obscureNewPassward.value;
  bool get obscureConfirmPassward => _obscureConfirmPassward.value;

  @override
  void onClose() {
    currentPasswardController.dispose();
    newPasswardController.dispose();
    confirmPasswardController.dispose();
    super.onClose();
  }

  void toggleCurrentPasswardVisibility() {
    _obscureCurrentPassward.value = !_obscureCurrentPassward.value;
  }

  void toggleNewPasswardVisibility() {
    _obscureNewPassward.value = !_obscureNewPassward.value;
  }

  void toggleConfirmPasswardVisibility() {
    _obscureConfirmPassward.value = !_obscureConfirmPassward.value;
  }

  Future<void> changePassward() async {
    if (!formKey.currentState!.validate()) return;
    try {
      _isLoading.value = true;
      _error.value = '';
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('No User Logged In');
      }
     
     
      await user.updatePassword(newPasswardController.text);
     
      Get.snackbar(
        'Success',
        'Passward Changes Successfully',
        backgroundColor: Colors.green.withOpacity(0.1),
        colorText: Colors.green,
        duration: Duration(seconds: 2),
      );
      currentPasswardController.clear();
      newPasswardController.clear();
      confirmPasswardController.clear();
     await _authController.signOut();
    } on FirebaseAuthException catch (e) {
      String errorMassage;
      switch (e.code) {
        case 'wrong-password':
          errorMassage = 'Current Passward is Incorrect';
          break;
        case 'weak-password':
          errorMassage = 'Current Passward is too weak';
          break;
        case 'requires-recent-login':
          errorMassage =
              'Please sign out and sign in again before changing password';
          break;
        default:
          errorMassage = 'Failed to Change Password';
      }
      _error.value = errorMassage;
      Get.snackbar(
        'Error',
        errorMassage,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
        duration: Duration(seconds: 4),
      );
    } catch (e) {
      _error.value = "Falied To Change Password";
      print(e.toString());
      Get.snackbar(
        'Error',
        _error.value,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
        duration: Duration(seconds: 4),
      );
    } finally {
      _isLoading.value = false;
    }
  }  
    String? validateCurrentPassword(String? value) {
      if (value?.isEmpty ?? true) {
        return 'Please Enter Your Current Password!';
      }
      return null;
    }

    String? validateNewPassword(String? value) {
      if (value?.isEmpty ?? true) {
        return 'Please Enter New Password!';
      }
      if (value!.length < 6) {
        return 'Password Must be atleat 6 characters';
      }
      if (value == currentPasswardController.text) {
        return 'Password be different from the current password';
      }
      return null;
    }

    String? validateConfirmPassword(String? value) {
      if (value?.isEmpty ?? true) {
        return 'Please confirm your Password!';
      }
      if (value != newPasswardController.text) {
        return "Password Does Not Match";
      }
    return null;
    }
void clearError(){
  _error.value='';
}
  
  }
