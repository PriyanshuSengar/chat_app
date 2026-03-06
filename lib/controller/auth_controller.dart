// ignore_for_file: avoid_print

import 'package:chat_app/models/user_model.dart';
import 'package:chat_app/routes/app_routes.dart';
import 'package:chat_app/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class AuthController extends GetxController {
  final AuthService _authService = AuthService();
  final Rx<User?> _user = Rx<User?>(null);
  final Rx<UserModel?> _userModel = Rx<UserModel?>(null);
  final RxBool _isLoading = false.obs;
  final RxString _error = ''.obs;
  final RxBool _isinitialized = false.obs;
  User? get user => _user.value;
  UserModel? get userModel => _userModel.value;
  bool get isLoading => _isLoading.value;
  String get error => _error.value;
  bool get isAuthenticated => _user.value != null;
  bool get isinitialized => _isinitialized.value;
  @override
  void onInit() {
    super.onInit();
    _user.bindStream(_authService.authStateChanges);
    // ever(_user, _handleAuthStateChange);
  }

  // void _handleAuthStateChange(User? user) {
  //   if (user == null) {
  //     if (Get.currentRoute != AppRoutes.login) {
  //       Get.offAllNamed(AppRoutes.login);
  //     } else {
  //       if (Get.currentRoute != AppRoutes.profile) {
  //         Get.offAllNamed(AppRoutes.profile);
  //       }
  //     }
  //   }
  //   if (!_isinitialized.value) {
  //     _isinitialized.value = true;
  //   }
  // }

  // ignore: non_constant_identifier_names
  // void CheckInitialAuthState() {
  //   final currentUser = FirebaseAuth.instance.currentUser;
  //   if (currentUser != null) {
  //     _user.value = currentUser;
  //     Get.offAllNamed(AppRoutes.profile);
  //   } else {
  //     Get.offAllNamed(AppRoutes.login);
  //   }
  //   _isinitialized.value = true;
  // }

  Future<void> signInwithEmailAndPassward(String email, String password) async {
    try {
      _isLoading.value = true;
      _error.value = '';
      UserModel? userModel = await _authService.signInwithEmailAndPassward(
        email,
        password,
      );
      if (userModel != null) {
        _userModel.value = userModel;
        Get.offAllNamed(AppRoutes.main);
        // because we don't have main screen now
      }
    } catch (e) {
      _error.value = e.toString();
      Get.snackbar('Error', 'Falied To Login');
      print(e);
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> registerwithEmailAndPassward(
    String email,
    String password,
    String displayName,
  ) async {
    try {
      _isLoading.value = true;
      _error.value = '';
      UserModel? userModel = await _authService.registerwithEmailAndPassward(
        email,
        password,
        displayName,
      );
      if (userModel != null) {
        _userModel.value = userModel;
        Get.offAllNamed(AppRoutes.main);
      }
    } catch (e) {
      _error.value = e.toString();
      Get.snackbar('Error', 'Falied To Create Account');
      print(e);
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> signOut() async {
    try {
      _isLoading.value = true;
      await _authService.signOut();
      _userModel.value = null;
      Get.offAllNamed(AppRoutes.login);
    } catch (e) {
      _error.value = e.toString();
      Get.snackbar('Error', 'Failed To Sign Out');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> deleteAccount() async {
    try {
      _isLoading.value = true;
      await _authService.deleteAccount();
      _userModel.value = null;
      Get.offAllNamed(AppRoutes.login);
    } catch (e) {
      _error.value = e.toString();
      Get.snackbar('Error', 'Failed To Delete Account');
    } finally {
      _isLoading.value = false;
    }
  }

  void clearError() {
    _error.value = '';
  }
}
