import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:widget_flutter/core/constants/app_colors.dart';
import 'package:widget_flutter/models/address.dart';
import 'package:widget_flutter/providers/auth_provider.dart';
import 'package:widget_flutter/providers/address_provider.dart';
import 'package:widget_flutter/routes/app_route.dart';

enum _AddressInputMethod { text, map }

class AddressesScreen extends StatefulWidget {
  const AddressesScreen({super.key});

  @override
  State<AddressesScreen> createState() => _AddressesScreenState();
}

class _AddressesScreenState extends State<AddressesScreen> {
  String? _loadedToken;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final token = context.read<AuthProvider>().token;
    if (token != null && token.isNotEmpty && token != _loadedToken) {
      _loadedToken = token;
      context.read<AddressProvider>().loadAddresses(token);
    }
  }

  Future<void> _addAddress(BuildContext context) async {
    final method = await _chooseAddressInput(context);
    if (!context.mounted || method == null) return;

    String? addressText;
    var latitude = 0.0;
    var longitude = 0.0;
    if (method == _AddressInputMethod.map) {
      final result = await context.push(AppRoute.map);
      if (!context.mounted || result is! Map<String, dynamic>) return;
      addressText = result['address']?.toString();
      latitude = (result['lat'] as num?)?.toDouble() ?? 0;
      longitude = (result['lng'] as num?)?.toDouble() ?? 0;
    } else {
      addressText = await _requestManualAddress(context);
    }
    if (!context.mounted) return;
    if (addressText == null || addressText.isEmpty) return;

    final label = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => _LabelPicker(
        onSelected: (value) => Navigator.of(sheetContext).pop(value),
      ),
    );
    if (!context.mounted || label == null) return;

    final contact = await _requestContact(context, addressText, label);
    if (!context.mounted || contact == null) return;

    final token = context.read<AuthProvider>().token;
    if (token == null || token.isEmpty) return;

    try {
      await context.read<AddressProvider>().addAddress(
            token,
            Address(
              id: 0,
              label: label,
              recipientName: contact.$1,
              phone: contact.$2,
              address: addressText,
              lat: latitude,
              lng: longitude,
            ),
          );
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.toString().replaceFirst('Exception: ', ''))),
        );
      }
      return;
    }
    if (context.mounted) context.pop();
  }

  Future<_AddressInputMethod?> _chooseAddressInput(BuildContext context) {
    return showModalBottomSheet<_AddressInputMethod>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Container(
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 18),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const Text(
                'Add delivery address',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 6),
              Text(
                'How would you like to add your location?',
                style: TextStyle(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 16),
              _AddressInputOption(
                icon: Icons.edit_location_alt_outlined,
                title: 'Enter address manually',
                subtitle: 'Type a street, building, or landmark',
                onTap: () => Navigator.of(sheetContext)
                    .pop(_AddressInputMethod.text),
              ),
              const SizedBox(height: 10),
              _AddressInputOption(
                icon: Icons.map_outlined,
                title: 'Choose on Google Maps',
                subtitle: 'Pin the exact delivery location',
                onTap: () => Navigator.of(sheetContext)
                    .pop(_AddressInputMethod.map),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<String?> _requestManualAddress(BuildContext context) async {
    final houseController = TextEditingController();
    final streetController = TextEditingController();
    final areaController = TextEditingController();
    final landmarkController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
        contentPadding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
        title: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.edit_location_alt_outlined,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Enter your address',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          padding: EdgeInsets.only(
            bottom: MediaQuery.viewInsetsOf(dialogContext).bottom,
          ),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Add a detailed location so your order reaches you easily.',
                  style: TextStyle(color: Colors.grey.shade600, height: 1.35),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: houseController,
                  autofocus: true,
                  textCapitalization: TextCapitalization.sentences,
                  textInputAction: TextInputAction.next,
                  decoration: _dialogInputDecoration(
                    label: 'House / building number',
                    hint: 'Example: House 24A or Building B',
                    icon: Icons.home_work_outlined,
                  ),
                  validator: _requiredAddressField,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: streetController,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  decoration: _dialogInputDecoration(
                    label: 'Street',
                    hint: 'Street name or number',
                    icon: Icons.signpost_outlined,
                  ),
                  validator: _requiredAddressField,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: areaController,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  decoration: _dialogInputDecoration(
                    label: 'Area / city',
                    hint: 'District, commune, or city',
                    icon: Icons.location_city_outlined,
                  ),
                  validator: _requiredAddressField,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: landmarkController,
                  textCapitalization: TextCapitalization.sentences,
                  textInputAction: TextInputAction.done,
                  decoration: _dialogInputDecoration(
                    label: 'Landmark (optional)',
                    hint: 'Nearby shop, school, or landmark',
                    icon: Icons.flag_outlined,
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                final parts = [
                  houseController.text.trim(),
                  streetController.text.trim(),
                  areaController.text.trim(),
                  landmarkController.text.trim(),
                ].where((part) => part.isNotEmpty).join(', ');
                Navigator.of(dialogContext).pop(parts);
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Continue'),
          ),
        ],
      ),
    );
    return result;
  }

  String? _requiredAddressField(String? value) {
    return value == null || value.trim().isEmpty ? 'This field is required' : null;
  }

  Future<(String, String)?> _requestContact(
    BuildContext context,
    String addressText,
    String label,
  ) async {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final result = await showDialog<(String, String)>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
        contentPadding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
        title: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.location_on_rounded, color: AppColors.primary),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Save this address',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Add delivery details for your $label address.',
                  style: TextStyle(color: Colors.grey.shade600, height: 1.35),
                ),
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF7F0),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.pin_drop_outlined, size: 19, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          addressText,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 13, height: 1.3),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: nameController,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  decoration: _dialogInputDecoration(
                    label: 'Recipient name',
                    icon: Icons.person_outline_rounded,
                  ),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Enter the recipient name'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.done,
                  decoration: _dialogInputDecoration(
                    label: 'Phone number',
                    icon: Icons.phone_outlined,
                  ),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Enter a phone number'
                      : null,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton.icon(
            onPressed: () {
              if (!formKey.currentState!.validate()) return;
              Navigator.of(dialogContext).pop(
                (nameController.text.trim(), phoneController.text.trim()),
              );
            },
            icon: const Icon(Icons.check_rounded, size: 18),
            label: const Text('Save address'),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
    return result;
  }

  InputDecoration _dialogInputDecoration({
    required String label,
    String? hint,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon, color: AppColors.primary),
      filled: true,
      fillColor: const Color(0xFFFFFBF8),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFEADFD7)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFEADFD7)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final addressProvider = context.watch<AddressProvider>();
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF8),
      appBar: AppBar(
        title: const Text('Delivery address'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
        body: addressProvider.loading
          ? const Center(child: CircularProgressIndicator())
          : addressProvider.addresses.isEmpty
          ? _EmptyAddresses(onAdd: () => _addAddress(context))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text(
                  'Choose where to deliver',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 6),
                Text(
                  'Select a saved address or add a new location.',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                const SizedBox(height: 18),
                ...addressProvider.addresses.map(
                  (address) => _AddressTile(
                    address: address,
                    selected: addressProvider.selectedAddress?.id == address.id,
                    onTap: () async {
                      final token = authProvider.token;
                      if (token != null && !address.isDefault) {
                        try {
                          await addressProvider.setDefault(token, address);
                        } catch (error) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(error.toString().replaceFirst('Exception: ', ''))),
                            );
                          }
                          return;
                        }
                      } else {
                        addressProvider.selectAddress(address);
                      }
                      if (context.mounted) context.pop();
                    },
                    onDelete: () async {
                      final token = authProvider.token;
                      if (token == null) return;
                      try {
                        await addressProvider.deleteAddress(token, address.id);
                      } catch (error) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(error.toString().replaceFirst('Exception: ', ''))),
                          );
                        }
                      }
                    },
                  ),
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: () => _addAddress(context),
                  icon: const Icon(Icons.add_location_alt_outlined),
                  label: const Text('Add another address'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    minimumSize: const Size.fromHeight(50),
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class _EmptyAddresses extends StatelessWidget {
  final VoidCallback onAdd;

  const _EmptyAddresses({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 92,
              height: 92,
              decoration: const BoxDecoration(
                color: Color(0xFFFFEBDD),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.location_on_outlined,
                size: 42,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Add a delivery address',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              'Choose Home, School, or Work and pin the exact location on Google Maps.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600, height: 1.4),
            ),
            const SizedBox(height: 22),
            ElevatedButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.map_outlined),
              label: const Text('Choose on map'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddressTile extends StatelessWidget {
  final Address address;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _AddressTile({
    required this.address,
    required this.selected,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: selected ? AppColors.primary : const Color(0xFFF0E5DD),
          width: selected ? 1.5 : 1,
        ),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        leading: CircleAvatar(
          backgroundColor: const Color(0xFFFFEBDD),
          child: Icon(_iconFor(address.label), color: AppColors.primary),
        ),
        title: Text(
          address.label,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Text(
          address.address,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (selected)
              const Icon(Icons.check_circle_rounded, color: AppColors.secondary),
            IconButton(
              onPressed: onDelete,
              icon: Icon(Icons.delete_outline, color: Colors.grey.shade500),
            ),
          ],
        ),
      ),
    );
  }

  IconData _iconFor(String label) {
    switch (label) {
      case 'Home':
        return Icons.home_rounded;
      case 'School':
        return Icons.school_rounded;
      case 'Work':
        return Icons.work_rounded;
      default:
        return Icons.location_on_rounded;
    }
  }
}

class _AddressInputOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _AddressInputOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFFFFBF8),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: AppColors.primary),
            ],
          ),
        ),
      ),
    );
  }
}

class _LabelPicker extends StatelessWidget {
  final ValueChanged<String> onSelected;

  const _LabelPicker({required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 42,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const Text(
              'Save this location as',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _labelButton(Icons.home_rounded, 'Home'),
                _labelButton(Icons.school_rounded, 'School'),
                _labelButton(Icons.work_rounded, 'Work'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _labelButton(IconData icon, String label) {
    return Expanded(
      child: InkWell(
        onTap: () => onSelected(label),
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Column(
            children: [
              Icon(icon, color: AppColors.primary),
              const SizedBox(height: 5),
              Text(label),
            ],
          ),
        ),
      ),
    );
  }
}