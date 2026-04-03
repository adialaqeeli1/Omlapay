import 'package:fast_contacts/fast_contacts.dart';
import 'package:flutter/material.dart';

import '../../../../core/extentions/context_extensions.dart';
import '../../../../core/models/contact_model/contact_model.dart';
import '../../../../core/theme/theme.dart';
import '../../../../widgets/common_text_field.dart';

/// Bottom sheet that displays device contacts for selection.
///
/// Permission must be granted **before** showing this sheet.
class ContactSelectionSheet extends StatefulWidget {
  final Function(ContactModel) onContactSelected;

  const ContactSelectionSheet({super.key, required this.onContactSelected});

  @override
  State<ContactSelectionSheet> createState() => _ContactSelectionSheetState();
}

class _ContactSelectionSheetState extends State<ContactSelectionSheet> {
  final TextEditingController _searchController = TextEditingController();
  List<Contact> _allContacts = [];
  List<Contact> _filteredContacts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterContacts);
    _loadContacts();
  }

  Future<void> _loadContacts() async {
    final contacts = await FastContacts.getAllContacts();
    final withPhones = contacts.where((c) => c.phones.isNotEmpty).toList();
    _sortContacts(withPhones);

    if (mounted) {
      setState(() {
        _allContacts = withPhones;
        _filteredContacts = withPhones;
        _isLoading = false;
      });
    }
  }

  /// Sorts contacts alphabetically by name; unnamed contacts go to the end.
  void _sortContacts(List<Contact> contacts) {
    contacts.sort((a, b) {
      final aName = a.displayName.trim();
      final bName = b.displayName.trim();
      final aHasName = aName.isNotEmpty;
      final bHasName = bName.isNotEmpty;
      if (aHasName && !bHasName) return -1;
      if (!aHasName && bHasName) return 1;
      return aName.toLowerCase().compareTo(bName.toLowerCase());
    });
  }

  void _filterContacts() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredContacts = _allContacts.where((contact) {
        final name = contact.displayName.toLowerCase();
        final phones = contact.phones
            .map((p) => p.number.replaceAll(RegExp(r'\s+'), ''))
            .join(' ');
        return name.contains(query) || phones.contains(query);
      }).toList();
      _sortContacts(_filteredContacts);
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

          // Content
          Expanded(child: _buildContent(context)),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final l10n = context.l10n!;
    final colorScheme = Theme.of(context).colorScheme;

    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              l10n.contactsLoading,
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      );
    }

    if (_filteredContacts.isEmpty) {
      return Center(
        child: Text(
          l10n.noContactsFound,
          style: TextStyle(color: colorScheme.onSurfaceVariant),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _filteredContacts.length,
      separatorBuilder: (context, index) => Divider(
        color: colorScheme.outlineVariant,
        height: 1,
      ),
      itemBuilder: (context, index) {
        final contact = _filteredContacts[index];
        final phone = contact.phones.first.number;
        return ListTile(
          contentPadding: EdgeInsets.zero,
          leading: CircleAvatar(
            backgroundColor: AppColors.tealColor.withValues(alpha: 0.2),
            child: Text(
              contact.displayName.isNotEmpty
                  ? contact.displayName[0].toUpperCase()
                  : '?',
              style: const TextStyle(
                color: AppColors.tealColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          title: Text(
            contact.displayName,
            style: TextStyle(
              color: colorScheme.onSurface,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: Text(
            phone,
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
              fontSize: 14,
            ),
          ),
          onTap: () {
            final contactModel = ContactModel(
              id: contact.id,
              name: contact.displayName,
              phoneNumber: phone,
            );
            widget.onContactSelected(contactModel);
            Navigator.pop(context);
          },
        );
      },
    );
  }
}
