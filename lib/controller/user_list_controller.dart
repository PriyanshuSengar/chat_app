import 'package:chat_app/controller/auth_controller.dart';
import 'package:chat_app/models/friend_request_model.dart';
import 'package:chat_app/models/friendship_model.dart';
import 'package:chat_app/models/user_model.dart';
import 'package:chat_app/routes/app_routes.dart';
import 'package:chat_app/services/firestore_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

enum UserRelationShipStatus {
  none,
  friendRequestSend,
  friendRequestReceived,
  friends,
  blocked,
}

class UserListController extends GetxController {
  final FirestoreService _firestoreService = FirestoreService();
  final AuthController _authController = Get.find<AuthController>();
  final Uuid _uuid = Uuid();
  final RxList<UserModel> _users = <UserModel>[].obs;
  final RxList<UserModel> _filteredUser = <UserModel>[].obs;
  final RxBool _isLoading = false.obs;
  final RxString _searchQuery = ''.obs;
  final RxString _error = ''.obs;
  final RxMap<String, UserRelationShipStatus> _userRelationships =
      <String, UserRelationShipStatus>{}.obs;
  final RxList<FriendRequestModel> _sentRequests = <FriendRequestModel>[].obs;
  final RxList<FriendRequestModel> _receivedRequest =
      <FriendRequestModel>[].obs;
  final RxList<FriendshipModel> _friendships = <FriendshipModel>[].obs;
  List<UserModel> get users => _users;
  List<UserModel> get filteredUsers => _filteredUser;
  bool get isLoading => _isLoading.value;
  String get searchQuery => _searchQuery.value;
  String get error => _error.value;
  Map<String, UserRelationShipStatus> get userRelationShips =>
      _userRelationships;
  @override
  void onInit() {
    super.onInit();
    _loadUsers();
    _loadRelationships();
    debounce(
      _searchQuery,
      (_) => filterUser(),
      time: Duration(milliseconds: 300),
    );
  }

  void _loadUsers() async {
    _users.bindStream(_firestoreService.getAllUserStream());
    ever(_users, (List<UserModel> userList) {
      final currentuserId = _authController.user?.uid;
      final otherUsers =
          userList.where((user) => user.id != currentuserId).toList();
      if (_searchQuery.value.isEmpty) {
        _filteredUser.value = otherUsers;
      } else {
        filterUser();
      }
    });
  }

  void _loadRelationships() async {
    final currentuserId = _authController.user?.uid;
    if (currentuserId != null) {
      _sentRequests.bindStream(
        _firestoreService.getSentFriendRequestsStream(currentuserId),
      );
      _receivedRequest.bindStream(
        _firestoreService.getFriendRequestsStream(currentuserId),
      );
      _friendships.bindStream(
        _firestoreService.getFriendsStream(currentuserId),
      );
      ever(_sentRequests, (_) => _updateAllRelationshipsStatus());
      ever(_receivedRequest, (_) => _updateAllRelationshipsStatus());
      ever(_friendships, (_) => _updateAllRelationshipsStatus());
      ever(_users, (_) => _updateAllRelationshipsStatus());
    }
  }

  void _updateAllRelationshipsStatus() {
    final currentUserId = _authController.user?.uid;
    if (currentUserId == null) return;
    for (var user in _users) {
      if (user.id != currentUserId) {
        final status = _calculateUserRelationShipStatus(user.id);
        _userRelationships[user.id] = status;
      }
    }
  }

  UserRelationShipStatus _calculateUserRelationShipStatus(String userId) {
    final currentUserId = _authController.user?.uid;
    if (currentUserId == null) return UserRelationShipStatus.none;
    final frienship = _friendships.firstWhereOrNull(
      (f) =>
          (f.user1Id == currentUserId && f.user2Id == userId) ||
          (f.user1Id == userId && f.user2Id == currentUserId),
    );
    if (frienship != null) {
      if (frienship.isBlocked) {
        return (UserRelationShipStatus.blocked);
      } else {
        return UserRelationShipStatus.friends;
      }
    }
    final sentRequest = _sentRequests.firstWhereOrNull(
      (r) => r.receiverId == userId && r.status == FriendRequestStatus.pending,
    );
    if (sentRequest != null) {
      return UserRelationShipStatus.friendRequestSend;
    }
    final receiveRequest = _receivedRequest.firstWhereOrNull(
      (r) => r.senderId == userId && r.status == FriendRequestStatus.pending,
    );
    if (receiveRequest != null) {
      return UserRelationShipStatus.friendRequestReceived;
    }
    return UserRelationShipStatus.none;
  }

  void filterUser() {
    final currenUserId = _authController.user?.uid;
    final query = _searchQuery.value.toLowerCase();
    if (query.isEmpty) {
      _filteredUser.value =
          _users.where((user) => user.id != currenUserId).toList();
    } else {
      _filteredUser.value =
          _users.where((user) {
            return user.id != currenUserId &&
                (user.displayName.toLowerCase().contains(query) ||
                    user.email.toLowerCase().contains(query));
          }).toList();
    }
  }

  void updateSearchQuery(String query) {
    _searchQuery.value = query;
    filterUser();
  }

  void clearSearch() {
    _searchQuery.value = "";
    filterUser();
  }

  Future<void> sendFriendRequest(UserModel user) async {
    try {
      _isLoading.value = true;
      final currentUserId = _authController.user?.uid;
      if (currentUserId != null) {
        final request = FriendRequestModel(
          id: _uuid.v4(),
          senderId: currentUserId,
          receiverId: user.id,
          createdAt: DateTime.now(),
        );
        _userRelationships[user.id] = UserRelationShipStatus.friendRequestSend;
        await _firestoreService.sendFriendRequest(request);
        Get.snackbar('Success', "friend request sent to ${user.displayName}");
      }
    } catch (e) {
      _userRelationships[user.id] = UserRelationShipStatus.none;
      _error.value = e.toString();
      print("Error sending friend request : $e");
      Get.snackbar('Error', "Falied to send friend request");
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> cancelFriendRequest(UserModel user) async {
    try {
      _isLoading.value = true;
      final currentUserId = _authController.user?.uid;
      if (currentUserId != null) {
        final request = _sentRequests.firstWhereOrNull(
          (r) =>
              r.receiverId == user.id &&
              r.status == FriendRequestStatus.pending,
        );
        if (request != null) {
          _userRelationships[user.id] = UserRelationShipStatus.none;
          await _firestoreService.cancelFriendRequest(request.id);
          Get.snackbar('Success', 'Friend Request Cancelled');
        }
      }
    } catch (e) {
      _userRelationships[user.id] = UserRelationShipStatus.friendRequestSend;
      _error.value = e.toString();
      print("Error cancelling friend request : $e");
      Get.snackbar('Error', "Falied to cancel friend request");
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> acceptFriendRequest(UserModel user) async {
    try {
      _isLoading.value = true;
      final currentUserId = _authController.user?.uid;
      if (currentUserId != null) {
        final request = _receivedRequest.firstWhereOrNull(
          (r) =>
              r.senderId == user.id && r.status == FriendRequestStatus.pending,
        );
        if (request != null) {
          _userRelationships[user.id] = UserRelationShipStatus.friends;
          await _firestoreService.respondToFriendRequest(
            request.id,
            FriendRequestStatus.accepted,
          );
          Get.snackbar('Success', 'Friend Request Accepted');
        }
      }
    } catch (e) {
      _userRelationships[user.id] =
          UserRelationShipStatus.friendRequestReceived;
      _error.value = e.toString();
      print("Error accepting friend request : $e");
      Get.snackbar('Error', "Falied to accept friend request");
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> declineFriendRequest(UserModel user) async {
    try {
      _isLoading.value = true;
      final currentUserId = _authController.user?.uid;
      if (currentUserId != null) {
        final request = _receivedRequest.firstWhereOrNull(
          (r) =>
              r.senderId == user.id && r.status == FriendRequestStatus.pending,
        );
        if (request != null) {
          _userRelationships[user.id] = UserRelationShipStatus.none;
          await _firestoreService.respondToFriendRequest(
            request.id,
            FriendRequestStatus.declined,
          );
          Get.snackbar('Success', 'Friend Request Declined');
        }
      }
    } catch (e) {
      _userRelationships[user.id] =
          UserRelationShipStatus.friendRequestReceived;
      _error.value = e.toString();
      print("Error declining friend request : $e");
      Get.snackbar('Error', "Falied to decline  friend request");
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> startChat(UserModel user) async {
    try {
      _isLoading.value = true;
      final currentUserId = _authController.user?.uid;
      if (currentUserId != null) {
        final relatioship =
            _userRelationships[user.id] ?? UserRelationShipStatus.none;
        if (relatioship != UserRelationShipStatus.friends) {
          Get.snackbar(
            'Info',
            "You can only chat with friends . Please send friend request first",
          );
          return;
        }
        final chatId = await _firestoreService.createOrGetChat(
          currentUserId,
          user.id,
        );
        Get.toNamed(
          AppRoutes.chat,
          arguments: {'chatId': chatId, 'otheruser': user},
        );
      }
    } catch (e) {
      _error.value = e.toString();
      print("Error starting chat : $e");
      Get.snackbar('Error', 'Failed to start chat');
    } finally {
      _isLoading.value = false;
    }
  }

  UserRelationShipStatus getUserRelationshipStatus(String userId) {
    return _userRelationships[userId] ?? UserRelationShipStatus.none;
  }

  String getRelationshipButtonText(UserRelationShipStatus status) {
    switch (status) {
      case UserRelationShipStatus.none:
        return 'Add friend';
      case UserRelationShipStatus.friendRequestSend:
        return 'Request Sent';
      case UserRelationShipStatus.friendRequestReceived:
        return 'Accept ';
      case UserRelationShipStatus.friends:
        return 'Message';
      case UserRelationShipStatus.blocked:
        return 'Blocked';
    }
  }

  IconData getRelationButtonIcon(UserRelationShipStatus status) {
    switch (status) {
      case UserRelationShipStatus.none:
        return Icons.person_add;
      case UserRelationShipStatus.friendRequestSend:
        return Icons.access_time;
      case UserRelationShipStatus.friendRequestReceived:
        return Icons.check;
      case UserRelationShipStatus.friends:
        return Icons.chat_bubble_outline;
      case UserRelationShipStatus.blocked:
        return Icons.block;
    }
  }

  Color getRelationshipButtonColor(UserRelationShipStatus status) {
    switch (status) {
      case UserRelationShipStatus.none:
        return Colors.blue;
      case UserRelationShipStatus.friendRequestSend:
        return Colors.orange;
      case UserRelationShipStatus.friendRequestReceived:
        return Colors.green;
      case UserRelationShipStatus.friends:
        return Colors.blue;
      case UserRelationShipStatus.blocked:
        return Colors.redAccent;
    }
  }

  void handleRelationshipAction(UserModel user) {
    final status = getUserRelationshipStatus(user.id);
    switch (status) {
      case UserRelationShipStatus.none:
        sendFriendRequest(user);
        break;
      case UserRelationShipStatus.friendRequestSend:
        cancelFriendRequest(user);
        break;
      case UserRelationShipStatus.friendRequestReceived:
        acceptFriendRequest(user);
        break;
      case UserRelationShipStatus.friends:
        startChat(user);
        break;
      case UserRelationShipStatus.blocked:
        Get.snackbar('Info', "You have bloacked this user");
        break;
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

  void _clearError() {
    _error.value = '';
  }
}
