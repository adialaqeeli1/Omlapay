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
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1E1E1E), // Dark background matching design
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
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
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              fillColor: const Color(0xFF2A2D35),
            ),
          ),

          const SizedBox(height: 16),

          // List
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _filteredContacts.length,
              separatorBuilder: (context, index) =>
                  const Divider(color: Color(0xFF2A2D35), height: 1),
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
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: Text(
                    contact.phoneNumber,
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
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
