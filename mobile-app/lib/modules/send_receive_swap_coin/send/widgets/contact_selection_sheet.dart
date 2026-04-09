import 'package:country_picker/country_picker.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter/material.dart';

import '../../../../core/extentions/context_extensions.dart';
import '../../../../core/models/contact_model/contact_model.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/utils/app_exception.dart';
import '../../../../core/utils/snackbar_helper.dart';
import '../../../../widgets/common_text_field.dart';
import '../../../auth/services/auth_service.dart';
import 'send_invitation_dialog.dart';

/// Bottom sheet that displays device contacts for selection.
///
/// Permission must be granted **before** showing this sheet.
/// When a contact is tapped, we call the check-user API first.
/// If the user doesn't exist on Omlapay, an invitation dialog is shown.
class ContactSelectionSheet extends StatefulWidget {
  final Function(ContactModel) onContactSelected;

  const ContactSelectionSheet({super.key, required this.onContactSelected});

  @override
  State<ContactSelectionSheet> createState() => _ContactSelectionSheetState();
}

class _ContactSelectionSheetState extends State<ContactSelectionSheet> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  List<Contact> _allContacts = [];
  List<Contact> _filteredContacts = [];
  bool _isLoading = true;

  /// Tracks which contact index is currently being checked against the API.
  int? _checkingIndex;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterContacts);
    _loadContacts();
  }

  Future<void> _loadContacts() async {
    final contacts = await FlutterContacts.getAll(
      properties: {ContactProperty.phone},
    );
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
      final aName = a.displayName?.trim() ?? '';
      final bName = b.displayName?.trim() ?? '';
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
        final name = contact.displayName?.toLowerCase() ?? '';
        final phones = contact.phones
            .map((p) => p.number.replaceAll(RegExp(r'\s+'), ''))
            .join(' ');
        return name.contains(query) || phones.contains(query);
      }).toList();
      _sortContacts(_filteredContacts);
    });
  }

  /// Parses a full phone number into (countryCode, mobileNumber).
  ///
  /// If the phone number starts with `+`, we extract the country code prefix.
  /// Otherwise we fall back to the device's locale-based country code.
  ({String countryCode, String mobileNumber}) _parsePhoneNumber(String phone) {
    // Normalize: remove spaces, dashes, parentheses.
    String cleaned = phone.replaceAll(RegExp(r'[\s\-\(\)]'), '');

    // Normalize international prefix "00" to "+"
    if (cleaned.startsWith('00')) {
      cleaned = '+${cleaned.substring(2)}';
    }

    if (cleaned.startsWith('+') && cleaned.length > 3) {
      // Try to match known country phone codes (1–3 digit codes after '+').
      // We try 3 digits, then 2, then 1 to find the best match.
      for (int len = 3; len >= 1; len--) {
        if (cleaned.length <= len + 1) continue;
        final codeCandidate = cleaned.substring(1, 1 + len);
        final country = CountryService().findByPhoneCode(codeCandidate);
        if (country != null) {
          // Found a valid country code.
          return (
            countryCode: '+$codeCandidate',
            mobileNumber: cleaned.substring(1 + len),
          );
        }
      }
    }

    // Fallback: use device locale country code.
    final defaultCode = _deviceDefaultCountryCode();
    final mobileNumber = cleaned.startsWith('+')
        ? cleaned.substring(1)
        : cleaned;
    return (countryCode: defaultCode, mobileNumber: mobileNumber);
  }

  /// Returns the device's default country phone code (e.g. "+966").
  String _deviceDefaultCountryCode() {
    try {
      final localeCountryCode =
          WidgetsBinding.instance.platformDispatcher.locale.countryCode;
      if (localeCountryCode != null && localeCountryCode.isNotEmpty) {
        final country = CountryService().findByCode(localeCountryCode);
        if (country != null) return '+${country.phoneCode}';
      }
    } catch (_) {}
    // Ultimate fallback.
    return '+966';
  }

  /// Called when a contact tile is tapped.
  /// Checks the user against the API before completing selection.
  Future<void> _onContactTapped(Contact contact, int index) async {
    _searchFocusNode.unfocus();
    FocusManager.instance.primaryFocus?.unfocus();

    if (_checkingIndex != null) return; // Already checking another contact.

    final phone = contact.phones.first.number;
    final parsed = _parsePhoneNumber(phone);

    setState(() => _checkingIndex = index);

    try {
      final response = await AuthService.checkUser(
        countryCode: parsed.countryCode,
        mobileNumber: parsed.mobileNumber,
      );

      if (!mounted) return;

      final statusCode = response['statusCode'];
      final isSuccess =
          statusCode is int && statusCode >= 200 && statusCode < 300;

      if (isSuccess) {
        final data = response['data'];
        final userExists = data is Map && data['userExists'] == true;

        if (userExists) {
          // User exists — select and close.
          _selectContactAndPop(contact, phone);
        } else {
          // Temporarily hide the loading spinner while the dialog is open.
          if (mounted) setState(() => _checkingIndex = null);

          // User doesn't exist — show invitation dialog.
          final result = await SendInvitationDialog.show(context);
          if (!mounted) return;

          if (result == true) {
            // Invite tapped — call the invite API.
            setState(() => _checkingIndex = index);
            try {
              final inviteResponse = await AuthService.inviteUser(
                countryCode: parsed.countryCode,
                mobileNumber: parsed.mobileNumber,
              );
              if (!mounted) return;

              // Pop the bottom sheet so the toast is visible over the main screen
              Navigator.pop(context);

              final message =
                  inviteResponse['message'] ??
                  inviteResponse['localized_message'];
              if (message != null && message.toString().isNotEmpty) {
                SnackbarHelper.showSuccess(context, message.toString());
              } else {
                SnackbarHelper.showSuccess(
                  context,
                  "Invitation sent successfully",
                );
              }
            } catch (e) {
              if (mounted) {
                // Popping the bottom sheet on error as well
                Navigator.pop(context);
                final message = e is AppException
                    ? e.localizedMessage(context.l10n)
                    : context.l10n!.unknownError;
                SnackbarHelper.showError(context, message);
              }
            }
          }
          // Cancel tapped — just close the dialog, stay on the sheet.

          // Defensively ensure keyboard is dropped again after returning to the sheet.
          if (mounted) FocusManager.instance.primaryFocus?.unfocus();
        }
      } else {
        // Unexpected format from ApiHelper but status is 2xx
        _selectContactAndPop(contact, phone);
      }
    } catch (e) {
      // Show API errors to the user (e.g. invalid country code)
      if (mounted) {
        final message = e is AppException
            ? e.message
            : context.l10n!.unknownError;
        SnackbarHelper.showError(context, message);
      }
    } finally {
      if (mounted) {
        setState(() => _checkingIndex = null);
      }
    }
  }

  /// Creates a [ContactModel], calls the callback, and pops the sheet.
  void _selectContactAndPop(Contact contact, String phone) {
    final contactModel = ContactModel(
      id: contact.id ?? '',
      name: contact.displayName ?? '',
      phoneNumber: phone,
    );
    widget.onContactSelected(contactModel);
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
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
              focusNode: _searchFocusNode,
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
      separatorBuilder: (context, index) =>
          Divider(color: colorScheme.outlineVariant, height: 1),
      itemBuilder: (context, index) {
        final contact = _filteredContacts[index];
        final phone = contact.phones.first.number;
        final isChecking = _checkingIndex == index;
        return ListTile(
          contentPadding: EdgeInsets.zero,
          leading: CircleAvatar(
            backgroundColor: AppColors.tealColor.withValues(alpha: 0.2),
            child: Text(
              (contact.displayName != null && contact.displayName!.isNotEmpty)
                  ? contact.displayName![0].toUpperCase()
                  : '?',
              style: const TextStyle(
                color: AppColors.tealColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          title: Text(
            contact.displayName ?? '',
            style: TextStyle(
              color: colorScheme.onSurface,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: Text(
            phone,
            style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 14),
          ),
          trailing: isChecking
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.tealColor,
                  ),
                )
              : null,
          onTap: isChecking ? null : () => _onContactTapped(contact, index),
        );
      },
    );
  }
}
