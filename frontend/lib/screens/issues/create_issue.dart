import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/blocs/issue/issue_bloc.dart';
import 'package:frontend/blocs/issue/issue_event.dart';
import 'package:frontend/blocs/issue/issue_state.dart';
import 'package:frontend/models/issue.dart';
import 'package:frontend/widgets/modern_snackbar.dart';

class IssueForm extends StatefulWidget {
  final String projectID;
  final String reporterID;
  const IssueForm({
    super.key,
    required this.projectID,
    required this.reporterID,
  });

  @override
  State<IssueForm> createState() => _IssueFormState();
}

class _IssueFormState extends State<IssueForm> {
  final _formKey = GlobalKey<FormState>();

  String _title = '';
  String _description = '';
  IssuePriority _priority = IssuePriority.medium;
  IssueStatus _status = IssueStatus.open;

  bool _validateTextField() {
    if (_title.isEmpty || _description.isEmpty) {
      context.read<IssueBloc>().add(
        const IssueTextFieldValidated('Please fill in all fields.'),
      );
      return false;
    } else {
      context.read<IssueBloc>().add(
        IssueCreateRequested(
          widget.projectID,
          _title,
          _description,
          _priority.value.toLowerCase(),
          _status.value.toLowerCase(),
        ),
      );
      ModernSnackbar.show(
        context: context,
        message: "Issue added successfully.",
        type: SnackbarType.success,
      );
      Navigator.pop(context, true);
      return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Issue'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  _buildTextField('Title', onChanged: (val) => _title = val),
                  const SizedBox(height: 20),
                  _buildTextField(
                    'Description',
                    onChanged: (val) => _description = val,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 20),
                  _buildDropdown<IssuePriority>(
                    label: 'Priority',
                    value: _priority,
                    items: IssuePriority.values,
                    onChanged: (val) => setState(() => _priority = val!),
                  ),
                  const SizedBox(height: 20),
                  _buildDropdown<IssueStatus>(
                    label: 'Status',
                    value: _status,
                    items: IssueStatus.values,
                    onChanged: (val) => setState(() => _status = val!),
                  ),
                  const SizedBox(height: 20),
                  // _buildDropdown<IssueType>(
                  //   label: 'Type',
                  //   value: _type,
                  //   items: IssueType.values,
                  //   onChanged: (val) => setState(() => _type = val!),
                  // ),
                  // const SizedBox(height: 12),
                  // _buildSecondTextField(
                  //   'Reporter ID',
                  //   controller: _reporterController,
                  // ),
                  // const SizedBox(height: 12),
                  // _buildSecondTextField(
                  //   'Project ID',
                  //   controller: _projectController,
                  // ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.save),
                    label: const Text('Save Issue'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => _validateTextField(),
                  ),
                  const SizedBox(height: 30),
                  BlocBuilder<IssueBloc, IssueState>(
                    builder: (context, state) {
                      if (state is IssueTextFieldValidatedState) {
                        return Center(
                          child: Text(
                            state.message,
                            style: TextStyle(
                              color: Colors.red[400],
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      }
                      return SizedBox();
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label, {
    required void Function(String) onChanged,
    int maxLines = 1,
  }) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      maxLines: maxLines,
      onChanged: onChanged,
      validator: (val) =>
          (val == null || val.trim().isEmpty) ? 'Please enter $label' : null,
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    required T value,
    required List<T> items,
    required ValueChanged<T?> onChanged,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      items: items
          .map(
            (e) => DropdownMenuItem<T>(
              value: e,
              child: Text(e.toString().split('.').last.toUpperCase()),
            ),
          )
          .toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }
}
