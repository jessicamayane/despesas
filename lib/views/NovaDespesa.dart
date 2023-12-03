import 'package:FLUTTER_APPLICATION_3/views/Home.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class NovaDespesa extends StatefulWidget {
  @override
  _NovaDespesaState createState() => _NovaDespesaState();
}

class _NovaDespesaState extends State<NovaDespesa> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ObjectRegistrationScreen(),
    );
  }
}

class ObjectRegistrationScreen extends StatefulWidget {
  @override
  _ObjectRegistrationScreenState createState() =>
      _ObjectRegistrationScreenState();
}

class _ObjectRegistrationScreenState extends State<ObjectRegistrationScreen> {
  final TextEditingController typeController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController categoryController = TextEditingController();
  final TextEditingController valueController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController paymentMethodController = TextEditingController();
  final String userId = FirebaseAuth.instance.currentUser?.uid ?? '';
  String? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    categoryController.text = 'Alimento';
    return Scaffold(
      appBar: AppBar(
        title: Text('Cadastro de despesa'),
        leading: IconButton(
          icon: Icon(Icons.home),
          onPressed: () {
            // Navegar de volta para a homePage
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => HomePage(),
                ));
          },
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: typeController,
              decoration: InputDecoration(labelText: 'Tipo'),
            ),
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Nome'),
            ),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedCategory = newValue ?? '';
                });
              },
              items: <String>['Alimento', 'Mobilidade']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              decoration: InputDecoration(labelText: 'Categoria'),
            ),
            TextField(
              controller: valueController,
              decoration: InputDecoration(labelText: 'Valor'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: dateController,
              decoration: InputDecoration(labelText: 'Data'),
            ),
            TextField(
              controller: paymentMethodController,
              decoration: InputDecoration(labelText: 'Método de Pagamento'),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                _cadastrarDespesa();
                _atualizarSaldo(valueController.text);

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HomePage(),
                  ),
                );
              },
              child: Text('Cadastrar'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _cadastrarDespesa() async {
    try {
      await FirebaseFirestore.instance.collection('Despesas').add({
        'userId': userId,
        'tipo': typeController.text,
        'data': dateController.text,
        'categoria': _selectedCategory,
        'valor': double.parse(valueController.text.replaceAll('R\$', '')),
        'método_pagamento': paymentMethodController.text,
        'nome': nameController.text
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao cadastrar despesa: $e')));
    }
  }

  Future<void> _atualizarSaldo(String valor) async {
    final valorDespesa = double.parse(valor.replaceAll('R\$', '').trim());

    final userCreditDoc =
        FirebaseFirestore.instance.collection('Saldo').doc(userId);

    FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot snapshot = await transaction.get(userCreditDoc);

      if (snapshot.exists && snapshot.data() != null) {
        final userData = snapshot.data() as Map<String, dynamic>;
        final saldoAtual = userData['valor'] as double? ?? 0.0;

        final novoSaldo = saldoAtual - valorDespesa;

        transaction.update(userCreditDoc, {'valor': novoSaldo});
      } else {
        print('Documento de crédito do usuário não encontrado.');
      }
    }).then((result) {
      //_valorController.clear();
    }).catchError((error) {
      print('Erro ao atualizar o saldo: $error');
    });
  }
}
