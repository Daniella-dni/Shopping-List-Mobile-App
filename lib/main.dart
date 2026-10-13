import 'package:flutter/material.dart';

void main() {
  runApp(const ShoppingListApp());
}

/// Root application widget
class ShoppingListApp extends StatelessWidget {
  const ShoppingListApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shopping List+',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const ShoppingListScreen(),
    );
  }
}

/// Data model representing an item on the shopping list
class Item {
  // 'name' is mutable (non-final) so it can be edited on the DetailsScreen
  String name;
  // Starting quantity is 1
  int quantity;
  // Bought status for strikethrough styling
  bool isBought;
  // Details note (e.g. 'the 1 litre bottle')
  String note;
  // Category ('Food', 'Drinks', 'Home')
  String category;

  Item({
    required this.name,
    this.quantity = 1,
    this.isBought = false,
    this.note = '',
    this.category = 'Food',
  });
}

/// Main Shopping List Screen
class ShoppingListScreen extends StatefulWidget {
  const ShoppingListScreen({super.key});

  @override
  State<ShoppingListScreen> createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends State<ShoppingListScreen> {
  final TextEditingController _itemController = TextEditingController();

  // Initial starter items
  final List<Item> items = [
    Item(name: 'Milk', category: 'Drinks'),
    Item(name: 'Bread', category: 'Food'),
    Item(name: 'Rice', category: 'Food'),
  ];

  // Current active status filter: 'All', 'To buy', or 'Bought'
  String filter = 'All';

  // Current active category filter: 'All', 'Food', 'Drinks', 'Home'
  String categoryFilter = 'All';

  // Sorting flag: Sort A to Z alphabetically
  bool isSortedAlphabetical = false;

  @override
  void dispose() {
    _itemController.dispose();
    super.dispose();
  }

  /// Adds a new item or increments quantity if duplicate exists
  void _addItem() {
    final text = _itemController.text.trim();

    // Validate empty input
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Type an item first')),
      );
      return;
    }

    // Part 3: Duplicate detection (case-insensitive & whitespace-trimmed)
    final matching = items.where(
      (item) => item.name.trim().toLowerCase() == text.toLowerCase(),
    );

    if (matching.isNotEmpty) {
      final existingItem = matching.first;
      setState(() {
        existingItem.quantity++;
      });
      _itemController.clear();

      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${existingItem.name} is already on the list: now ×${existingItem.quantity}',
          ),
        ),
      );
      return;
    }

    // Add new item (defaults to currently selected category filter if specific, else 'Food')
    final defaultCat = categoryFilter == 'All' ? 'Food' : categoryFilter;
    setState(() {
      items.add(Item(name: text, category: defaultCat));
    });
    _itemController.clear();
  }

  /// Deletes an item and shows an Undo SnackBar
  void _deleteItem(Item item) {
    // Find index in master list BEFORE removing to support exact Undo placement
    final originalIndex = items.indexOf(item);

    setState(() {
      items.remove(item);
    });

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${item.name} removed'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            setState(() {
              items.insert(originalIndex, item);
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 1. Filter by Category (if not 'All')
    Iterable<Item> base = items;
    if (categoryFilter != 'All') {
      base = base.where((i) => i.category == categoryFilter);
    }

    // 2. Separate into Unbought and Bought (Part 5: bought items always at bottom)
    List<Item> unbought = base.where((i) => !i.isBought).toList();
    List<Item> bought = base.where((i) => i.isBought).toList();

    // 3. Sort alphabetically (A to Z) within each group if sort is active
    if (isSortedAlphabetical) {
      unbought.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      bought.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    }

    // 4. Filter by Status ('All', 'To buy', 'Bought')
    List<Item> shown;
    if (filter == 'All') {
      // Bought items always displayed at the bottom
      shown = [...unbought, ...bought];
    } else if (filter == 'To buy') {
      shown = unbought;
    } else if (filter == 'Bought') {
      shown = bought;
    } else {
      shown = base.toList();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping List+'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        centerTitle: true,
        actions: [
          // Push further: Sort A to Z button
          IconButton(
            icon: Icon(
              isSortedAlphabetical ? Icons.sort_by_alpha : Icons.sort,
              color: isSortedAlphabetical ? Theme.of(context).colorScheme.primary : null,
            ),
            tooltip: isSortedAlphabetical ? 'Sorted A to Z (tap to reset)' : 'Sort A to Z',
            onPressed: () {
              setState(() {
                isSortedAlphabetical = !isSortedAlphabetical;
              });
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  duration: const Duration(milliseconds: 1200),
                  content: Text(
                    isSortedAlphabetical ? 'List sorted A to Z' : 'Sort reset to default order',
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Input Section
          Padding(
            padding: const EdgeInsets.fromLTRB(12.0, 12.0, 12.0, 6.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _itemController,
                    decoration: const InputDecoration(
                      hintText: 'Add an item...',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                    ),
                    onSubmitted: (_) => _addItem(),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: _addItem,
                  icon: const Icon(Icons.add),
                  label: const Text('Add'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Status Filter Chips (All, To buy, Bought) + Sort Indicator
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Row(
              children: [
                const Text('Status: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                ChoiceChip(
                  label: const Text('All'),
                  selected: filter == 'All',
                  onSelected: (selected) {
                    if (selected) setState(() => filter = 'All');
                  },
                ),
                const SizedBox(width: 6),
                ChoiceChip(
                  label: const Text('To buy'),
                  selected: filter == 'To buy',
                  onSelected: (selected) {
                    if (selected) setState(() => filter = 'To buy');
                  },
                ),
                const SizedBox(width: 6),
                ChoiceChip(
                  label: const Text('Bought'),
                  selected: filter == 'Bought',
                  onSelected: (selected) {
                    if (selected) setState(() => filter = 'Bought');
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 4),

          // Category Filter Chips (All, Food, Drinks, Home)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Row(
              children: [
                const Text('Category: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                ...['All', 'Food', 'Drinks', 'Home'].map((cat) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 6.0),
                    child: ChoiceChip(
                      label: Text(cat),
                      selected: categoryFilter == cat,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() => categoryFilter = cat);
                        }
                      },
                    ),
                  );
                }).toList(),
              ],
            ),
          ),

          const Divider(height: 16),

          // List / Empty State
          Expanded(
            child: Builder(
              builder: (context) {
                // Part 1: Truly empty master list
                if (items.isEmpty) {
                  return const Center(
                    child: Text(
                      'Your list is empty',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  );
                }

                // Part 5: Filter has nothing to show
                if (shown.isEmpty) {
                  return const Center(
                    child: Text(
                      'Nothing here',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  );
                }

                // Render list
                return ListView.builder(
                  itemCount: shown.length,
                  itemBuilder: (context, index) {
                    final item = shown[index];
                    return ListTile(
                      // Tap to toggle bought status
                      onTap: () {
                        setState(() {
                          item.isBought = !item.isBought;
                        });
                      },
                      // Part 6: Long press opens DetailsScreen
                      onLongPress: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetailsScreen(item: item),
                          ),
                        ).then((_) {
                          // Redraw list when returning to reflect any saved changes
                          setState(() {});
                        });
                      },
                      title: Text(
                        item.name,
                        style: TextStyle(
                          fontSize: 16,
                          decoration:
                              item.isBought ? TextDecoration.lineThrough : null,
                          color:
                              item.isBought ? Colors.grey : Colors.black87,
                        ),
                      ),
                      // Part 6: Subtitle shows Category · Note
                      subtitle: Text(
                        item.note.isNotEmpty
                            ? '${item.category} · ${item.note}'
                            : item.category,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 13,
                        ),
                      ),
                      // Part 2: Trailing Row (- qty + bin)
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min, // Trap fix: do not expand full width
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove, size: 20),
                            tooltip: 'Decrease quantity',
                            onPressed: () {
                              setState(() {
                                // Rule: Never drops below 1
                                if (item.quantity > 1) {
                                  item.quantity--;
                                }
                              });
                            },
                          ),
                          Text(
                            '${item.quantity}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add, size: 20),
                            tooltip: 'Increase quantity',
                            onPressed: () {
                              setState(() {
                                item.quantity++;
                              });
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline,
                                color: Colors.redAccent),
                            tooltip: 'Delete item',
                            onPressed: () => _deleteItem(item),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Part 6: Item Details Screen
class DetailsScreen extends StatefulWidget {
  final Item item;

  const DetailsScreen({super.key, required this.item});

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  late TextEditingController _nameController;
  late TextEditingController _noteController;
  late String _category;

  final List<String> categories = const ['Food', 'Drinks', 'Home'];

  @override
  void initState() {
    super.initState();
    // Pre-populate fields with existing item values
    _nameController = TextEditingController(text: widget.item.name);
    _noteController = TextEditingController(text: widget.item.note);
    _category = widget.item.category.isNotEmpty ? widget.item.category : 'Food';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _saveDetails() {
    final updatedName = _nameController.text.trim();
    // Validate that name is not empty
    if (updatedName.isEmpty) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name cannot be empty')),
      );
      return;
    }

    // Apply updates directly to the mutable item instance
    widget.item.name = updatedName;
    widget.item.note = _noteController.text.trim();
    widget.item.category = _category;

    // Return to main list
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Item details'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Item Name field
            const Text(
              'Name',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                hintText: 'Item name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            // Item Note field
            const Text(
              'Note',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _noteController,
              decoration: const InputDecoration(
                hintText: 'e.g. the 1 litre bottle, 1 kg bag',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            // Category Selection Chips
            const Text(
              'Category',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: categories.map((cat) {
                return ChoiceChip(
                  label: Text(cat),
                  selected: _category == cat,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _category = cat;
                      });
                    }
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 32),

            // Save Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _saveDetails,
                child: const Text('Save', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
