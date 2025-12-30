import 'package:chat_app/controller/auth_controller.dart';
import 'package:chat_app/routes/app_routes.dart';
import 'package:chat_app/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:get/instance_manager.dart';
import 'package:get/utils.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final _displayNameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _passwardController = TextEditingController();
  final _confirmPasswardController = TextEditingController();

  final _emailController = TextEditingController();
  final AuthController _authController = Get.find<AuthController>();
  var _obscurePassward = true;
  var _obscureConfirmPassward = true;
  @override
  void dispose() {
    _emailController.dispose();
    _passwardController.dispose();
    _displayNameController.dispose();
    _confirmPasswardController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20),

                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        Get.back();
                      },
                      icon: Icon(Icons.arrow_back, size: 30),
                    ),
                    Text(
                      "Create Account",
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Center(
                  child: Text(
                    "Fill in your details to get started",
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondaryColor,
                    ),
                  ),
                ),
                SizedBox(height: 40),
                TextFormField(
                  controller: _displayNameController,

                  decoration: InputDecoration(
                    labelText: "Display Name",
                    prefixIcon: Icon(Icons.person_outlined),
                    hintText: 'Display Name ',
                  ),
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Please enter you Name';
                    }

                    return null;
                  },
                ),
                SizedBox(height: 40),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: "Email",
                    prefixIcon: Icon(Icons.email_outlined),
                    hintText: 'Enter your email',
                  ),
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Please enter you email';
                    }
                    if (!GetUtils.isEmail(value!)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 40),
                TextFormField(
                  controller: _passwardController,
                  obscureText: _obscurePassward,
                  decoration: InputDecoration(
                    labelText: "Passward",
                    prefixIcon: Icon(Icons.lock_outline),
                    hintText: 'Enter your passward',
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassward
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassward = !_obscurePassward;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Please enter you passward';
                    }
                    if (value!.length < 6) {
                      return "Passward must be at least 6 characters";
                    }
                    return null;
                  },
                ),
                SizedBox(height: 40),
                TextFormField(
                  controller: _confirmPasswardController,
                  obscureText: _obscureConfirmPassward,
                  decoration: InputDecoration(
                    labelText: "Confirm Passward",
                    prefixIcon: Icon(Icons.lock_outline),
                    hintText: 'Confirm your passward',
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassward
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassward = !_obscureConfirmPassward;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Please confirm your passward !';
                    }
                    if (value != _passwardController.text) {
                      return 'Passward Mismatched';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 24),
                Obx(
                  () => SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed:
                          _authController.isLoading
                              ? null
                              : () {
                                if (_formKey.currentState?.validate() ??
                                    false) {
                                  _authController.registerwithEmailAndPassward(
                                    _emailController.text.trim(),
                                    _passwardController.text,
                                    _displayNameController.text
                                    
                                  );
                                }
                              },
                      child:
                          _authController.isLoading
                              ? SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                              : Text("Create Account"),
                    ),
                  ),
                ),

                SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(child: Divider(color: AppTheme.borderColor)),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        "OR",
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                    Expanded(child: Divider(color: AppTheme.borderColor)),
                  ],
                ),
                SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Already have an account ? ",
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    SizedBox(width: 12),
                    GestureDetector(
                      onTap: () => Get.toNamed(AppRoutes.login),
                      child: Text(
                        ' Sign In',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
