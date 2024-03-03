import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/addpage.dart';
import 'package:http/http.dart' as http;

class Todolistpage extends StatefulWidget {
  const Todolistpage({super.key});

  @override
  State<Todolistpage> createState() => _TodolistpageState();
}

class _TodolistpageState extends State<Todolistpage> {
  bool isloading = true;
  List items = [];
  @override
  void initState() {
    super.initState();
    fetchtodo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: const Text(
          "Todo app",
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: Visibility(
        visible: isloading,
        replacement: RefreshIndicator(
          onRefresh: fetchtodo,
          child: Visibility(
            visible: items.isNotEmpty,
            replacement: const Center(
              child: Text(
                "NO ITEM HERE ",
                style: TextStyle(fontSize: 18),
              ),
            ),
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index] as Map;
                final id = item['_id'] as String;
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                        child: Text(
                      "${index + 1}",
                    )),
                    title: Text(item['title']),
                    subtitle: Text(item['description']),
                    trailing: PopupMenuButton(onSelected: (value) {
                      if (value == 'edit') {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => Addpage(
                                  todo: item,
                                )));
                      } else if (value == 'delete') {
                        deletebyid(id);
                      }
                    }, itemBuilder: (context) {
                      return [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Text("Edit"),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text("delete"),
                        ),
                      ];
                    }),
                  ),
                );
              },
            ),
          ),
        ),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: navigatetoaddtopage,
        label: const Text(
          "Add",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.red,
      ),
    );
  }

  Future<void> navigatetoaddtopage() async {
    final route = MaterialPageRoute(
      builder: (context) => const Addpage(),
    );
    await Navigator.push(context, route);
    setState(() {
      isloading = true;
    });
    fetchtodo();
  }

  Future<void> deletebyid(String id) async {
    final url = "https://api.nstack.in/v1/todos/$id";
    final uri = Uri.parse(url);
    final response = await http.delete(uri);
    if (response.statusCode == 200) {
      final filtred = items.where((element) => element['_id'] != id).toList();
      setState(() {
        items = filtred;
      });
    } else {
      errormessaenger("deletion failed");
    }
  }

  Future<void> fetchtodo() async {
    const url = "https://api.nstack.in/v1/todos?page=1&limit=15";
    final uri = Uri.parse(url);
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final result = json['items'];
      print(result);
      setState(() {
        items = result;
      });
    }
    setState(() {
      isloading = false;
    });
  }

  void errormessaenger(String message) {
    if (mounted) {
      final snackBar = SnackBar(content: Text(message));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }
}
