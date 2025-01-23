import 'package:flutter/material.dart';
import 'package:match_day/Providers/authDaoProvider.dart';
import 'package:match_day/components/custom_snackbar.dart';
import 'package:provider/provider.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  bool _obscurePassword = true;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Inserisci una password'; // Messaggio per il test
    } else if (value.length < 6) {
      return 'La password deve avere almeno 6 caratteri'; // Messaggio per il test
    } else if (value.length < 4) {
      return 'La password è troppo corta'; // Messaggio per il test
    } else if (!RegExp(r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{6,}$')
        .hasMatch(value)) {
      return 'La password deve contenere almeno una lettera e un numero'; // Messaggio per il test
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Inserisci la tua email'; // Messaggio per il test
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Inserisci un\'email valida'; // Messaggio per il test
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Inserisci il tuo numero di telefono'; // Messaggio per il test
    }
    if (!RegExp(r'^\d{10}$').hasMatch(value)) {
      return 'Il numero di telefono deve avere esattamente 10 cifre'; // Messaggio per il test
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Registrazione"),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Registrazione',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    key: Key('nome_input'),
                    controller: _firstNameController,
                    decoration: InputDecoration(
                      labelText: 'Nome',
                      prefixIcon: Icon(Icons.person,
                          color: Theme.of(context).primaryColor),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Inserisci il tuo nome'; // Messaggio per il test
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    key: Key('cognome_input'),
                    controller: _lastNameController,
                    decoration: InputDecoration(
                      labelText: 'Cognome',
                      prefixIcon: Icon(Icons.person_outline,
                          color: Theme.of(context).primaryColor),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Inserisci il tuo cognome'; // Messaggio per il test
                      }
                      return null;
                    },
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
                      return _validateEmail(
                          value); // Passa direttamente il messaggio
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    key: Key('password_input'),
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: Icon(Icons.lock,
                          color: Theme.of(context).primaryColor),
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
                      return _validatePassword(
                          value); // Passa direttamente il messaggio
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    key: Key('telefono_input'),
                    controller: _phoneController,
                    decoration: InputDecoration(
                      labelText: 'Numero di telefono',
                      prefixIcon: Icon(Icons.phone,
                          color: Theme.of(context).primaryColor),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      return _validatePhone(
                          value); // Passa direttamente il messaggio
                    },
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    key: Key('submit_button'),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        final AuthDaoProvider authDaoProvider =
                            Provider.of<AuthDaoProvider>(context,
                                listen: false);
                        authDaoProvider.createAccount(
                            _emailController.text,
                            _passwordController.text,
                            'user', // Passa correttamente il ruolo qui
                            _phoneController
                                .text, // Passa il numero di telefono qui
                            _firstNameController.text,
                            _lastNameController.text,
                            context,
                            _formKey);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Registrazione Completata!')),
                        );
                      } else {
                        CustomSnackbar.show(
                            context, "Compila tutti i campi correttamente.");
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Registrati'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
