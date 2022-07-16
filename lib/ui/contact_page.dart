import 'dart:io';
import 'dart:async';
import 'package:contacts/helpers/contact_helper.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ContactPage extends StatefulWidget {
  final Contact? contact;

  const ContactPage({Key? key, this.contact}) : super(key: key);

  @override
  _ContactPageState createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  late Contact editedContact;
  bool userEdited = false;
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final nameFocus = FocusNode();
  final picker = ImagePicker();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.contact == null) {
      editedContact = Contact();
    } else {
      editedContact = Contact.fromMap(widget.contact!.toMap());
      nameController.text = editedContact.name!;
      emailController.text = editedContact.email ?? "";
      phoneController.text = editedContact.phone ?? "";
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: requestPop,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.purple,
          title: Text(editedContact.name ?? "Novo Contato"),
          centerTitle: true,
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            if (editedContact.name != null && editedContact.name!.isNotEmpty) {
              Navigator.pop(context, editedContact);
            } else {
              FocusScope.of(context).requestFocus(nameFocus);
            }
          },
          child: const Icon(Icons.save),
          backgroundColor: Colors.purple,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              GestureDetector(
                onTap: () {
                  picker.pickImage(source: ImageSource.camera).then((file) {
                    if (file == null) return;
                    setState(() {
                      editedContact.img = file.path;
                    });
                  });
                },
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: editedContact.img != null
                          ? FileImage(File(editedContact.img!))
                          : const AssetImage("lib/assets/images/shiro.jpg")
                              as ImageProvider,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              TextField(
                decoration: const InputDecoration(label: Text("Nome")),
                onChanged: (text) {
                  userEdited = true;
                  setState(() {
                    editedContact.name = text;
                  });
                },
                controller: nameController,
                focusNode: nameFocus,
              ),
              TextField(
                decoration: const InputDecoration(label: Text("Email")),
                onChanged: (text) {
                  userEdited = true;
                  editedContact.email = text;
                },
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
              ),
              TextField(
                decoration: const InputDecoration(label: Text("Phone")),
                onChanged: (text) {
                  userEdited = true;
                  editedContact.phone = text;
                },
                controller: phoneController,
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> requestPop() {
    if (userEdited) {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text("Descartar alterações?"),
              content: const Text("Se sair as alterações serão perdidas"),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text("Cancelar")),
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pop(context);
                    },
                    child: const Text("Sim"))
              ],
            );
          });
      return Future.value(false);
    } else {
      return Future.value(true);
    }
  }
}
