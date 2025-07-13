import 'package:flutter/material.dart';
import 'package:onepresence/model/profile_model.dart';
import 'package:onepresence/api/api_file.dart';
import 'package:onepresence/pages/in_navbot/profile.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';

class EditProfPage extends StatefulWidget {
  final ProfileData profile;
  const EditProfPage({Key? key, required this.profile}) : super(key: key);

  @override
  State<EditProfPage> createState() => _EditProfPageState();
}

class _EditProfPageState extends State<EditProfPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  bool _loading = false;
  bool _loadingPhoto = false; // Tambahan untuk upload foto
  String? _errorMsg;
  String? _profilePhotoUrl;
  File? _selectedPhoto;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile.name);
    _emailController = TextEditingController(text: widget.profile.email);
    _profilePhotoUrl = widget.profile.profilePhoto;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _errorMsg = null;
    });
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    try {
      final res = await UserService().editProfile(
        token,
        _nameController.text,
        _emailController.text,
      );
      if (res.data != null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res.message), backgroundColor: Colors.green),
        );
        Navigator.pop(context, true);
      } else if (res.errors != null) {
        setState(() {
          _errorMsg = res.message;
        });
      } else {
        setState(() {
          _errorMsg = res.message;
        });
      }
    } catch (e) {
      setState(() {
        _errorMsg = e.toString();
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _pickPhoto() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _selectedPhoto = File(picked.path);
      });
      await _uploadPhoto(picked.path);
    }
  }

  Future<void> _uploadPhoto(String filePath) async {
    setState(() {
      _loadingPhoto = true;
      _errorMsg = null;
    });
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    try {
      final res = await UserService().editProfilePhoto(token, filePath);
      if (res.profilePhoto != null) {
        setState(() {
          _profilePhotoUrl = res.profilePhoto;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res.message), backgroundColor: Colors.green),
        );
      } else {
        setState(() {
          _errorMsg = res.message;
        });
      }
    } catch (e) {
      setState(() {
        _errorMsg = e.toString();
      });
    } finally {
      setState(() {
        _loadingPhoto = false;
      });
    }
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profil'),
        backgroundColor: Color(0xff106D6B),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 48,
                      backgroundColor: Colors.teal, // AppColor.secondary
                      backgroundImage:
                          _selectedPhoto != null
                              ? FileImage(_selectedPhoto!)
                              : base64ImageProvider(_profilePhotoUrl),
                      child:
                          (_selectedPhoto == null &&
                                  (_profilePhotoUrl == null ||
                                      _profilePhotoUrl!.isEmpty))
                              ? Icon(
                                Icons.person,
                                size: 48,
                                color: Colors.grey, // AppColor.text
                              )
                              : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _loadingPhoto ? null : _pickPhoto,
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: Colors.teal, // AppColor.primary
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nama'),
                validator:
                    (v) => v == null || v.isEmpty ? 'Nama wajib diisi' : null,
              ),

              const SizedBox(height: 24),
              if (_errorMsg != null) ...[
                Text(_errorMsg!, style: const TextStyle(color: Colors.red)),
                const SizedBox(height: 12),
              ],
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed:
                      _loading ? null : _submit, // hanya disable saat _loading
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xff106D6B),
                  ),
                  child:
                      _loading
                          ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                          : const Text(
                            'Simpan',
                            style: TextStyle(color: Colors.white),
                          ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
