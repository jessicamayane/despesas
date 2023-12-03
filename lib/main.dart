import 'package:FLUTTER_APPLICATION_3/views/Home.dart';
import 'package:FLUTTER_APPLICATION_3/views/NovoUsuario.dart';
import 'package:FLUTTER_APPLICATION_3/views/Saldo.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    MaterialApp(
      home: LoginPage(),
      routes: {
        '/home': (context) => HomePage(),
      },
    ),
  );
}

class LoginPage extends StatelessWidget {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
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
                login(context);
                //validateLogin(auth,_emailController,_passwordController);
                //Navigator.pushNamed(context, '/home');
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(
                  Colors.pink,
                ),
              ),
              child: Text(
                'Entrar',
                style: TextStyle(
                  color: Colors.black, // Texto em preto
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                //Navigator.pushNamed(context, '/home');
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NovoUsuario(),
                    ));
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

login(context) async {
  try {
    UserCredential userCredential = await _firebaseAuth.signInWithEmailAndPassword(
      email: _emailController.text,
      password: _passwordController.text,
    );

    if (userCredential != null) {
      double saldo = await _obterSaldo();

      if (saldo == 0.0) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => SaldoPage(),
          ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(),
          ),
        );
      }
    }
  } on FirebaseAuthException catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(e.message.toString()),
        backgroundColor: Colors.redAccent,
      ),
    );
  }
}

//   validateLogin(context, email, password) async {
//   await Firebase.initializeApp();
//   FirebaseAuth auth = FirebaseAuth.instance;
//   auth.signInWithEmailAndPassword(email: email, password: password).then(
//         (value){Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(
//             builder: (context) => HomePage(),
//           ),
//         );}
//       );
// }
  Future<double> _obterSaldo() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Saldo')
          .where('userId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.first.get('valor') ?? 0.0;
      } else {
        return 0.0;
      }
    } catch (e) {
      print('Erro ao obter saldo: $e');
      return 0.0;
    }
  }
}
