import 'package:flutter/material.dart';
import 'package:mipal/helpers/constants.dart';
import 'package:mipal/main.dart';
import 'package:mipal/models/userProfile.dart';
import 'package:mipal/pages/profile.dart';
import 'package:mipal/services/user_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  
  @override
  State<HomePage> createState() => _HomePageState();
}


class _HomePageState extends State<HomePage> {
  final UserService userService = UserService();
  UserProfile? userProfile;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final currentUser = supabase.auth.currentUser;
    if (currentUser != null) {
      userProfile = await userService.getUserProfileById(currentUser.id);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AppConstants.appName,
        automaticallyImplyLeading: false,
        actions: [
          SizedBox(
            width: 40,
            height: 40,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.grey[300],
              ),
              child: IconButton(
                  onPressed: () {
                    Navigator
                        .of(context)
                        .push(MaterialPageRoute(builder: (context) => ProfilePage(userProfile: userProfile!)));
                  },
                  icon: Icon(Icons.person, size: 20,)),
            ),
          )
        ],
      ),
      body: Center(
        child: Text(
          'Bienvenue sur la page Home',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}