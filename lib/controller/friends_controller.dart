import 'dart:async';

import 'package:chat_app/controller/auth_controller.dart';
import 'package:chat_app/models/friendship_model.dart';
import 'package:chat_app/models/user_model.dart';
import 'package:chat_app/routes/app_routes.dart';
import 'package:chat_app/services/firestore_service.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';

class FriendsController extends GetxController {
  final FirestoreService _firestoreService = FirestoreService();
  final AuthController _authController = Get.find<AuthController>();
  final RxList<FriendshipModel> _friendships = <FriendshipModel>[].obs;
  final RxList<UserModel> _friends = <UserModel>[].obs;
  final RxBool _isLoading = false.obs;
  final RxString _error = ''.obs;
  final RxString _searchQuery = ''.obs;
  final RxList<UserModel> _filteredFriends = <UserModel>[].obs;
  StreamSubscription? _friendshipsSubscriptions;
  List<FriendshipModel> get friendships => _friendships.toList();
  List<UserModel> get friends => _friends;
  List<UserModel> get filteredFriends => _filteredFriends.toList();
  bool get isLoading => _isLoading.value;
  String get error => _error.value;
  String get searchQuery => _searchQuery.value;
  @override
  void onInit() {
    super.onInit();
    _loadFriends();
    debounce(
      _searchQuery,
      (_) => _filteredFriends(),
      time: Duration(milliseconds: 300),
    );
  }

  @override
  void onClose() {
    _friendshipsSubscriptions?.cancel();
    super.onClose();
  }

  void _loadFriends() {
    final currentUserId = _authController.user?.uid;
    if (currentUserId != null) {
      _friendshipsSubscriptions?.cancel();
      _friendshipsSubscriptions = _firestoreService
          .getFriendsStream(currentUserId)
          .listen((friendshipList) {
            _friendships.value = friendshipList;
            _loadFriendDetails(currentUserId, friendshipList);
          });
    }
  }

  Future<void> _loadFriendDetails(
    String currentUserId,
    List<FriendshipModel> friendshipList,
  ) async {
    try {
      _isLoading.value = true;
      List<UserModel> friendUsers = [];
      final futures =
          friendshipList.map((friendships) async {
            String friendId = friendships.getOtherUserId(currentUserId);
            return await _firestoreService.getUser(friendId);
          }).toList();
      final results = await Future.wait(futures);
      for (var friend in results) {
        if (friend != null) {
          friendUsers.add(friend);
        }
      }
      _friends.value = friendUsers;
      _filterFriends();
    } catch (e) {
      _error.value = e.toString();
    } finally {
      _isLoading.value = false;
    }
  }

  void _filterFriends() {
    final query = _searchQuery.value.toLowerCase();
    if (query.isEmpty) {
      _filteredFriends.value = friends;
    } else {
      _filteredFriends.value =
          _friends.where((friend) {
            return friend.displayName.toLowerCase().contains(query) ||
                friend.email.toLowerCase().contains(query);
          }).toList();
    }
  }

  void updateSearchQuery(String query) {
    _searchQuery.value = query;
  }

  void clearSearch() {
    _searchQuery.value = '';
  }

  Future<void> refreshFriends() async {
    final currentUserId = _authController.user?.uid;
    if (currentUserId != null) {
      _loadFriends();
    }
  }

  Future<void> removeFriend(UserModel friend) async {
    try {
      final result = await Get.dialog<bool>(
        AlertDialog(
          title: Text('Remove Friend'),
          content: Text(
            'Are you sure you want to remove ${friend.displayName} from your friends ?',
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Get.back(result: true),
              child: Text('Remove'),
              style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
            ),
          ],
        ),
      );
      if (result == true) {
        final currentUserId = _authController.user?.uid;
        if (currentUserId != null) {
          await _firestoreService.removeFriendShip(currentUserId, friend.id);
          Get.snackbar(
            'Success',
            "${friend.displayName} has been remove from your friends",
            backgroundColor: Colors.green.withOpacity(0.1),
            colorText: Colors.green,
            duration: Duration(seconds: 4),
          );
        }
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        "Falied to remove friend ",
        backgroundColor: Colors.redAccent.withOpacity(0.1),
        colorText: Colors.redAccent,
        duration: Duration(seconds: 4),
      );
      print(e.toString());
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> blockFriend(UserModel friend) async {
    try {
      final result = await Get.dialog<bool>(
        AlertDialog(
          title: Text('Block User'),
          content: Text(
            'Are you sure you want to block ${friend.displayName} You will no longer friends ?',
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Get.back(result: true),
              style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
              child: Text('Block'),
            ),
          ],
        ),
      );
      if (result == true) {
        final currentUserId = _authController.user?.uid;
        if (currentUserId != null) {
          await _firestoreService.blockUser(currentUserId, friend.id);
          Get.snackbar(
            'Success',
            "${friend.displayName} has been blocked",
            backgroundColor: Colors.green.withOpacity(0.1),
            colorText: Colors.green,
            duration: Duration(seconds: 4),
          );
        }
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        "Falied to block user ",
        backgroundColor: Colors.redAccent.withOpacity(0.1),
        colorText: Colors.redAccent,
        duration: Duration(seconds: 4),
      );
      print(e.toString());
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> startChat(UserModel friend) async {
    try {
      _isLoading.value = true;
      final currentUserId = _authController.user?.uid;
      if (currentUserId != null) {
        Get.toNamed(
          AppRoutes.chat,
          arguments: {'chatId': null, 'OtherUser': friend, 'isNewChat': true},
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to start chat',
        backgroundColor: Colors.redAccent.withOpacity(0.1),
        colorText: Colors.redAccent,
        duration: Duration(seconds: 4),
      );
      print(e.toString());
    } finally {
      _isLoading.value = false;
    }
  }
   String getLastSeenText(UserModel user) {
    if (user.isOnline) {
      return 'Online';
    } else {
      final now = DateTime.now();
      final difference = now.difference(user.lastSeen);
      if (difference.inMinutes < 1) {
        return 'Just Now';
      } else if (difference.inHours < 1) {
        return 'Last Seen ${difference.inMinutes} m ago';
      } else if (difference.inDays < 1) {
        return 'Last Seen ${difference.inHours} h ago';
      } else if (difference.inDays < 7) {
        return 'Last Seen ${difference.inDays} d ago';
      } else {
        return 'Last seen ${user.lastSeen.day}/${user.lastSeen.month}/${user.lastSeen.year}';
      }
    }
  }
  void openFriendRequests(){
    Get.toNamed(AppRoutes.friendRequests);
  }
  void clearError(){
    _error.value = '';
  }
}
