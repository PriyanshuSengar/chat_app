import 'package:chat_app/controller/auth_controller.dart';
import 'package:chat_app/models/friend_request_model.dart';
import 'package:chat_app/models/friendship_model.dart';
import 'package:chat_app/models/user_model.dart';
import 'package:chat_app/services/firestore_service.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

enum UserRelationShipStatus{
  none,
  friendRequestSend,
  friendRequestReceived,
  friends,
  blocked
}
class UserListController extends GetxController{
  final FirestoreService _firestoreService = FirestoreService();
  final AuthController _authController = Get.find<AuthController>();
  final Uuid _uuid = Uuid();
  final RxList<UserModel> _users = <UserModel>[].obs;
  final RxList<UserModel> _filteredUser = <UserModel>[].obs;
  final RxBool _isLoading = false.obs;
  final RxString _searchQuery =''.obs;
  final RxString _error = ''.obs;
  final RxMap<String , UserRelationShipStatus> _userRelationships = <String , UserRelationShipStatus>{}.obs;
  final RxList<FriendRequestModel> _sentRequests = <FriendRequestModel>[].obs;
  final RxList<FriendRequestModel> _receivedRequest = <FriendRequestModel>[].obs;
  final RxList<FriendshipModel> _friendships= <FriendshipModel>[].obs;
  List<UserModel> get users => _users;
  List<UserModel> get filteredUsers => _filteredUser;
  bool get isLoading => _isLoading.value;
  String get searchQuery => _searchQuery.value;
  String get error => _error.value;
  Map<String , UserRelationShipStatus> get userRelationShips =>
  _userRelationships;
  @override
  void onInit(){
    super.onInit();
    _loadUsers();
    // _loadRelationships();
    debounce(_sentRequests, (_) => _filteredUser(),time: Duration(milliseconds: 300));
  }
  void _loadUsers()async{
    _users.bindStream(_firestoreService.getAllUserStream());
    ever(_users , (List<UserModel> userList){
      final currentuserId = _authController.user?.uid;
      final otherUsers = userList.where((user)=>user.id != currentuserId).toList();
      if(_searchQuery.isEmpty){
        _filteredUser.value = otherUsers;

      }
      else{
        _filteredUser();
      }
    });
    void _loadRelationships(){
final currentuserId = _authController.user?.uid;
if(currentuserId == null){
  _sentRequests.bindStream(
    _firestoreService.getSentFriendRequestsStream(currentuserId!)
    );
  _receivedRequest.bindStream(
    _firestoreService.getFriendRequestsStream(currentuserId)
    );
  _friendships.bindStream(
    _firestoreService.getFriendsStream(currentuserId)
    );
    ever(_sentRequests , (_)=> _updateAllRelationshipsStatus());
    ever(_receivedRequest , (_)=> _updateAllRelationshipsStatus());
    ever(_friendships, (_)=> _updateAllRelationshipsStatus());
    ever(_users, (_)=> _updateAllRelationshipsStatus());
}
    }
  }

void  _updateAllRelationshipsStatus(){
  final currentUserId = _authController.user?.uid;
  if(currentUserId == null) return;
  for(var user in _users){
    if(user.id != currentUserId){

    }
  }
}
  

}