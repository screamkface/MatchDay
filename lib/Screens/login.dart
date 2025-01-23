import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Importa Firebase Auth
import 'package:match_day/Admin/admin_home.dart';
import 'package:match_day/Providers/authDaoProvider.dart';
import 'package:match_day/Screens/register.dart';
import 'package:match_day/Screens/reset.dart';
import 'package:match_day/User/selezionaCampo.dart';
import 'package:match_day/components/custom_snackbar.dart';
import 'package:provider/provider.dart'; // Assicurati di importare il tuo CustomSnackbar
import 'package:shared_preferences/shared_preferences.dart'; // Aggiungi SharedPreferences

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _rememberMe = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  // Funzione per salvare le credenziali nelle SharedPreferences
  Future<void> _saveUserCredentials(
      String email, String password, String userId, String role) async {
    final prefs = await SharedPreferences.getInstance();
    if (_rememberMe) {
      // Salva solo se il checkbox è selezionato
      await prefs.setString('userId', userId); // Salva l'ID dell'utente
      await prefs.setString('email', email); // Salva l'email
      await prefs.setString('password',
          password); // Salva la password (NB: Non è sicuro salvare la password così)
      await prefs.setString('role', role); // Salva il ruolo dell'utente
      await prefs.setBool('isLoggedIn', true); // Indica che l'utente è loggato
    } else {
      await prefs.remove(
          'email'); // Rimuovi le credenziali se "Ricordami" non è selezionato
      await prefs.remove('password');
      await prefs.setBool('isLoggedIn', false);
    }
  }

  // Funzione per controllare se l'utente è già loggato
  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    if (isLoggedIn) {
      final String? email = prefs.getString('email');
      final String? password = prefs.getString('password');
      if (email != null && password != null) {
        try {
          final authProvider =
              Provider.of<AuthDaoProvider>(context, listen: false);
          UserCredential? userCredential =
              await authProvider.signInCred(email, password, context);

          if (userCredential != null) {
            final String role = await authProvider.getUserRole();
            await _saveUserCredentials(
                email, password, userCredential.user!.uid, role);

            // Esegui la navigazione solo se non è già in corso
            if (!Navigator.of(context).canPop()) {
              if (role == 'admin') {
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (context) => AdminHomePage(),
                ));
              } else {
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (context) => CampoSelectionPage(),
                ));
              }
            }
          }
        } catch (e) {
          CustomSnackbar.show(context, "Errore durante il login automatico.");
        }
      }
    }
  }

  // Funzione di login
  Future<void> _signIn() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthDaoProvider>(context, listen: false);
      try {
        // Esegui il login
        UserCredential? userCredential = await authProvider.signInCred(
          _emailController.text.trim(),
          _passwordController.text.trim(),
          context,
        );

        // Ottieni il ruolo dell'utente dal database
        final String role = await authProvider.getUserRole();

        // Dopo il login riuscito, salva le credenziali e il ruolo
        await _saveUserCredentials(
          _emailController.text.trim(),
          _passwordController.text.trim(),
          role,
          userCredential!.user!.uid,
        );

        // Naviga alla pagina principale o alla schermata desiderata in base al ruolo
        if (role == 'admin') {
          Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (context) => AdminHomePage(),
          ));
        } else {
          Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (context) => CampoSelectionPage(),
          ));
        }
      } catch (e) {
        // Gestisci gli errori di login
        CustomSnackbar.show(context, "Errore durante il login.");
        print(e);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    // Controlla se l'utente è già loggato all'avvio dell'app
    _checkLoginStatus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(20.0),
          margin: const EdgeInsets.symmetric(horizontal: 20.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.account_circle,
                  color: Theme.of(context).primaryColor,
                  size: 100,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Sign In',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  key: Key('email_input'),
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email,
                        color: Theme.of(context).primaryColor),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Per favore, inserisci un\'email.';
                    }
                    return null; // Validazione passata
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  key: Key('password_input'),
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon:
                        Icon(Icons.lock, color: Theme.of(context).primaryColor),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Theme.of(context).primaryColor,
                      ),
                      onPressed: _togglePasswordVisibility,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  obscureText: _obscurePassword,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Per favore, inserisci una password.';
                    }
                    return null; // Validazione passata
                  },
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Checkbox(
                          value: _rememberMe,
                          onChanged: (value) {
                            setState(() {
                              _rememberMe = value!;
                            });
                          },
                        ),
                        const Text('Ricordami'),
                      ],
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const Reset()),
                        );
                      },
                      child: const Text(
                        'Ho dimenticato la password?',
                        style: TextStyle(
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  key: Key('submit_button'),
                  onPressed: _signIn,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Sign In'),
                ),
                const SizedBox(height: 10),
                TextButton(
                  key: Key('registrazione_button'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const Register()),
                    );
                  },
                  child: const Text(
                    "Non hai un account? Registrati",
                    style: TextStyle(
                      decoration: TextDecoration.underline,
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
