import 'dart:convert';

import 'package:consumir_api/screens/admin_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isVisible = true;

  final String url = 'https://cosmetic-api-yrcb.onrender.com/api/users/login';

  void apiLogin() async {
    final email = emailController.text;
    final password = passwordController.text;

    final body = jsonEncode({'email': email, 'password': password});
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json; charset=utf-8',
      },
      body: body,
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      final rol = responseData['id_role'];
      final pass = responseData['password'];
      final message = responseData['message'];

    
        if (password == pass) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            backgroundColor: Color.fromARGB(255, 197, 8, 8),
            content: const Text('Email o contraseña incorrectas'),
            duration: const Duration(seconds: 1),
          ));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Color.fromRGBO(102, 51, 153, 1),
              content: const Text('Bienvenido'),
              duration: const Duration(seconds: 1),
            ),
          );

          // Save the token locally
          final token = responseData['token'];
          final prefs = await SharedPreferences.getInstance();
          prefs.setString('token', token);

          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AdminScreen()),
          );

          emailController.clear();
          passwordController.clear();
        }
      
    } else if (response.statusCode == 401) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Color.fromARGB(255, 197, 8, 8),
        content: const Text('Email o contraseña incorrectas'),
        duration: const Duration(seconds: 1),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(50.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                height: 100,
              ),
              SizedBox(
                width: 300,
                height: 200,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(50.0),
                  child: Image.asset(
                    'assets/img/logo.png',
                    fit: BoxFit.cover,
                    color: null,
                    
                  ),
                ),
              ),
              const SizedBox(height: 50),
              SizedBox(
                width: 325.0,
                child: TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: "Correo electrónico",
                    hintText: "Ingrese el correo electrónico",
                    prefixIcon: Icon(Icons.email_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(30.0)),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, ingrese el correo electrónico';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 20.0),
              SizedBox(
                width: 325.0,
                child: TextFormField(
                  controller: passwordController,
                  obscureText: _isVisible,
                  decoration: InputDecoration(
                    labelText: "Contraseña",
                    hintText: "Ingrese la contraseña",
                    prefixIcon: const Icon(Icons.lock),
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(30.0)),
                    ),
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          _isVisible = !_isVisible;
                        });
                      },
                      icon: _isVisible
                          ? const Icon(Icons.visibility)
                          : const Icon(Icons.visibility_off),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, ingrese la contraseña';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    apiLogin();
                  }
                },
                style: ElevatedButton.styleFrom(
                  primary: const Color.fromRGBO(102, 51, 153, 1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                ),
                child: Container(
                  width: 150.0,
                  padding: const EdgeInsets.all(8.0),
                  child: const Center(
                    child: Text(
                      'Iniciar sesión',
                      style: TextStyle(
                        color: Color.fromRGBO(235, 234, 236, 1),
                      ),
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
}
