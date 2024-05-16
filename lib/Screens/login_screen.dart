import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;

class LoginScreen extends StatelessWidget {
  final bool fromRegister;

  const LoginScreen({super.key, required this.fromRegister});

  @override
  Widget build(BuildContext context) {
    if (fromRegister) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Akun berhasil dibuat, silahkah masuk")));
      });
    }
    return SafeArea(
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        body: Stack(
          alignment: Alignment.topCenter,
          children: [
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
                  child: Center(
                    child: Text("Selamat datang kembali!",
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 28,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onPrimaryContainer)),
                  ),
                ),
                const Image(
                  fit: BoxFit.cover,
                  image: AssetImage("assets/login.png"),
                ),
              ],
            ),
            const LoginForm(),
          ],
        ),
      ),
    );
  }
}

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  bool isLoading = false;
  bool showPassword = false;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.background,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(32),
            topRight: Radius.circular(32),
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const OnSlideIndicator(),
              const SizedBox(height: 24),
              Text(
                textAlign: TextAlign.left,
                "Masuk untuk mengakses riwayat Anda dan melihat karya terbaru",
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: const Color.fromRGBO(147, 143, 150, 1)),
              ),
              const SizedBox(height: 24),
              TextFormField(
                decoration: const InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20))),
                    labelText: "Email",
                    prefixIcon: Icon(Icons.email_outlined)),
                controller: emailController,
              ),
              const SizedBox(height: 10),
              TextFormField(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20))),
                  labelText: "Password",
                  prefixIcon: Icon(Icons.vpn_key_outlined),
                ),
                controller: passwordController,
                obscureText: !showPassword,
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Checkbox(
                      value: showPassword,
                      onChanged: (value) => {
                            setState(() {
                              showPassword = value!;
                            })
                          }),
                  const Text(
                    "Lihat password",
                  )
                ],
              ),
              isLoading
                  ? const CircularProgressIndicator()
                  : FilledButton(
                      onPressed: () async {
                        setState(() {
                          isLoading = true;
                        });
                        await dotenv.load(fileName: ".env");
                        http.Response? response;
                        try {
                          response = await http.post(
                            Uri.parse('${dotenv.env["API_URL"]}/auth/login'),
                            body: jsonEncode(<String, String>{
                              'email': emailController.text,
                              'password': passwordController.text
                            }),
                            headers: <String, String>{
                              'Content-Type': 'application/json; charset=UTF-8',
                              // preflight cors
                            },
                          );
                        } catch (e) {
                          setState(() {
                            isLoading = false;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      "Terjadi kesalahan, coba lagi nanti")));
                          return;
                        }

                        setState(() {
                          isLoading = false;
                        });
                        if (response.statusCode != 200) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text("Email atau password salah")));
                          return;
                        }
                        var userId = Cookie.fromSetCookieValue(
                                jsonDecode(response.body)["cookies"])
                            .value;
                        const storage = FlutterSecureStorage();
                        await storage.write(key: 'user_id', value: userId);
                        var readedUserId = await storage.read(key: 'user_id');
                        if (readedUserId != null) {
                          context.go('/explore');
                          if (!mounted) Navigator.of(context).pop();
                        }
                      },
                      style: FilledButton.styleFrom(
                        fixedSize: const Size(double.maxFinite, 40),
                      ),
                      child: const Text('Masuk')),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Belum mempunyai akun?',
                      style: Theme.of(context).textTheme.labelSmall),
                  TextButton(
                    onPressed: () {
                      context.go('/create-account');
                    },
                    style: TextButton.styleFrom(
                      textStyle: Theme.of(context).textTheme.labelSmall,
                    ),
                    child: const Text('Buat akun'),
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              Center(
                child: Text(
                  "Dengan melanjutkan berarti Anda setuju dengan persyaratan yang berlaku.",
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: const Color.fromRGBO(147, 143, 150, 1),
                      fontSize: 10),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class OnSlideIndicator extends StatelessWidget {
  const OnSlideIndicator({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 6,
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }
}
