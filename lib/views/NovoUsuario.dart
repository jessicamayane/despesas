import 'package:FLUTTER_APPLICATION_3/main.dart';
import 'package:FLUTTER_APPLICATION_3/views/Home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

//import 'dart:convert';

//import 'package:http/http.dart' as http;

class NovoUsuario extends StatelessWidget {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Novo Usuario'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.transparent,
              ),
              child: Image.asset(
                'logo.png', // Substitua pelo caminho da sua imagem nos ativos
                fit: BoxFit.cover, // Ajuste o valor do fit conforme necessário
              ),
            ),
            SizedBox(height: 20),
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'), // Campo de email
            ),
            SizedBox(height: 10),
            TextFormField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(labelText: 'Senha'), // Campo de senha
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                AddUser(context);
                
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(
                  Colors.pink,
                ),
              ),
              child: Text(
                'Cadastrar',
                style: TextStyle(
                  color: Colors.black, // Texto em preto
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LoginPage(),
                    ));
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(
                  Colors.pink,
                ),
              ),
              child: Text(
                'Voltar ao Login',
                style: TextStyle(
                  color: Colors.black, // Texto em preto
                ),
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () {
                    // Ação ao pressionar o botão do Instagram
                  },
                  icon: SvgPicture.asset(
                    'Gmail_icon_2020.svg', // Substitua pelo caminho da imagem do Instagram
                    width: 30,
                    height: 30,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    // Ação ao pressionar o botão do Facebook
                  },
                  icon: SvgPicture.asset(
                    'facebook.svg', // Substitua pelo caminho da imagem do Facebook
                    width: 30,
                    height: 30,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    // Ação ao pressionar o botão do Gmail
                  },
                  icon: SvgPicture.asset(
                    'Instagram.svg', // Substitua pelo caminho da imagem do Gmail
                    width: 30,
                    height: 30,
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Future<void> AddUser(context) async {
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(userCredential.user?.uid)
          .set({
        'nome': _emailController.text,
      });

                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LoginPage(),
                    ));
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.message.toString()),
        backgroundColor: Colors.redAccent,
      ));
    }
  }
}
