import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shopping_list/data/categories.dart';
import 'package:shopping_list/models/grocery_item.dart';
import 'package:shopping_list/widgets/new_item.dart';

class GrocaryList extends StatefulWidget {
  const GrocaryList({Key? key}) : super(key: key);

  @override
  State<GrocaryList> createState() => _GrocaryListState();
}

class _GrocaryListState extends State<GrocaryList> {
  List<GroceryItem> _grocaryItems = [];
  late Future<List<GroceryItem>> _loadedItems;

  @override
  void initState() {
    super.initState();
    _loadedItems = _loadItems();
  }

  Future<List<GroceryItem>> _loadItems() async {
    final url = Uri.https('shopping-list-b7336-default-rtdb.firebaseio.com',
        'shopping-list.json');

    {
      final response = await http.get(url);

      if (response.statusCode >= 404) {
        throw Exception(
            'Failed to fetch grocery items. Please try again letter.');
      }

      if (response.body == 'null') {
        return [];
      }
      final Map<String, dynamic> listData = json.decode(response.body);
      final List<GroceryItem> loadedItems = [];
      for (var item in listData.entries) {
        final category = categories.entries
            .firstWhere(
                (catItem) => catItem.value.title == item.value['category'])
            .value;
        loadedItems.add(
          GroceryItem(
            id: item.key,
            name: item.value['name'],
            quantity: item.value['quantity'],
            category: category,
          ),
        );
      }
      return loadedItems;
    }
  }

  void _addItem() async {
    final newItem = await Navigator.of(context).push<GroceryItem>(
      MaterialPageRoute(
        builder: (ctx) => const NewItem(),
      ),
    );
    if (newItem == null) {
      return;
    }
    setState(() {
      _grocaryItems.add(newItem);
    });
  }

  void _removeItem(GroceryItem item) async {
    final index = _grocaryItems.indexOf(item);
    setState(() {
      _grocaryItems.remove(item);
    });
    final url = Uri.https('shopping-list-b7336-default-rtdb.firebaseio.com',
        'shopping-list/${item.id}.json');
    final response = await http.delete(url);

    if (response.statusCode >= 400) {
      setState(() {
        _grocaryItems.insert(index, item);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Groceries'),
        actions: [
          IconButton(
            onPressed: _addItem,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: FutureBuilder(
        future: _loadedItems,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                snapshot.error.toString(),
              ),
            );
          }
          if (snapshot.data!.isEmpty) {
            return const Center(
              child: Text('No items added yet.'),
            );
          }
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) => Dismissible(
              onDismissed: ((direction) {
                _removeItem(snapshot.data![index]);
              }),
              key: ValueKey(snapshot.data![index].id),
              child: ListTile(
                leading: Container(
                  width: 30,
                  height: 30,
                  color: snapshot.data![index].category.color,
                ),
                title: Text(snapshot.data![index].name),
                trailing: Text(snapshot.data![index].quantity.toString()),
              ),
            ),
          );
        },
      ),
    );
  }
}
