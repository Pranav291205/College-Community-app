import 'package:flutter/material.dart';

class MultiSelectCategoriesDropdown extends StatefulWidget {
  final List<String> selectedCategories;
  final Function(List<String>) onChanged;

  const MultiSelectCategoriesDropdown({
    Key? key,
    required this.selectedCategories,
    required this.onChanged,
  }) : super(key: key);

  @override
  State<MultiSelectCategoriesDropdown> createState() =>
      _MultiSelectCategoriesDropdownState();
}

class _MultiSelectCategoriesDropdownState
    extends State<MultiSelectCategoriesDropdown> {
  static const List<String> _allCategories = [
        "Artificial Intelligence (AI)",
        "Technical",
        "Machine Learning",
        "Data Science",
        "Python Programming",
        "Web Development",
        "AR / VR",
        "Cloud Computing",
        "Cyber Security",
        "Robotics",
        "Electronics",
        "Mechanical Design",
        "CAD / CAM",
        "Electrical Systems",
        "Embedded Systems",
        "Blockchain",
        "Quantum Computing",
        "Competitive Coding",
        "Hackathons",
        "Research & Innovation",
  ];

  void _showCategoryDialog() {
    showDialog(
      context: context,
      builder: (context) {
        List<String> tempSelected = List.from(widget.selectedCategories);

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Select Categories'),
              content: SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _allCategories.length,
                  itemBuilder: (context, index) {
                    final category = _allCategories[index];
                    final isSelected = tempSelected.contains(category);

                    return CheckboxListTile(
                      title: Text(category),
                      value: isSelected,
                      activeColor: Colors.blue,
                      onChanged: (checked) {
                        setDialogState(() {
                          if (checked == true) {
                            tempSelected.add(category);
                          } else {
                            tempSelected.remove(category);
                          }
                        });
                      },
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    widget.onChanged(tempSelected);
                    Navigator.pop(context);
                  },
                  child: const Text('Done'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _showCategoryDialog,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade400),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const Icon(Icons.category, color: Colors.blue),
            const SizedBox(width: 12),
            Expanded(
              child: widget.selectedCategories.isEmpty
                  ? const Text(
                      'Select categories',
                      style: TextStyle(color: Colors.grey),
                    )
                  : Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: widget.selectedCategories.map((cat) {
                        return Chip(
                          label: Text(
                            cat,
                            style: const TextStyle(fontSize: 11),
                          ),
                          backgroundColor: Colors.blue.shade100,
                          deleteIcon: const Icon(Icons.close, size: 16),
                          onDeleted: () {
                            final updated = List<String>.from(
                              widget.selectedCategories,
                            );
                            updated.remove(cat);
                            widget.onChanged(updated);
                          },
                        );
                      }).toList(),
                    ),
            ),
            const Icon(Icons.arrow_drop_down),
          ],
        ),
      ),
    );
  }
}
