import 'package:FLUTTER_APPLICATION_3/views/Graph.dart';
import 'package:FLUTTER_APPLICATION_3/views/NovaDespesa.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class _HomePageState extends State<HomePage> {
  @override
  //HomePage createState() => HomePage();
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('App Financeiro'),
        ),
        body: Column(
          children: [
            CreditCardWidget(),
            SizedBox(height: 16.0),
            ExpenseButton(),
            SizedBox(height: 16.0),
            ExpenseButtonGrafico(),
            SizedBox(height: 16.0),
            TransactionList(),
          ],
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class TransactionList extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: StreamBuilder(
        stream: _firestore
            .collection('Despesas')
            .where('userId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          var documents = snapshot.data?.docs;

          return ListView.builder(
            itemCount: documents?.length,
            itemBuilder: (context, index) {
              var data = documents?[index].data();

              return Card(
                elevation: 5.0,
                margin: EdgeInsets.all(8.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: ListTile(
                  title: Text('Tipo: ${data?['tipo']}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Categoria: ${data?['categoria']}'),
                      Text(
                        'Valor: -R\$ ${data?['valor']}',
                        style: TextStyle(
                          color: Colors.red,
                        ),
                      ),
                      Text('Data: ${data?['data']}'),
                      Text('Método de Pagamento: ${data?['método_pagamento']}'),
                      Text('Nome: ${data?['nome']}'),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class CreditCardWidget extends StatefulWidget {
  @override
  _CreditCardWidgetState createState() => _CreditCardWidgetState();
}

//class _HomePageState extends State<HomePage> {
class _CreditCardWidgetState extends State<CreditCardWidget> {
  double saldolocal = 0.0;

  @override
  void initState() {
    super.initState();
    _atualizarSaldo(); // Chamando a função para obter e definir o saldo inicial
  }

  @override
  Widget build(BuildContext context) {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    //final saldo = snapshot.data ?? 0.0;
    return Card(
      elevation: 5.0,
      margin: EdgeInsets.all(8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Container(
        padding: EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.0),
          color: Colors.blue, // Cor de fundo do cartão
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(
                  Icons.credit_card,
                  color: Colors.white,
                ),
                Icon(
                  Icons.more_horiz,
                  color: Colors.white,
                ),
              ],
            ),
            SizedBox(height: 20.0),
            Text(
              '1234 5678 9012 3456',
              style: TextStyle(fontSize: 20.0, color: Colors.white),
            ),
            SizedBox(height: 12.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Validade: 12/25',
                  style: TextStyle(fontSize: 16.0, color: Colors.white),
                ),
                Row(
                  children: [
                    Image.asset(
                      'mastercard.png',
                      height: 30.0,
                      width: 50.0,
                    ),
                    SizedBox(width: 8.0),
                    Text(
                      'CVV: 123',
                      style: TextStyle(fontSize: 16.0, color: Colors.white),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 12.0),
            StreamBuilder<DocumentSnapshot>(
              stream: _firestore
                  .collection('Saldo')
                  .doc(FirebaseAuth.instance.currentUser?.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.active &&
                    snapshot.hasData) {
                  Map<String, dynamic>? userData =
                      snapshot.data?.data() as Map<String, dynamic>?;
                  if (userData != null) {
                    double saldobd = userData['valor'] ?? 0;
                    return Text('\$$saldobd',
                        style: TextStyle(fontSize: 16.0, color: Colors.white));
                  } else {
                    return Text('\$0',
                        style: Theme.of(context).textTheme.headline4);
                  }
                } else if (snapshot.hasError) {
                  return Text("Erro ao carregar os dados");
                }
                return CircularProgressIndicator(); // 8) toma
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _atualizarSaldo() async {
    try {
      double novoSaldo = await _obterSaldo();
      setState(() {
        saldolocal = novoSaldo;
      });
    } catch (e) {
      print('Erro ao obter saldo: $e');
    }
  }
}

class ExpenseButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => NovaDespesa(),
          ),
        );
      },
      child: Text('Cadastrar Despesa'),
    );
  }
}

class ExpenseButtonGrafico extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ChartScreen(),
          ),
        );
      },
      child: Text('Relatorio'),
    );
  }
}

Future<double> _obterSaldo() async {
  try {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('Saldo')
        .where('userId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      return await querySnapshot.docs.first.get('valor') ?? 0.0;
    } else {
      return 0.0;
    }
  } catch (e) {
    print('Erro ao obter saldo: $e');
    return 0.0;
  }
}
