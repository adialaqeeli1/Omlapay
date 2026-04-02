import 'package:flutter/material.dart';
import '../../../../core/extentions/context_extensions.dart';
import '../../../../core/mock_data/mock_data.dart';
import '../../../../core/models/contact_model/contact_model.dart';
import '../../../../core/theme/theme.dart';
import '../../../../widgets/common_text_field.dart';

class ContactSelectionSheet extends StatefulWidget {
  final Function(ContactModel) onContactSelected;

  const ContactSelectionSheet({super.key, required this.onContactSelected});

  @override
  State<ContactSelectionSheet> createState() => _ContactSelectionSheetState();
}

class _ContactSelectionSheetState extends State<ContactSelectionSheet> {
  final TextEditingController _searchController = TextEditingController();
  List<ContactModel> _filteredContacts = [];

  @override
  void initState() {
    super.initState();
    _filteredContacts = MockData.contacts;
    _searchController.addListener(_filterContacts);
  }

  void _filterContacts() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredContacts = MockData.contacts.where((contact) {
        return contact.name.toLowerCase().contains(query) ||
            contact.phoneNumber.contains(query);
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n!;
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.contactsSheetTitle,
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: colorScheme.onSurface),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // Search
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: CommonTextField(
              controller: _searchController,
              hintText: l10n.searchContactsHint,
              prefixIcon: Icon(
                Icons.search,
                color: colorScheme.onSurfaceVariant,
              ),
              fillColor: colorScheme.surfaceContainerHighest,
            ),
          ),

          const SizedBox(height: 16),

          // List
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _filteredContacts.length,
              separatorBuilder: (context, index) => Divider(
                color: colorScheme.outlineVariant,
                height: 1,
              ),
              itemBuilder: (context, index) {
                final contact = _filteredContacts[index];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: AppColors.tealColor.withValues(alpha: 0.2),
                    child: Text(
                      contact.name[0].toUpperCase(),
                      style: const TextStyle(
                        color: AppColors.tealColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    contact.name,
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: Text(
                    contact.phoneNumber,
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 14,
                    ),
                  ),
                  trailing: contact.isVerified
                      ? const Icon(
                          Icons.verified,
                          color: AppColors.tealColor,
                          size: 20,
                        )
                      : null,
                  onTap: () {
                    widget.onContactSelected(contact);
                    Navigator.pop(context);
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
