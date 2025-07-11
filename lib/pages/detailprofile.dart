import 'package:flutter/material.dart';
import 'package:onepresence/model/profile_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:onepresence/auth/login.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:onepresence/model/training_detail_model.dart';
import 'package:onepresence/api/absen_api.dart';

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

class DetailProfile extends StatefulWidget {
  final ProfileData profile;
  const DetailProfile({Key? key, required this.profile}) : super(key: key);

  @override
  State<DetailProfile> createState() => _DetailProfileState();
}

class _DetailProfileState extends State<DetailProfile> {
  Future<TrainingDetailResponse>? _trainingDetailFuture;

  @override
  void initState() {
    super.initState();
    if (widget.profile.training != null) {
      SharedPreferences.getInstance().then((prefs) {
        final token = prefs.getString('token') ?? '';
        setState(() {
          _trainingDetailFuture = fetchTrainingDetail(
            widget.profile.training!.id,
            token,
          );
        });
      });
    }
  }

  void _showTrainingDetailDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Detail Training'),
          content: FutureBuilder<TrainingDetailResponse>(
            future: _trainingDetailFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox(
                  height: 80,
                  child: Center(child: CircularProgressIndicator()),
                );
              } else if (snapshot.hasError) {
                String errorMsg = 'Gagal memuat detail training';
                final error = snapshot.error.toString();
                final match = RegExp(
                  r'"message"\s*:\s*"([^"]+)"',
                ).firstMatch(error);
                if (match != null) {
                  errorMsg = match.group(1)!;
                }
                return Text(
                  errorMsg,
                  style: const TextStyle(color: Colors.red),
                );
              } else if (snapshot.hasData && snapshot.data!.data != null) {
                final detail = snapshot.data!.data!;
                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('ID: ${detail.id}'),
                      const SizedBox(height: 8),
                      Text('Judul: ${detail.title}'),
                      const SizedBox(height: 8),
                      Text('Deskripsi: ${detail.description ?? '-'}'),
                      const SizedBox(height: 8),
                      Text(
                        'Jumlah Peserta: ${detail.participantCount?.toString() ?? '-'}',
                      ),
                      const SizedBox(height: 8),
                      Text('Standar: ${detail.standard ?? '-'}'),
                      const SizedBox(height: 8),
                      Text('Durasi: ${detail.duration ?? '-'}'),
                      const SizedBox(height: 8),
                      Text('Dibuat: ${detail.createdAt ?? '-'}'),
                      const SizedBox(height: 8),
                      Text('Diupdate: ${detail.updatedAt ?? '-'}'),
                      const SizedBox(height: 8),
                      Text(
                        'Units: ${(detail.units != null && detail.units!.isNotEmpty) ? detail.units!.length.toString() + ' item' : '-'}',
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Activities: ${(detail.activities != null && detail.activities!.isNotEmpty) ? detail.activities!.length.toString() + ' item' : '-'}',
                      ),
                    ],
                  ),
                );
              } else {
                return const Text('Detail training tidak tersedia');
              }
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Tutup'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = widget.profile;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Profil'),
        backgroundColor: Color(0xff468585),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Color(0xffffffff),
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
                  (profile.profilePhoto != null &&
                          profile.profilePhoto!.isNotEmpty)
                      ? Center(
                        child: CircleAvatar(
                          radius: 100,
                          backgroundColor: Colors.white,
                          backgroundImage:
                              base64ImageProvider(profile.profilePhoto!) ??
                              const AssetImage(
                                    'assets/images/default_profile.png',
                                  )
                                  as ImageProvider,
                        ),
                      )
                      : Center(
                        child: CircleAvatar(
                          radius: 80,
                          backgroundColor: Colors.white,
                          backgroundImage: const AssetImage(
                            'assets/images/default_profile.png',
                          ),
                        ),
                      ),
                  const SizedBox(height: 16),
                  // Ganti Column data profil menjadi ListTile dengan ikon
                  ListTile(
                    leading: Icon(Icons.person),
                    title: Text('Nama'),
                    subtitle: Text(profile.name ?? '-'),
                  ),
                  ListTile(
                    leading: Icon(Icons.email),
                    title: Text('Email'),
                    subtitle: Text(profile.email ?? '-'),
                  ),
                  ListTile(
                    leading: Icon(Icons.group),
                    title: Text('Batch'),
                    subtitle: Text(profile.batchKe?.toString() ?? '-'),
                  ),
                  ListTile(
                    leading: Icon(Icons.wc),
                    title: Text('Gender'),
                    subtitle: Text(profile.jenisKelamin ?? '-'),
                  ),
                  ListTile(
                    leading: Icon(Icons.school),
                    title: Text('Pelatihan'),
                    subtitle: Text(profile.trainingTitle ?? '-'),
                  ),
                  if (profile.batch != null) ...[
                    ListTile(
                      leading: Icon(Icons.date_range),
                      title: Text('Periode Batch'),
                      subtitle: Text(
                        '${profile.batch!.startDate} s/d ${profile.batch!.endDate}',
                      ),
                    ),
                  ],
                  if (profile.training != null) ...[
                    ListTile(
                      leading: Icon(Icons.book),
                      title: Text('Judul Training'),
                      subtitle: Text(profile.training!.title ?? '-'),
                      onTap: () {
                        _showTrainingDetailDialog(context);
                      },
                    ),
                    // FutureBuilder tetap di bawah
                    const SizedBox(height: 8),
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
