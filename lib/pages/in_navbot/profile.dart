import 'package:flutter/material.dart';
import 'package:onepresence/api/api_file.dart';
import 'package:onepresence/model/profile_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:onepresence/pages/in_navbot/detailprofile.dart';
import 'package:onepresence/auth/login.dart';
import 'package:onepresence/pages/editprof.dart';
import 'dart:convert';
import 'dart:typed_data';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Key _profileRefreshKey = UniqueKey();

  // Helper untuk handle base64, url, atau path
  ImageProvider? base64ImageProvider(String? base64String) {
    if (base64String == null || base64String.isEmpty) return null;
    if (base64String.startsWith('data:image')) {
      try {
        final bytes = base64Decode(base64String.split(',').last);
        return MemoryImage(bytes);
      } catch (_) {
        return null;
      }
    }
    if (base64String.startsWith('http')) {
      return NetworkImage(base64String);
    }
    return NetworkImage(
      'https://appabsensi.mobileprojp.com/public/$base64String',
    );
  }

  Future<ProfileResponse> fetchProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    return UserService().getProfile(token);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ProfileResponse>(
      key: _profileRefreshKey,
      future: fetchProfile(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(
            child: Text('Gagal memuat profil:  [${snapshot.error}]'),
          );
        } else if (snapshot.hasData) {
          if (snapshot.data!.data != null) {
            final profile = snapshot.data!.data!;
            print('Profile photo URL:  [${profile.profilePhoto}]');
            return SingleChildScrollView(
              child: Column(
                children: [
                  // Container biru dengan ikon/foto profil dan data singkat
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      vertical: 30,
                      horizontal: 24,
                    ),
                    decoration: const BoxDecoration(color: Color(0xff468585)),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        profile.profilePhoto != null &&
                                profile.profilePhoto!.isNotEmpty
                            ? CircleAvatar(
                              key: ValueKey(profile.profilePhoto),
                              radius: 48,
                              backgroundColor: Colors.white,
                              backgroundImage: base64ImageProvider(
                                profile.profilePhoto,
                              ),
                              child: null,
                            )
                            : CircleAvatar(
                              radius: 48,
                              backgroundColor: Colors.white,
                              child: Icon(
                                Icons.person,
                                size: 48,
                                color: Colors.grey,
                              ),
                            ),

                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Nama: ${profile.name}',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Email: ${profile.email}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Kelas: ${profile.trainingTitle}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Tombol menuju detail profil dan tombol lain di bawahnya
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        ListTile(
                          leading: Icon(Icons.info, color: Color(0xff468585)),
                          title: Text(
                            'Lihat Detail Profil',
                            style: TextStyle(fontSize: 16),
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) =>
                                        DetailProfile(profile: profile),
                              ),
                            );
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          tileColor: Colors.grey[100],
                        ),
                        const SizedBox(height: 8),
                        ListTile(
                          leading: Icon(Icons.edit, color: Color(0xff468585)),
                          title: Text(
                            'Edit Profile',
                            style: TextStyle(fontSize: 16),
                          ),
                          onTap: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => EditProfPage(profile: profile),
                              ),
                            );
                            if (result == true) {
                              setState(() {
                                _profileRefreshKey = UniqueKey();
                              }); // Paksa FutureBuilder rebuild
                            }
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          tileColor: Colors.grey[100],
                        ),
                        const SizedBox(height: 8),
                        ListTile(
                          leading: Icon(Icons.logout, color: Colors.red),
                          title: Text(
                            'Logout',
                            style: TextStyle(fontSize: 16, color: Colors.red),
                          ),
                          onTap: () async {
                            final prefs = await SharedPreferences.getInstance();
                            await prefs.remove('token');
                            if (context.mounted) {
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const LoginPage(),
                                ),
                                (route) => false,
                              );
                            }
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          tileColor: Colors.grey[100],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          } else if (snapshot.data!.message == "Unauthenticated.") {
            return const Center(
              child: Text('Sesi anda telah habis. Silakan login kembali.'),
            );
          } else {
            return const Center(child: Text('Data profil tidak ditemukan.'));
          }
        }
        return const SizedBox.shrink();
      },
    );
  }
}
