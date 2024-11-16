import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:match_day/Models/campo.dart';
import 'package:match_day/User/campoSelected.dart';
import 'package:match_day/components/adminNavbar.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  int _selectedIndex = 0;

  // Fetch field names from Firestore
  Future<List<DocumentSnapshot>> fetchFields() async {
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('fields').get();
    return snapshot.docs;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: AdminNavbar(
        selectedIndex: _selectedIndex,
        onTabChange: (value) {
          setState(() {
            _selectedIndex = value;
          });
        },
      ),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Center(child: Text("Campi Disponibili")),
      ),
      body: FutureBuilder<List<DocumentSnapshot>>(
        future: fetchFields(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(
                child: Text('Errore nel caricamento dei campi'));
          } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            // Display the field names in a ListView
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final fieldDoc = snapshot.data![index];
                final fieldName = fieldDoc['nome'];
                final campoId = fieldDoc.id; // Aggiungi l'ID del campo

                final campo =
                    Campo(id: campoId, nome: fieldName, calendario: {});

                return GestureDetector(
                  onTap: () {
                    // Naviga verso la pagina CampoCalendarPage passando l'ID del campo
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CampoCalendar(
                          campo: campo,
                        ),
                      ),
                    );
                  },
                  child: Card(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    shape: RoundedRectangleBorder(
                      side: const BorderSide(),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 2,
                    child: ListTile(
                      title: Text(
                        fieldName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () {
                              _editField(context, fieldDoc);
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              _deleteField(fieldDoc.id);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          } else {
            return const Center(child: Text('Nessun campo disponibile'));
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddFieldDialog(
              context); // Apre il dialog per aggiungere un campo
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _editField(BuildContext context, DocumentSnapshot fieldDoc) {
    final TextEditingController controller =
        TextEditingController(text: fieldDoc['nome']);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Modifica Campo'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(labelText: 'Nome del Campo'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annulla'),
            ),
            ElevatedButton(
              onPressed: () async {
                // Aggiorna il campo su Firebase
                await FirebaseFirestore.instance
                    .collection('fields')
                    .doc(fieldDoc.id)
                    .update({'nome': controller.text});
                Navigator.pop(context);
                setState(() {
                  fetchFields(); // Ricarica i campi
                });
              },
              child: const Text('Salva'),
            ),
          ],
        );
      },
    );
  }

  // Function to delete a field
  void _deleteField(String fieldId) async {
    await FirebaseFirestore.instance.collection('fields').doc(fieldId).delete();
    setState(() {
      fetchFields(); // Ricarica i campi
    });
  }

  // Dialog per aggiungere un nuovo campo
  void _showAddFieldDialog(BuildContext context) {
    final TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Aggiungi nuovo campo'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Nome del Campo',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annulla'),
            ),
            ElevatedButton(
              onPressed: () async {
                // Aggiungi il campo su Firebase
                await FirebaseFirestore.instance
                    .collection('fields')
                    .add({'nome': controller.text});
                Navigator.pop(context);
                setState(() {
                  fetchFields(); // Ricarica i campi
                });
              },
              child: const Text('Aggiungi'),
            ),
          ],
        );
      },
    );
  }
}
