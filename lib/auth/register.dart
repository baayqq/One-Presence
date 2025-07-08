import 'package:flutter/material.dart';
import 'package:onepresence/api/api_file.dart';
import 'package:onepresence/auth/login.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  bool isObsecure = true;
  final TextEditingController userController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController batchIdController = TextEditingController();
  final TextEditingController trainingIdController = TextEditingController();
  final TextEditingController genderController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  String? selectedGender;

  void handleRegist() async {
    if (formKey.currentState!.validate()) {
      final res = await UserService().registUser(
        userController.text,
        emailController.text,
        passwordController.text,
        genderController.text,
        batchIdController.text,
        trainingIdController.text,
      );

      if (res['data'] != null && res['data']['user'] != null) {
        final String name = res['data']['user']['name'];
        final String email = res['data']['user']['email'];

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('username', name);
        await prefs.setString('email', email);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Registrasi berhasil! Selamat datang, $name'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      } else if (res['errors'] != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Maaf: ${res['message']}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    userController.dispose();
    emailController.dispose();
    passwordController.dispose();
    batchIdController.dispose();
    trainingIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff468585),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 48),
              const Text(
                'Selamat Datang',
                style: TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 36),
              Padding(
                padding: const EdgeInsets.all(28.0),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xf2ffffff),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black,
                        blurRadius: 12,
                        offset: Offset(2, 2),
                      ),
                    ],
                  ),
                  child: Form(
                    key: formKey,
                    child: Column(
                      children: [
                        const Text(
                          'Buat akun',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: userController,
                          decoration: inputDecoration(
                            "Nama",
                            Icons.account_box,
                          ),
                          validator:
                              (value) =>
                                  value == null || value.isEmpty
                                      ? 'Nama wajib diisi'
                                      : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: emailController,
                          decoration: inputDecoration("Email", Icons.email),
                          validator:
                              (value) =>
                                  value == null || value.isEmpty
                                      ? 'Email wajib diisi'
                                      : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: passwordController,
                          obscureText: isObsecure,
                          decoration: inputDecoration(
                            "Password",
                            Icons.lock,
                          ).copyWith(
                            suffixIcon: IconButton(
                              icon: Icon(
                                isObsecure
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed:
                                  () =>
                                      setState(() => isObsecure = !isObsecure),
                            ),
                          ),
                          validator:
                              (value) =>
                                  value == null || value.isEmpty
                                      ? 'Password wajib diisi'
                                      : null,
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: selectedGender,
                          hint: const Text("Jenis Kelamin"),
                          items: const [
                            DropdownMenuItem(
                              value: "L",
                              child: Text("Laki-laki"),
                            ),
                            DropdownMenuItem(
                              value: "P",
                              child: Text("Perempuan"),
                            ),
                          ],
                          onChanged:
                              (value) => setState(() => selectedGender = value),
                          decoration: inputDecoration("", Icons.wc),
                          validator:
                              (value) =>
                                  value == null
                                      ? 'Jenis kelamin wajib dipilih'
                                      : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: batchIdController,
                          keyboardType: TextInputType.number,
                          decoration: inputDecoration(
                            "Batch ID",
                            Icons.confirmation_number,
                          ),
                          validator:
                              (value) =>
                                  value == null || value.isEmpty
                                      ? 'Batch ID wajib diisi'
                                      : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: trainingIdController,
                          keyboardType: TextInputType.number,
                          decoration: inputDecoration(
                            "Training ID",
                            Icons.school,
                          ),
                          validator:
                              (value) =>
                                  value == null || value.isEmpty
                                      ? 'Training ID wajib diisi'
                                      : null,
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              backgroundColor: Colors.yellow[600],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: handleRegist,
                            child: const Text(
                              'Register',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Sudah punya akun?",
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xff888888),
                              ),
                            ),
                            TextButton(
                              onPressed:
                                  () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const LoginPage(),
                                    ),
                                  ),
                              child: const Text(
                                "Login",
                                style: TextStyle(
                                  color: Color(0xff0D47A1),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }
}
