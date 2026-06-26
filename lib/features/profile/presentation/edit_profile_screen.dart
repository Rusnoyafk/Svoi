import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/app_spacing.dart';
import '../../../features/auth/domain/auth_state.dart';
import '../../../features/auth/presentation/providers/auth_provider.dart';
import '../../../features/user/presentation/providers/user_provider.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _bioCtrl;
  late final TextEditingController _countryCtrl;
  late final TextEditingController _cityCtrl;
  late final TextEditingController _oblastCtrl;
  late final TextEditingController _originCityCtrl;

  bool _loading = false;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController();
    _bioCtrl = TextEditingController();
    _countryCtrl = TextEditingController();
    _cityCtrl = TextEditingController();
    _oblastCtrl = TextEditingController();
    _originCityCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _bioCtrl.dispose();
    _countryCtrl.dispose();
    _cityCtrl.dispose();
    _oblastCtrl.dispose();
    _originCityCtrl.dispose();
    super.dispose();
  }

  void _initFromProfile() {
    if (_initialized) return;
    final profile = ref.read(currentUserProfileProvider).value;
    if (profile == null) return;
    _nameCtrl.text = profile.displayName;
    _bioCtrl.text = profile.bio ?? '';
    _countryCtrl.text = profile.country ?? '';
    _cityCtrl.text = profile.city ?? '';
    _oblastCtrl.text = profile.originOblast ?? '';
    _originCityCtrl.text = profile.originCity ?? '';
    _initialized = true;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final authState = ref.read(authProvider);
    if (authState is! AuthStateAuthenticated) return;

    setState(() => _loading = true);
    try {
      await ref.read(userRepositoryProvider).updateProfile(
        authState.user.uid,
        {
          'displayName': _nameCtrl.text.trim(),
          'bio': _bioCtrl.text.trim().isEmpty ? null : _bioCtrl.text.trim(),
          'country': _countryCtrl.text.trim().isEmpty ? null : _countryCtrl.text.trim(),
          'city': _cityCtrl.text.trim().isEmpty ? null : _cityCtrl.text.trim(),
          'originOblast': _oblastCtrl.text.trim().isEmpty ? null : _oblastCtrl.text.trim(),
          'originCity': _originCityCtrl.text.trim().isEmpty ? null : _originCityCtrl.text.trim(),
        },
      );
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Помилка збереження: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    _initFromProfile();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Редагувати профіль'),
        actions: [
          TextButton(
            onPressed: _loading ? null : _save,
            child: _loading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Зберегти'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            // ── Основна інформація ────────────────────────────────────────
            _SectionLabel("Основне"),
            const SizedBox(height: AppSpacing.sm),
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: "Ім'я *"),
              textCapitalization: TextCapitalization.words,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? "Введіть ім'я" : null,
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _bioCtrl,
              decoration: const InputDecoration(
                labelText: 'Про себе',
                hintText: 'Коротко про вас (до 200 символів)',
              ),
              maxLines: 3,
              maxLength: 200,
              inputFormatters: [LengthLimitingTextInputFormatter(200)],
              validator: (v) {
                if (v != null && v.length > 200) {
                  return 'Максимум 200 символів';
                }
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.xl),

            // ── Де я зараз ───────────────────────────────────────────────
            _SectionLabel('Де я зараз'),
            const SizedBox(height: AppSpacing.sm),
            TextFormField(
              controller: _countryCtrl,
              decoration: const InputDecoration(labelText: 'Країна'),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _cityCtrl,
              decoration: const InputDecoration(labelText: 'Місто'),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: AppSpacing.xl),

            // ── Звідки я ─────────────────────────────────────────────────
            _SectionLabel('Звідки я (Україна)'),
            const SizedBox(height: AppSpacing.sm),
            TextFormField(
              controller: _oblastCtrl,
              decoration: const InputDecoration(labelText: 'Область'),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _originCityCtrl,
              decoration: const InputDecoration(labelText: 'Місто/село'),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: AppSpacing.xxxl),

            // ── Зберегти ─────────────────────────────────────────────────
            FilledButton(
              onPressed: _loading ? null : _save,
              child: _loading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Зберегти'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.w600,
          ),
    );
  }
}
