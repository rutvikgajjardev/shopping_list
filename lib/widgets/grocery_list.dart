import 'package:flutter/material.dart';
import 'package:shopping_list/models/grocery_item.dart';
import 'package:shopping_list/widgets/new_item.dart';

class GrocaryList extends StatefulWidget {
  const GrocaryList({Key? key}) : super(key: key);

  @override
  State<GrocaryList> createState() => _GrocaryListState();
}

class _GrocaryListState extends State<GrocaryList> {
  final List<GroceryItem> _grocaryItems = [];
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

  @override
  Widget build(BuildContext context) {
    Widget content = const Center(
      child: Text('No items added yet.'),
    );

    if (_grocaryItems.isNotEmpty) {
      content = ListView.builder(
        itemCount: _grocaryItems.length,
        itemBuilder: (context, index) => ListTile(
          leading: Container(
            width: 30,
            height: 30,
            color: _grocaryItems[index].category.color,
          ),
          title: Text(_grocaryItems[index].name),
          trailing: Text(_grocaryItems[index].quantity.toString()),
        ),
      );
    }
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
        body: content);
  }
}
