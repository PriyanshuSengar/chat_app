import 'package:chat_app/controller/main_controller.dart';
import 'package:chat_app/controller/profile_controller.dart';
import 'package:chat_app/routes/app_routes.dart';
import 'package:chat_app/views/auth/forgot_passward_view.dart';
import 'package:chat_app/views/auth/login_view.dart';
import 'package:chat_app/views/auth/profile/change_password_view.dart';
import 'package:chat_app/views/auth/register_view.dart';
import 'package:chat_app/views/auth/profile/profile_view.dart';
import 'package:chat_app/views/main_view.dart';
import 'package:chat_app/views/splash_view.dart';
import 'package:get/get.dart';

class AppPages {
  static const initial = AppRoutes.splash;
  static final routes =[
    GetPage(name: AppRoutes.splash, page: ()=>const SplashView()),
    GetPage(name: AppRoutes.login, page: ()=>const LoginView()),
    GetPage(name: AppRoutes.register, page: ()=>const RegisterView()),
    GetPage(name: AppRoutes.forgotPassward, page: ()=> ForgotPasswardView(),),
    GetPage(name: AppRoutes.changePassward, page: ()=>const ChangePasswordView(),),
    // GetPage(name: AppRoutes.home, page: ()=>const HomeView(),binding: BindingsBuilder((){
    //   Get.put(HomeController());
    // })),
    GetPage(name: AppRoutes.main, page: ()=> MainView(),binding: BindingsBuilder((){
      Get.put(MainController());
    })),
    GetPage(name: AppRoutes.profile, page: ()=>const ProfileView(),binding: BindingsBuilder((){
      Get.put(ProfileController());
    })),
    // GetPage(name: AppRoutes.chat, page: ()=>const ChatView(),binding: BindingsBuilder((){
    //   Get.put(ChatController());
    // })),
    // GetPage(name: AppRoutes.userList, page: ()=>const UserListView(),binding: BindingsBuilder((){
    //   Get.put(UserListController());
    // })),
    // GetPage(name: AppRoutes.friends, page: ()=>const FriendsView(),binding: BindingsBuilder((){
    //   Get.put(FriendsController());
    // })),
    // GetPage(name: AppRoutes.friendRequests,
    //  page: ()=>const FriendRequestsView(), 
    // binding: BindingsBuilder((){
    //   Get.put(FriendRequestsController());
    // })),
    // GetPage(name: AppRoutes.notifications, 
    // page: ()=>const NotificationsView(),
    // binding: BindingsBuilder((){
    //   Get.put(NotificationsController());
    // })),

  ];
}