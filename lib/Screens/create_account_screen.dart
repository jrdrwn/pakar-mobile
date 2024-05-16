import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;

class CreateAccountScreen extends StatelessWidget {
  const CreateAccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                    child: Text("Halo, sedikit lagi",
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
                  image: AssetImage("assets/create-account.png"),
                ),
              ],
            ),
            const CreateAccountForm(),
          ],
        ),
      ),
    );
  }
}

class CreateAccountForm extends StatefulWidget {
  const CreateAccountForm({super.key});

  @override
  State<CreateAccountForm> createState() => _CreateAccountFormState();
}

class _CreateAccountFormState extends State<CreateAccountForm> {
  bool showPassword = false;
  bool isLoading = false;

  final emailController = TextEditingController();
  final usernameController = TextEditingController();
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
                "Buat akun dan masuk untuk mengakses riwayat Anda dan melihat karya terbaru",
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
                    labelText: "Username",
                    prefixIcon: Icon(Icons.person_outline)),
                controller: usernameController,
              ),
              const SizedBox(height: 10),
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
                        var response = await http.post(
                          Uri.parse('${dotenv.env["API_URL"]}/auth/register'),
                          body: jsonEncode(<String, String>{
                            'email': emailController.text,
                            "username": usernameController.text,
                            'password': passwordController.text,
                            "first_name": "first",
                            "middle_name": "middle",
                            "last_name": "last"
                          }),
                          headers: <String, String>{
                            'Content-Type': 'application/json; charset=UTF-8',
                          },
                        );
                        setState(() {
                          isLoading = false;
                        });
                        if (response.statusCode != 200) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                              content: Text(
                                  "Data tersebut sudah ada atau data Anda salah")));
                          return;
                        }

                        // Navigator.push(
                        //     context,
                        //     MaterialPageRoute(
                        //       builder: (context) =>
                        //           const LoginScreen(fromRegister: true),
                        //     ));
                        context.go('/login?from_register=true');
                        if (!mounted) Navigator.of(context).pop();
                      },
                      style: FilledButton.styleFrom(
                        fixedSize: const Size(double.maxFinite, 40),
                      ),
                      child: const Text('Buat akun')),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Sudah mempunyai akun?',
                      style: Theme.of(context).textTheme.labelSmall),
                  TextButton(
                    onPressed: () {
                      context.go('/login?from_register=false');
                    },
                    style: TextButton.styleFrom(
                      textStyle: Theme.of(context).textTheme.labelSmall,
                    ),
                    child: const Text('Masuk'),
                  ),
                ],
              ),
              const SizedBox(
                height: 26,
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
