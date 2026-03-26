import 'package:chat_app/controller/change_passward_controller.dart';
import 'package:chat_app/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChangePasswordView extends StatelessWidget {
  const ChangePasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    final contoller = Get.put(ChangePasswardController());
    return Scaffold(
      appBar: AppBar(title: Text("Change Password"), centerTitle: true),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: Form(
            key: contoller.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 20,
                  child: Center(
                    child: Container(
                      height: 80,
                      width: 80,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.security_rounded,
                        size: 40,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 24),
                Text(
                  'Update Your Password',
                  style: Theme.of(Get.context!).textTheme.headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8),
                Text(
                  'Enter your current password and choose a new secure password',
                  style: Theme.of(Get.context!).textTheme.headlineMedium
                      ?.copyWith(color: AppTheme.textSecondaryColor),
                  textAlign: TextAlign.start,
                ),
                SizedBox(height: 8),
                Obx(
                  () => TextFormField(
                    controller: contoller.currentPasswardController,
                    obscureText: contoller.obscureCurrentPassward,
                    decoration: InputDecoration(
                      hintText: 'Enter your current password',
                      labelText: 'Current Password',
                      prefixIcon: Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        onPressed: contoller.toggleCurrentPasswardVisibility,
                        icon: Icon(
                          contoller.obscureCurrentPassward
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_rounded,
                        ),
                      ),
                    ),
                    validator: contoller.validateCurrentPassword,
                  ),
                ),
                SizedBox(height: 20),
                Obx(
                  () => TextFormField(
                    controller: contoller.newPasswardController,
                    obscureText: contoller.obscureNewPassward,
                    decoration: InputDecoration(
                      hintText: 'Enter you new password',
                      labelText: 'New password',
                      prefixIcon: Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        onPressed: contoller.toggleNewPasswardVisibility,
                        icon: Icon(
                          contoller.obscureNewPassward
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_rounded,
                        ),
                      ),
                    ),
                    validator: contoller.validateNewPassword,
                  ),
                ),
                SizedBox(height: 20),
                SizedBox(height: 20),
                Obx(
                  () => TextFormField(
                    controller: contoller.confirmPasswardController,
                    obscureText: contoller.obscureConfirmPassward,
                    decoration: InputDecoration(
                      labelText: 'Confirm New Password',
                      prefixIcon: Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        onPressed: contoller.toggleConfirmPasswardVisibility,
                        icon: Icon(
                          contoller.obscureConfirmPassward
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_rounded,
                        ),
                      ),
                      hintText: 'Confirm your new password',
                    ),
                    validator: contoller.validateConfirmPassword,
                  ),
                ),
                SizedBox(height: 20),
                Obx(
                  () => SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed:
                          contoller.isLoading ? null : contoller.changePassward,
                      icon:
                          contoller.isLoading
                              ? SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                              : Icon(Icons.security),
                      label: Text(
                        contoller.isLoading ? 'Updating' : 'Update Password',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
