import 'package:flutter/material.dart';
import '../models/cloth_type.dart';
import '../models/cloth_field.dart';
import '../services/app_data.dart';
import 'cloth_type_form_screen.dart';

class ClothTypeListScreen extends StatefulWidget {
  const ClothTypeListScreen({super.key});

  @override
  State<ClothTypeListScreen> createState() => _ClothTypeListScreenState();
}

class _ClothTypeListScreenState extends State<ClothTypeListScreen> {
  final AppData _appData = AppData();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ValueListenableBuilder<List<ClothType>>(
        valueListenable: _appData.clothTypes,
        builder: (context, clothTypes, child) {
          if (clothTypes.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.design_services_outlined, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  const Text(
                    'No cloth templates yet',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap "+" to define a new garment template (e.g. Kurta, Suit).',
                    style: TextStyle(fontSize: 13, color: Colors.grey[400]),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: clothTypes.length,
            itemBuilder: (context, index) {
              final type = clothTypes[index];
              return _buildClothTypeCard(context, type);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const ClothTypeFormScreen(),
            ),
          );
        },
        tooltip: 'Add Garment Template',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildClothTypeCard(BuildContext context, ClothType type) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade100),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.architecture_rounded,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      type.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_rounded, size: 20),
                      tooltip: 'Edit Template',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ClothTypeFormScreen(clothType: type),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
                      tooltip: 'Delete Template',
                      onPressed: () => _showDeleteConfirmation(context, type),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${type.fields.length} measurement parameters configured:',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: type.fields.map((field) {
                final isInches = field.type == ClothFieldType.inches;
                return Chip(
                  avatar: Icon(
                    isInches ? Icons.square_foot_rounded : Icons.text_fields_rounded,
                    size: 14,
                    color: isInches ? Colors.amber[800] : Colors.blue[800],
                  ),
                  label: Text(
                    field.name,
                    style: const TextStyle(fontSize: 12),
                  ),
                  backgroundColor: isInches ? Colors.amber.shade50 : Colors.blue.shade50,
                  side: BorderSide.none,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, ClothType type) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Delete Garment Template?'),
          content: Text(
            'Are you sure you want to delete the ${type.name} template? Order items referencing this template will remain but cannot be edited using this blueprint.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              onPressed: () {
                _appData.deleteClothType(type.id);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Template ${type.name} deleted')),
                );
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}
