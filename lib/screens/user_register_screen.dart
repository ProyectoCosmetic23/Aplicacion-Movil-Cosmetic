import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class UserRegisterScreen extends StatefulWidget {
  const UserRegisterScreen({super.key});

  @override
  State<UserRegisterScreen> createState() => _UserRegisterScreenState();
}

class _UserRegisterScreenState extends State<UserRegisterScreen> {
  TextEditingController nameController =  TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  String rol = "Cliente";

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
   bool _isVisible = true;

  final String url= 'https://apilibros-iaeu.onrender.com/api/users';

 void apiLogin() async {
  final email = emailController.text;
  final password = passwordController.text;
  final name = nameController.text;

  final body = jsonEncode({
    'nombre': name,
    'correo': email,
    'contrasena': password,
    'rol': rol
  });
  final response = await http.post(
    Uri.parse(url),
    headers: {
      'Content-Type': 'application/json; charset=utf-8',
    },
    body: body,
  );

  if (mounted) {
    if (response.statusCode == 201) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Bienvenido', style: TextStyle(color: Color.fromRGBO(235, 234, 236, 1),),),
        backgroundColor: Color.fromRGBO(102, 51, 153, 1),
        duration: const Duration(seconds: 1),
      
      ));
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('credenciales invalidas', style: TextStyle(color: Color.fromRGBO(235, 234, 236, 1),),),
         backgroundColor: Color.fromRGBO(102, 51, 153, 1),
        duration: const Duration(seconds: 1),
       
      ));
    }
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre',
                  hintText: 'Ingrese su nombre',
                  prefixIcon: Icon(Icons.people_outlined),
                ),
              ),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Correo Electrónico',
                  hintText: 'Ingrese su correo',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
              ),
              TextField(
                controller: passwordController,
                decoration: InputDecoration(
                  labelText: 'Ingrese su contraseña',
                  hintText: 'Ingrese su correo',
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(onPressed: (){
                    setState(() {
                      _isVisible = !_isVisible;
                    });
                  },
                  icon: _isVisible ? const Icon(Icons.visibility) : const Icon(Icons.visibility_off),)
                  
                ),
                obscureText: _isVisible,
              ),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: () {
                apiLogin();
                Navigator.pop(context);
              }, child: const Text('Registrarse')),
              TextButton(onPressed: () {
              
                Navigator.pop(context);
              }, child: const Text('Cancelar', style: TextStyle(color: Colors.red),))

            ],
          )
        ),
      ),

    );
  }
}