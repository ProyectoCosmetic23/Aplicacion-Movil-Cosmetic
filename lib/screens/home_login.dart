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
  double emailFieldHeight = 50;
  double passwordFieldHeight = 50;

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
      body: Center(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 400, // Reducir el ancho del contenedor del logo
                  height: 150, // Reducir la altura del contenedor del logo
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(50.0),
                    child: Image.asset(
                      'assets/img/logo.png',
                      fit: BoxFit.cover,
                      color: null,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: 300, // Mantener el ancho del campo de texto
                  height: emailFieldHeight,
                  child: TextFormField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: "Correo electrónico",
                      hintText: "Ingrese el correo electrónico",
                      enabledBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        borderSide: BorderSide(
                          color: Colors.grey,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        borderSide: BorderSide(
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      errorBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        borderSide: BorderSide(
                          color: Colors.red,
                        ),
                      ),
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        borderSide: BorderSide(
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        setState(() {
                          emailFieldHeight = 70; // Ajusta la altura del campo de texto si hay un error
                        });
                        return 'Por favor, ingrese el correo electrónico';
                      }
                      setState(() {
                        emailFieldHeight = 50; // Restablece la altura del campo de texto si no hay errores
                      });
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: 300, // Mantener el ancho del campo de texto
                  height: passwordFieldHeight,
                  child: TextFormField(
                    controller: passwordController,
                    obscureText: _isVisible,
                    decoration: InputDecoration(
                      labelText: "Contraseña",
                      hintText: "Ingrese la contraseña",
                      enabledBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        borderSide: BorderSide(
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      errorBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        borderSide: BorderSide(color: Colors.red),
                      ),
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        borderSide: BorderSide(color: Colors.grey),
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
                        setState(() {
                          passwordFieldHeight = 70; // Ajusta la altura del campo de texto si hay un error
                        });
                        return 'Por favor, ingrese la contraseña';
                      }
                      setState(() {
                        passwordFieldHeight = 50; // Restablece la altura del campo de texto si no hay errores
                      });
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
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  child: Container(
                    width: 105.0, // Mantener el ancho del botón
                    height: 50,
                    padding: const EdgeInsets.all(10.0),
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
      ),
    );
  }
}
