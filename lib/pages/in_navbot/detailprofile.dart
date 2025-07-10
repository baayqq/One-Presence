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
      _trainingDetailFuture = fetchTrainingDetail(widget.profile.training!.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = widget.profile;
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
                            backgroundColor: Colors.white,
                            backgroundImage: base64ImageProvider(
                              profile.profilePhoto,
                            ),
                            child: null,
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
                    const SizedBox(height: 16),
                    FutureBuilder<TrainingDetailResponse>(
                      future: _trainingDetailFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        } else if (snapshot.hasError) {
                          // Ambil hanya pesan 'message' dari error jika ada
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
                            style: TextStyle(color: Colors.red),
                          );
                        } else if (snapshot.hasData &&
                            snapshot.data!.data != null) {
                          final detail = snapshot.data!.data!;
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Deskripsi: ${detail.description}',
                                style: const TextStyle(fontSize: 16),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Tanggal: ${detail.startDate} s/d ${detail.endDate}',
                                style: const TextStyle(fontSize: 16),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Lokasi: ${detail.location}',
                                style: const TextStyle(fontSize: 16),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Mentor: ${detail.mentor}',
                                style: const TextStyle(fontSize: 16),
                              ),
                            ],
                          );
                        } else {
                          return const Text('Detail training tidak tersedia');
                        }
                      },
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
