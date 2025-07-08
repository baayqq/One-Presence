import 'package:flutter/material.dart';
import 'package:onepresence/model/profile_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:onepresence/auth/login.dart';

class DetailProfile extends StatelessWidget {
  final ProfileData profile;
  const DetailProfile({Key? key, required this.profile}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Profil')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      profile.profilePhoto != null &&
                              profile.profilePhoto!.isNotEmpty
                          ? CircleAvatar(
                            radius: 40,
                            backgroundImage:
                                profile.profilePhoto!.startsWith('http')
                                    ? NetworkImage(profile.profilePhoto!)
                                    : NetworkImage(
                                      'https://appabsensi.mobileprojp.com/storage/${profile.profilePhoto}',
                                    ),
                          )
                          : const CircleAvatar(
                            radius: 40,
                            child: Icon(
                              Icons.account_circle,
                              size: 60,
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
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Email: ${profile.email}',
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Gender: ${profile.jenisKelamin}',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Batch: ${profile.batchKe}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Pelatihan: ${profile.trainingTitle}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  if (profile.batch != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      'Periode Batch: ${profile.batch!.startDate} s/d ${profile.batch!.endDate}',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                  if (profile.training != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      'Judul Training: ${profile.training!.title}',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
