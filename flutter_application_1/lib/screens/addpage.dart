import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Addpage extends StatefulWidget {
  final Map? todo;
  const Addpage({super.key, this.todo});

  @override
  State<Addpage> createState() => _AddpageState();
}

class _AddpageState extends State<Addpage> {
  TextEditingController titlecontroller = TextEditingController();
  TextEditingController descrptioncontroller = TextEditingController();
  bool isedit = true;

  @override
  void initState() {
    super.initState();
    final todo = widget.todo;
    if (todo != null) {
      isedit = true;
      final title = todo['title'];
      final description = todo['description'];
      titlecontroller.text = title;
      descrptioncontroller.text = description;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: Text(
          isedit ? 'add todo ' : 'edit todo',
          style: const TextStyle(color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextField(
            controller: titlecontroller,
            decoration: const InputDecoration(hintText: "Title"),
          ),
          const SizedBox(
            height: 20,
          ),
          TextField(
            controller: descrptioncontroller,
            decoration: const InputDecoration(hintText: "Description"),
            keyboardType: TextInputType.multiline,
            minLines: 5,
            maxLines: 8,
          ),
          const SizedBox(
            height: 20,
          ),
          ElevatedButton(
              onPressed: isedit ? submitdata : updatedata,
              child: Text(isedit ? 'submit' : 'update'))
        ],
      ),
    );
  }

  Future<void> updatedata() async {
    final todo = widget.todo;
    if (todo == null) {
      print("you canmnot call do not  updated without todo data");
      return;
    }
    final id = todo['_id'];
    final title = titlecontroller.text;
    final descrption = descrptioncontroller.text;
    final body = {
      "title": title,
      "description": descrption,
      "is_completed": false
    };
    //submit updated daTA TO SERVER
    final url = 'https://api.nstack.in/v1/todos/$id';
    final uri = Uri.parse(url);
    final response = await http.put(uri,
        body: jsonEncode(body), headers: {'Content-Type': 'application/json'});
    if (response.statusCode == 200) {
      // titlecontroller.text = "";
      // descrptioncontroller.text = "";
      // print("Creation success");
      successmessaenger("updation success");
    } else {
      // print("creation failed");
      errormessaenger("updation failed");
      // print(response.body);
    }
  }

  Future<void> submitdata() async {
    // get the data from form
    final title = titlecontroller.text;
    final descrption = descrptioncontroller.text;
    final body = {
      "title": title,
      "description": descrption,
      "is_completed": false
    };
    //submit data to server
    const url = 'https://api.nstack.in/v1/todos';
    final uri = Uri.parse(url);
    final response = await http.post(uri,
        body: jsonEncode(body), headers: {'Content-Type': 'application/json'});

    //show success or fail message based on status
    if (response.statusCode == 201) {
      titlecontroller.text = "";
      descrptioncontroller.text = "";
      // print("Creation success");
      successmessaenger("Creation success");
    } else {
      // print("creation failed");
      errormessaenger("Creation failed");
      // print(response.body);
    }
  }

  void successmessaenger(String message) {
    final snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void errormessaenger(String message) {
    final snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
