import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ihealth_naija_test_version/config/theme.dart';
import 'package:ihealth_naija_test_version/screens/login_screen.dart';
import '../providers/auth_provider.dart';
import '../widgets/profile_info_card.dart';
import '../utils/date_formatter.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  Future<void> _handleLogout(BuildContext context, WidgetRef ref) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
          child: CircularProgressIndicator(),
        ),
      );

      await ref.read(authProvider.notifier).logout();

      Navigator.pop(context);

      Navigator.pushAndRemoveUntil(
        // ignore: use_build_context_synchronously
        context,
        MaterialPageRoute(builder: (context) => LoginScreen(onRegister: () {  }, onLoginSuccess: () {  },)),
        (route) => false,
      );
    } catch (e) {
      // ignore: use_build_context_synchronously
      Navigator.pop(context);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to logout. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get user data from the auth provider
    final user = ref.watch(userProvider);
    final userName = user?.name ?? 'Guest User';
    final userEmail = user?.email ?? 'No email available';
    final userGender = user?.gender ?? 'Not specified';
    
    // Format date of birth if available using the DateFormatter class
    final dateOfBirth = user?.dateOfBirth != null 
        ? DateFormatter.formatDate(DateTime.parse(user!.dateOfBirth!))
        : 'Not available';

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 200.0,
              floating: false,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppTheme.primaryColor,
                        AppTheme.primaryColor.withOpacity(0.8),
                        AppTheme.primaryColor.withOpacity(0.6),
                      ],
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.white,
                        child: Icon(Icons.person, size: 50, color: AppTheme.moderateColor),
                      ),
                      SizedBox(height: 10),
                      Text(
                        userName,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () {
                    // TODO: Navigate to edit profile
                  },
                ),
                PopupMenuButton<String>(
                  onSelected: (value) async {
                    if (value == 'logout') {
                      await _handleLogout(context, ref);
                    }
                  },
                  itemBuilder: (BuildContext context) => [
                    PopupMenuItem(
                      value: 'logout',
                      child: Row(
                        children: [
                          Icon(Icons.logout, color: Colors.red[300]),
                          SizedBox(width: 8),
                          Text('Logout'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    ProfileInfoCard(
                      icon: Icons.email,
                      title: 'Email',
                      value: userEmail,
                    ),
                    SizedBox(height: 16),
                    ProfileInfoCard(
                      icon: Icons.calendar_today,
                      title: 'Date of Birth',
                      value: dateOfBirth,
                    ),
                    SizedBox(height: 16),
                    ProfileInfoCard(
                      icon: Icons.person_outline,
                      title: 'Gender',
                      value: userGender == 'male' 
                          ? 'Male'
                          : userGender == 'female' 
                              ? 'Female' 
                              : 'Not specified',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
