import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../auth/providers/auth_provider.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _fullNameController;
  late final TextEditingController _ageController;
  late final TextEditingController _regionController;
  late final TextEditingController _occupationController;

  String? _selectedGender;
  bool _isSaving = false;

  static const List<String> _genders = [
    'Male',
    'Female',
    'Other',
    'Prefer not to say',
  ];

  @override
  void initState() {
    super.initState();

    final user = ref.read(authProvider).valueOrNull;

    _fullNameController = TextEditingController(text: user?.fullName ?? '');

    _ageController = TextEditingController(text: user?.age?.toString() ?? '');

    _regionController = TextEditingController(text: user?.region ?? '');

    _occupationController = TextEditingController(text: user?.occupation ?? '');

    _selectedGender = user?.gender;
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _ageController.dispose();
    _regionController.dispose();
    _occupationController.dispose();

    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedGender == null || _selectedGender!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select your gender.')),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await ref
          .read(authProvider.notifier)
          .updateProfile(
            fullName: _fullNameController.text.trim(),
            age: int.parse(_ageController.text.trim()),
            gender: _selectedGender!,
            region: _regionController.text.trim(),
            occupation: _occupationController.text.trim(),
          );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully.')),
      );

      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to update profile. Please try again.')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).valueOrNull;

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile'), centerTitle: false),

      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ============================================================
                // Profile identity
                // ============================================================
                Center(
                  child: Column(
                    children: [
                      _InitialsAvatar(fullName: user?.fullName ?? ''),

                      const SizedBox(height: AppSpacing.md),

                      Text(
                        'Personal information',
                        style: AppTextStyles.sectionTitle,
                      ),

                      const SizedBox(height: 4),

                      Text(
                        'Keep your profile information up to date.',
                        style: AppTextStyles.caption,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.xl),

                // ============================================================
                // Full name
                // ============================================================
                _FieldLabel('Full name'),

                const SizedBox(height: AppSpacing.xs),

                TextFormField(
                  controller: _fullNameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    hintText: 'Enter your full name',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().length < 2) {
                      return 'Please enter your full name.';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: AppSpacing.lg),

                // ============================================================
                // Email - read only
                // ============================================================
                _FieldLabel('Email'),

                const SizedBox(height: AppSpacing.xs),

                TextFormField(
                  initialValue: user?.email ?? '',
                  readOnly: true,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.email_outlined),
                    suffixIcon: Icon(Icons.lock_outline, size: 18),
                  ),
                ),

                const SizedBox(height: AppSpacing.xs),

                Text(
                  'Email cannot be changed once registered',
                  style: AppTextStyles.caption,
                ),

                const SizedBox(height: AppSpacing.lg),

                // ============================================================
                // Age
                // ============================================================
                _FieldLabel('Age'),

                const SizedBox(height: AppSpacing.xs),

                TextFormField(
                  controller: _ageController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    hintText: 'Enter your age',
                    prefixIcon: Icon(Icons.cake_outlined),
                  ),
                  validator: (value) {
                    final age = int.tryParse(value?.trim() ?? '');

                    if (age == null) {
                      return 'Please enter your age.';
                    }

                    if (age < 13 || age > 100) {
                      return 'Please enter a valid age.';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: AppSpacing.lg),

                // ============================================================
                // Gender
                // ============================================================
                _FieldLabel('Gender'),

                const SizedBox(height: AppSpacing.xs),

                DropdownButtonFormField<String>(
                  initialValue: _selectedGender,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.wc_outlined),
                  ),
                  items: _genders.map((gender) {
                    return DropdownMenuItem(value: gender, child: Text(gender));
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedGender = value;
                    });
                  },
                ),

                const SizedBox(height: AppSpacing.lg),

                // ============================================================
                // Region
                // ============================================================
                _FieldLabel('Region'),

                const SizedBox(height: AppSpacing.xs),

                TextFormField(
                  controller: _regionController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    hintText: 'e.g. Maharashtra, India',
                    prefixIcon: Icon(Icons.location_on_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your region.';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: AppSpacing.lg),

                // ============================================================
                // Occupation
                // ============================================================
                _FieldLabel('Occupation'),

                const SizedBox(height: AppSpacing.xs),

                TextFormField(
                  controller: _occupationController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    hintText: 'e.g. Student',
                    prefixIcon: Icon(Icons.work_outline),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your occupation.';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: AppSpacing.xxl),

                // ============================================================
                // Save button
                // ============================================================
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _isSaving ? null : _saveProfile,
                    child: _isSaving
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Save Changes'),
                  ),
                ),

                const SizedBox(height: AppSpacing.md),

                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: _isSaving
                        ? null
                        : () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                ),

                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// Field label
// ============================================================================

class _FieldLabel extends StatelessWidget {
  final String text;

  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
    );
  }
}

// ============================================================================
// Initials avatar
// ============================================================================

class _InitialsAvatar extends StatelessWidget {
  final String fullName;

  const _InitialsAvatar({required this.fullName});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 42,
      backgroundColor: AppColors.primaryLight,
      child: Text(
        _getInitials(fullName),
        style: AppTextStyles.cardTitle.copyWith(
          color: AppColors.primary,
          fontSize: 26,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();

    if (parts.isEmpty) {
      return '?';
    }

    if (parts.length == 1) {
      final first = parts.first;

      if (first.length >= 2) {
        return first.substring(0, 2).toUpperCase();
      }

      return first.substring(0, 1).toUpperCase();
    }

    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }
}
