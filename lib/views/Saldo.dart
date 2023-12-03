import 'package:FLUTTER_APPLICATION_3/views/Graph.dart';
import 'package:FLUTTER_APPLICATION_3/views/NovaDespesa.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_svg/svg.dart';

class SaldoPage extends StatelessWidget {
  final _valorsaldoController = TextEditingController();
  FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final String userId = FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Saldo'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 10),
            TextFormField(
              controller: _valorsaldoController,
              decoration: InputDecoration(labelText: 'Saldo'), // Campo de Saldo
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                CadastrarSaldo(context);
                //login(context);
                //validateLogin(auth,_emailController,_passwordController);
                Navigator.pushNamed(context, '/home');
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(
                  Colors.pink,
                ),
              ),
              child: Text(
                'Avançar',
                style: TextStyle(
                  color: Colors.black, // Texto em preto
                ),
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

CadastrarSaldo(context) async {
  try {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    if (userId != null) {
      await FirebaseFirestore.instance.collection('Saldo').doc(userId).set({
        'userId': userId,
        'valor': double.parse(_valorsaldoController.text),
      });
    } else {
      throw FirebaseAuthException(
        code: 'user-not-found',
        message: 'Usuário não autenticado.',
      );
    }
  } on FirebaseAuthException catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(e.message.toString()),
      backgroundColor: Colors.redAccent,
    ));
  }
}
}
