import 'package:chat_app/controller/profile_controller.dart';
import 'package:chat_app/routes/app_routes.dart';
import 'package:chat_app/theme/app_theme.dart';
import 'package:chat_app/views/main_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor.withOpacity(0.2),
        title: Text("Profile"),
        leading: IconButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (BuildContext context) => MainView()),
            );
          },
          icon: Icon(Icons.arrow_back),
        ),
        actions: [
          Obx(
            () => TextButton(
              onPressed:
                  controller.isEditing
                      ? controller.toggleEditing
                      : controller.toggleEditing,
              child: Text(
                controller.isEditing ? 'Cancel' : 'Edit',
                style: TextStyle(
                  color:
                      controller.isEditing
                          ? AppTheme.errorColor
                          : AppTheme.primaryColor,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Obx(() {
        final user = controller.currentUser;
        if (user == null) {
          return Center(
            child: CircularProgressIndicator(color: AppTheme.primaryColor),
          );
        }
        return SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: Column(
            children: [
              Column(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: AppTheme.primaryColor,
                        child:
                            user.photoURL.isNotEmpty
                                ? ClipOval(
                                  child: Image.network(
                                    user.photoURL,
                                    height: 120,
                                    width: 120,
                                    fit: BoxFit.cover,
                                    // ignore: avoid_types_as_parameter_names
                                    errorBuilder: (context, error, StackTrace) {
                                      return _buildAefaultAvatar(user);
                                    },
                                  ),
                                )
                                : _buildAefaultAvatar(user),
                      ),
                      if (controller.isEditing)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: IconButton(
                              onPressed: () {
                                Get.snackbar('Info', 'Photo upate coming soon');
                              },
                              icon: Icon(
                                Icons.camera_alt,
                                size: 20,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Text(
                    user.displayName,
                    style: Theme.of(Get.context!).textTheme.headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text(
                    user.email,
                    style: Theme.of(Get.context!).textTheme.bodyMedium
                        ?.copyWith(color: AppTheme.textSecondaryColor),
                  ),
                  SizedBox(height: 8),
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 4, horizontal: 12),
                    decoration: BoxDecoration(
                      color:
                          user.isOnline
                              ? AppTheme.successColor.withOpacity(0.1)
                              : AppTheme.textSecondaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          height: 8,
                          width: 8,
                          decoration: BoxDecoration(
                            color:
                                user.isOnline
                                    ? AppTheme.successColor
                                    : AppTheme.textSecondaryColor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        SizedBox(width: 6),
                        Text(
                          user.isOnline ? 'Online' : 'Offline',
                          style: Theme.of(
                            Get.context!,
                          ).textTheme.bodySmall?.copyWith(
                            color:
                                user.isOnline
                                    ? AppTheme.successColor
                                    : AppTheme.textSecondaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    controller.getJoined(),
                    style: Theme.of(Get.context!).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondaryColor,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 32),
              Obx(
                () => Card(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Personal Information',
                          style: Theme.of(
                            Get.context!,
                          ).textTheme.headlineSmall?.copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 20),
                        TextFormField(
                          controller: controller.displayNameController,
                          enabled: controller.isEditing,
                          decoration: InputDecoration(
                            labelText: 'Display Name ',
                            prefixIcon: Icon(Icons.person_outlined),
                          ),
                        ),
                        SizedBox(height: 16),
                        TextFormField(
                          controller: controller.emailController,
                          enabled: false,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            prefixIcon: Icon(Icons.email_outlined),
                            helperText: "Email can't be changed",
                          ),
                        ),
                        if (controller.isEditing) ...[
                          SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed:
                                  controller.isLoading
                                      ? null
                                      : controller.updateProfile,
                              child:
                                  controller.isLoading
                                      ? SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                      : Text("Save Changed"),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 32),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(
                        Icons.security,
                        color: AppTheme.primaryColor,
                      ),
                      title: Text("Change Passward"),
                      trailing: Icon(Icons.arrow_forward_ios),
                      onTap: () => Get.toNamed(AppRoutes.changePassward),
                    ),
                    Divider(height: 1, color: Colors.grey),
                    ListTile(
                      leading: Icon(
                        Icons.delete_forever,
                        color: AppTheme.errorColor,
                      ),
                      title: Text("Delete Account"),
                      trailing: Icon(Icons.arrow_forward_ios),
                      onTap: controller.deleteAccount,
                    ),
                    Divider(height: 1, color: Colors.grey),
                    ListTile(
                      leading: Icon(Icons.logout, color: AppTheme.errorColor),
                      title: Text("Sign Out"),
                      trailing: Icon(Icons.arrow_forward_ios),
                      onTap: controller.signOut,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30),
              Text(
                'ChatApp v1.0.0',
                style: Theme.of(Get.context!).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondaryColor,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildAefaultAvatar(dynamic user) {
    return Text(
      user.displayName.isNotEmpty ? user.displayName[0].toUpperCase() : '?',
      style: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w600,
        fontSize: 32,
      ),
    );
  }
}
