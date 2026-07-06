import 'package:flutter/material.dart';
import '../models/cloth_field.dart';
import '../models/cloth_type.dart';
import '../services/app_data.dart';

class ClothTypeFormScreen extends StatefulWidget {
  final ClothType? clothType;

  const ClothTypeFormScreen({super.key, this.clothType});

  @override
  State<ClothTypeFormScreen> createState() => _ClothTypeFormScreenState();
}

class _ClothTypeFormScreenState extends State<ClothTypeFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _appData = AppData();

  late TextEditingController _nameController;
  final List<ClothField> _fields = [];

  bool get isEditMode => widget.clothType != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.clothType?.name ?? '');
    if (isEditMode) {
      _fields.addAll(widget.clothType!.fields);
    } else {
      // Add a couple of default blank fields to guide the user
      _fields.add(ClothField(
        id: 'field_${DateTime.now().millisecondsSinceEpoch}_1',
        name: 'Length',
        type: ClothFieldType.inches,
        defaultValue: '30',
      ));
      _fields.add(ClothField(
        id: 'field_${DateTime.now().millisecondsSinceEpoch}_2',
        name: 'Waist',
        type: ClothFieldType.inches,
        defaultValue: '32',
      ));
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _addNewField() {
    setState(() {
      final uniqueId = 'field_${DateTime.now().millisecondsSinceEpoch}_${_fields.length}';
      _fields.add(ClothField(
        id: uniqueId,
        name: '',
        type: ClothFieldType.inches,
        defaultValue: '30',
      ));
    });
  }

  void _removeField(int index) {
    setState(() {
      _fields.removeAt(index);
    });
  }

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      if (_fields.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please add at least one measurement parameter')),
        );
        return;
      }

      // Check for empty field names
      for (int i = 0; i < _fields.length; i++) {
        if (_fields[i].name.trim().isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Parameter #${i + 1} cannot have an empty name')),
          );
          return;
        }
      }

      final clothTypeData = ClothType(
        id: isEditMode ? widget.clothType!.id : DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        fields: _fields.map((f) => f.copyWith(name: f.name.trim())).toList(),
      );

      if (isEditMode) {
        _appData.updateClothType(clothTypeData);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Garment template updated successfully')),
        );
      } else {
        _appData.addClothType(clothTypeData);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Garment template added successfully')),
        );
      }

      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? 'Edit Template' : 'Create Template'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check_rounded),
            onPressed: _saveForm,
            tooltip: 'Save Blueprint',
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            // Top Section: Template Name
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Garment Specification',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Define the name of the garment and configure the required measurement inputs.',
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Garment Name *',
                      prefixIcon: const Icon(Icons.architecture_rounded),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      hintText: 'E.g., Shirt, Kurta, Suit Jacket, Trouser',
                    ),
                    textCapitalization: TextCapitalization.words,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter garment name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Measurement Fields (${_fields.length})',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      ElevatedButton.icon(
                        onPressed: _addNewField,
                        icon: const Icon(Icons.add_rounded, size: 18),
                        label: const Text('Add Parameter'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Dynamic Fields list
            Expanded(
              child: _fields.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.list_alt_rounded, size: 48, color: Colors.grey[300]),
                          const SizedBox(height: 12),
                          Text(
                            'No fields added yet',
                            style: TextStyle(color: Colors.grey[500], fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Click "Add Parameter" to configure measurement inputs.',
                            style: TextStyle(color: Colors.grey[400], fontSize: 12),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      itemCount: _fields.length,
                      itemBuilder: (context, index) {
                        final field = _fields[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: Colors.grey.shade200),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                            child: Row(
                              children: [
                                // Index Indicator
                                CircleAvatar(
                                  radius: 12,
                                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                                  child: Text(
                                    '${index + 1}',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),

                                // Field Name Input
                                Expanded(
                                  child: TextFormField(
                                    initialValue: field.name,
                                    decoration: const InputDecoration(
                                      hintText: 'Parameter name (e.g. Chest)',
                                      border: InputBorder.none,
                                    ),
                                    textCapitalization: TextCapitalization.words,
                                    onChanged: (val) {
                                      _fields[index] = field.copyWith(name: val);
                                    },
                                  ),
                                ),

                                // Unit / Type Selector (Inches vs Text)
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ChoiceChip(
                                      label: const Text('Inches'),
                                      selected: field.type == ClothFieldType.inches,
                                      onSelected: (selected) {
                                        if (selected) {
                                          setState(() {
                                            _fields[index] = field.copyWith(
                                              type: ClothFieldType.inches,
                                              defaultValue: '30',
                                            );
                                          });
                                        }
                                      },
                                      labelStyle: TextStyle(
                                        fontSize: 11,
                                        color: field.type == ClothFieldType.inches
                                            ? Theme.of(context).colorScheme.onPrimary
                                            : Colors.grey[700],
                                      ),
                                      selectedColor: Theme.of(context).colorScheme.primary,
                                      visualDensity: VisualDensity.compact,
                                    ),
                                    const SizedBox(width: 4),
                                    ChoiceChip(
                                      label: const Text('Text'),
                                      selected: field.type == ClothFieldType.text,
                                      onSelected: (selected) {
                                        if (selected) {
                                          setState(() {
                                            _fields[index] = field.copyWith(
                                              type: ClothFieldType.text,
                                              defaultValue: '',
                                            );
                                          });
                                        }
                                      },
                                      labelStyle: TextStyle(
                                        fontSize: 11,
                                        color: field.type == ClothFieldType.text
                                            ? Theme.of(context).colorScheme.onPrimary
                                            : Colors.grey[700],
                                      ),
                                      selectedColor: Theme.of(context).colorScheme.primary,
                                      visualDensity: VisualDensity.compact,
                                    ),
                                  ],
                                ),

                                // Delete Field Button
                                IconButton(
                                  icon: const Icon(Icons.close_rounded, color: Colors.redAccent, size: 20),
                                  onPressed: () => _removeField(index),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),

            // Save Button footer
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _saveForm,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    isEditMode ? 'Update Specification' : 'Save Specification',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
