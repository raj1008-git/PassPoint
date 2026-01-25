import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/dev.log.dart';

class ManageDepartmentsScreen extends StatefulWidget {
  const ManageDepartmentsScreen({Key? key}) : super(key: key);

  @override
  State<ManageDepartmentsScreen> createState() =>
      _ManageDepartmentsScreenState();
}

class _ManageDepartmentsScreenState extends State<ManageDepartmentsScreen> {
  Stream<QuerySnapshot> _departmentsStream() {
    return FirebaseFirestore.instance
        .collection('departments')
        .orderBy('name')
        .snapshots();
  }

  Future<void> _showAddDepartmentDialog() async {
    final nameController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Department'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Department Name',
                hintText: 'e.g., IT Department',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.words,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = nameController.text.trim();
              if (name.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter department name'),
                    backgroundColor: AppTheme.error,
                  ),
                );
                return;
              }

              try {
                await FirebaseFirestore.instance.collection('departments').add({
                  'name': name,
                  'people': [],
                  'peopleEmails': [],
                });

                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Department "$name" added successfully'),
                      backgroundColor: AppTheme.success,
                    ),
                  );
                }
              } catch (e) {
                devLog('Add department error', params: {'error': e.toString()});
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to add department: $e'),
                      backgroundColor: AppTheme.error,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryRed,
              foregroundColor: AppTheme.white,
            ),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _showEditDepartmentDialog(
    String departmentId,
    String currentName,
  ) async {
    final nameController = TextEditingController(text: currentName);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Department Name'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Department Name',
            border: OutlineInputBorder(),
          ),
          textCapitalization: TextCapitalization.words,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = nameController.text.trim();
              if (name.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter department name'),
                    backgroundColor: AppTheme.error,
                  ),
                );
                return;
              }

              try {
                await FirebaseFirestore.instance
                    .collection('departments')
                    .doc(departmentId)
                    .update({'name': name});

                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Department updated successfully'),
                      backgroundColor: AppTheme.success,
                    ),
                  );
                }
              } catch (e) {
                devLog(
                  'Edit department error',
                  params: {'error': e.toString()},
                );
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to update department: $e'),
                      backgroundColor: AppTheme.error,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.info,
              foregroundColor: AppTheme.white,
            ),
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  Future<void> _showManagePeopleDialog(
    String departmentId,
    String departmentName,
    List<String> currentPeople,
    List<String> currentEmails,
  ) async {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final people = List<String>.from(currentPeople);
    final emails = List<String>.from(currentEmails);

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Text('Manage People - $departmentName'),
            content: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Add person form
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Person Name',
                      hintText: 'e.g., John Doe',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                    ),
                    textCapitalization: TextCapitalization.words,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email (optional)',
                      hintText: 'john.doe@pmlil.com',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () {
                      final name = nameController.text.trim();
                      if (name.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please enter person name'),
                            backgroundColor: AppTheme.error,
                          ),
                        );
                        return;
                      }

                      setDialogState(() {
                        people.add(name);
                        emails.add(emailController.text.trim());
                        nameController.clear();
                        emailController.clear();
                      });
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Add Person'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.success,
                      foregroundColor: AppTheme.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 12),

                  // People list
                  if (people.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        'No people added yet',
                        style: AppTheme.bodySmall,
                      ),
                    )
                  else
                    Flexible(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: people.length,
                        itemBuilder: (context, index) {
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: AppTheme.info.withOpacity(0.2),
                                child: Text(
                                  people[index][0].toUpperCase(),
                                  style: const TextStyle(
                                    color: AppTheme.info,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              title: Text(people[index]),
                              subtitle: emails[index].isNotEmpty
                                  ? Text(
                                      emails[index],
                                      style: const TextStyle(fontSize: 12),
                                    )
                                  : const Text(
                                      'No email',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                              trailing: IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: AppTheme.error,
                                ),
                                onPressed: () {
                                  setDialogState(() {
                                    people.removeAt(index);
                                    emails.removeAt(index);
                                  });
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  try {
                    await FirebaseFirestore.instance
                        .collection('departments')
                        .doc(departmentId)
                        .update({'people': people, 'peopleEmails': emails});

                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('People updated successfully'),
                          backgroundColor: AppTheme.success,
                        ),
                      );
                    }
                  } catch (e) {
                    devLog(
                      'Update people error',
                      params: {'error': e.toString()},
                    );
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Failed to update people: $e'),
                          backgroundColor: AppTheme.error,
                        ),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryRed,
                  foregroundColor: AppTheme.white,
                ),
                child: const Text('Save Changes'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _deleteDepartment(String departmentId, String name) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Department'),
        content: Text(
          'Are you sure you want to delete "$name"?\n\nThis action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.error,
              foregroundColor: AppTheme.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await FirebaseFirestore.instance
            .collection('departments')
            .doc(departmentId)
            .delete();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Department "$name" deleted'),
              backgroundColor: AppTheme.success,
            ),
          );
        }
      } catch (e) {
        devLog('Delete department error', params: {'error': e.toString()});
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete department: $e'),
              backgroundColor: AppTheme.error,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.dark),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Manage Departments',
          style: TextStyle(color: AppTheme.dark),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _departmentsStream(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AppTheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text('Error: ${snapshot.error}'),
                ],
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final departments = snapshot.data!.docs;

          if (departments.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.business_outlined,
                    size: 80,
                    color: AppTheme.grey.withOpacity(0.3),
                  ),
                  const SizedBox(height: 16),
                  const Text('No departments yet', style: AppTheme.h3),
                  const SizedBox(height: 8),
                  const Text(
                    'Tap the + button to add your first department',
                    style: AppTheme.bodySmall,
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: departments.length,
            itemBuilder: (context, index) {
              final doc = departments[index];
              final data = doc.data() as Map<String, dynamic>;
              final name = data['name'] ?? 'Unnamed Department';
              final people = (data['people'] as List?)?.cast<String>() ?? [];
              final emails =
                  (data['peopleEmails'] as List?)?.cast<String>() ?? [];

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: AppTheme.radiusMedium,
                ),
                child: ExpansionTile(
                  leading: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryRed.withOpacity(0.1),
                      borderRadius: AppTheme.radiusSmall,
                    ),
                    child: const Icon(
                      Icons.business,
                      color: AppTheme.primaryRed,
                    ),
                  ),
                  title: Text(
                    name,
                    style: AppTheme.labelLarge.copyWith(fontSize: 16),
                  ),
                  subtitle: Text(
                    '${people.length} ${people.length == 1 ? 'person' : 'people'}',
                    style: AppTheme.bodySmall,
                  ),
                  children: [
                    const Divider(height: 1),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // People list
                          if (people.isEmpty)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 8),
                              child: Text(
                                'No people added yet',
                                style: AppTheme.bodySmall,
                              ),
                            )
                          else
                            ...people.asMap().entries.map((entry) {
                              final idx = entry.key;
                              final person = entry.value;
                              final email = idx < emails.length
                                  ? emails[idx]
                                  : '';
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.person,
                                      size: 16,
                                      color: AppTheme.textSecondary,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            person,
                                            style: AppTheme.bodyMedium,
                                          ),
                                          if (email.isNotEmpty)
                                            Text(
                                              email,
                                              style: AppTheme.bodySmall
                                                  .copyWith(
                                                    color:
                                                        AppTheme.textTertiary,
                                                  ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),

                          const SizedBox(height: 16),

                          // Action buttons
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              ElevatedButton.icon(
                                onPressed: () => _showManagePeopleDialog(
                                  doc.id,
                                  name,
                                  people,
                                  emails,
                                ),
                                icon: const Icon(Icons.people, size: 18),
                                label: const Text('Manage People'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.info,
                                  foregroundColor: AppTheme.white,
                                ),
                              ),
                              OutlinedButton.icon(
                                onPressed: () =>
                                    _showEditDepartmentDialog(doc.id, name),
                                icon: const Icon(Icons.edit, size: 18),
                                label: const Text('Edit Name'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppTheme.dark,
                                ),
                              ),
                              OutlinedButton.icon(
                                onPressed: () =>
                                    _deleteDepartment(doc.id, name),
                                icon: const Icon(Icons.delete, size: 18),
                                label: const Text('Delete'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppTheme.error,
                                  side: const BorderSide(color: AppTheme.error),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddDepartmentDialog,
        backgroundColor: AppTheme.primaryRed,
        icon: const Icon(Icons.add),
        label: const Text('Add Department'),
      ),
    );
  }
}
