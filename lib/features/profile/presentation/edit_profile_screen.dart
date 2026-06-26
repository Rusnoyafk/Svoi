import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/app_spacing.dart';
import '../../../core/providers/location_provider.dart';
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

  final _nameCtrl = TextEditingController();
  final _bioCtrl = TextEditingController();
  final _countryCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();

  // Каскадний вибір "Звідки я"
  String? _selectedOblast;
  String? _selectedRaion;
  String? _selectedOriginCity;

  bool _loading = false;
  bool _initialized = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _bioCtrl.dispose();
    _countryCtrl.dispose();
    _cityCtrl.dispose();
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
    _selectedOblast = profile.originOblast;
    _selectedRaion = profile.originRaion;
    _selectedOriginCity = profile.originCity;
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
          'originOblast': _selectedOblast,
          'originRaion': _selectedRaion,
          'originCity': _selectedOriginCity,
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
            ),
            const SizedBox(height: AppSpacing.xl),

            // ── Де я зараз ───────────────────────────────────────────────
            _SectionLabel('Де я зараз'),
            const SizedBox(height: AppSpacing.sm),
            _CountryAutocomplete(
              initialValue: _countryCtrl.text,
              onChanged: (v) => _countryCtrl.text = v,
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
            _CascadeLocationPicker(
              selectedOblast: _selectedOblast,
              selectedRaion: _selectedRaion,
              selectedCity: _selectedOriginCity,
              onOblastChanged: (v) => setState(() {
                _selectedOblast = v;
                _selectedRaion = null;
                _selectedOriginCity = null;
              }),
              onRaionChanged: (v) => setState(() {
                _selectedRaion = v;
                _selectedOriginCity = null;
              }),
              onCityChanged: (v) => setState(() => _selectedOriginCity = v),
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

// ── Каскадний вибір Область → Район → Місто ───────────────────────────────────

class _CascadeLocationPicker extends ConsumerWidget {
  const _CascadeLocationPicker({
    required this.selectedOblast,
    required this.selectedRaion,
    required this.selectedCity,
    required this.onOblastChanged,
    required this.onRaionChanged,
    required this.onCityChanged,
  });

  final String? selectedOblast;
  final String? selectedRaion;
  final String? selectedCity;
  final ValueChanged<String?> onOblastChanged;
  final ValueChanged<String?> onRaionChanged;
  final ValueChanged<String?> onCityChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final oblastsAsync = ref.watch(oblastsProvider);
    final raionsAsync = selectedOblast != null
        ? ref.watch(raionsProvider(selectedOblast!))
        : const AsyncData<List<String>>([]);
    final citiesAsync = (selectedOblast != null && selectedRaion != null)
        ? ref.watch(citiesProvider((selectedOblast!, selectedRaion!)))
        : const AsyncData<List<String>>([]);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Область
        oblastsAsync.when(
          loading: () => const LinearProgressIndicator(),
          error: (e, _) => Text('Помилка: $e'),
          data: (oblasts) => _SearchableField(
            label: 'Область',
            value: selectedOblast,
            options: oblasts,
            onSelected: onOblastChanged,
          ),
        ),
        if (selectedOblast != null) ...[
          const SizedBox(height: AppSpacing.md),
          // Район
          raionsAsync.when(
            loading: () => const LinearProgressIndicator(),
            error: (e, _) => Text('Помилка: $e'),
            data: (raions) => _SearchableField(
              label: 'Район',
              value: selectedRaion,
              options: raions,
              onSelected: onRaionChanged,
            ),
          ),
        ],
        if (selectedOblast != null && selectedRaion != null) ...[
          const SizedBox(height: AppSpacing.md),
          // Місто / село
          citiesAsync.when(
            loading: () => const LinearProgressIndicator(),
            error: (e, _) => Text('Помилка: $e'),
            data: (cities) => _SearchableField(
              label: 'Місто / село',
              value: selectedCity,
              options: cities,
              onSelected: onCityChanged,
            ),
          ),
        ],
        // Підсумок вибраного
        if (selectedOblast != null) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(
            _buildSummary(),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
        ],
      ],
    );
  }

  String _buildSummary() {
    final parts = <String>[];
    if (selectedOblast != null) parts.add('$selectedOblast обл.');
    if (selectedRaion != null) parts.add('$selectedRaion р-н');
    if (selectedCity != null) parts.add(selectedCity!);
    return parts.join(' › ');
  }
}

// ── Поле з автопідбором ───────────────────────────────────────────────────────

class _SearchableField extends StatelessWidget {
  const _SearchableField({
    required this.label,
    required this.value,
    required this.options,
    required this.onSelected,
  });

  final String label;
  final String? value;
  final List<String> options;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) {
    return Autocomplete<String>(
      initialValue: value != null ? TextEditingValue(text: value!) : null,
      optionsBuilder: (textEditingValue) {
        final query = textEditingValue.text.toLowerCase();
        if (query.isEmpty) return options;
        return options.where((o) => o.toLowerCase().contains(query));
      },
      onSelected: onSelected,
      fieldViewBuilder: (ctx, ctrl, focusNode, onSubmit) {
        return TextFormField(
          controller: ctrl,
          focusNode: focusNode,
          decoration: InputDecoration(
            labelText: label,
            suffixIcon: ctrl.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, size: 18),
                    onPressed: () {
                      ctrl.clear();
                      onSelected(null);
                    },
                  )
                : const Icon(Icons.arrow_drop_down),
          ),
          textCapitalization: TextCapitalization.words,
        );
      },
      optionsViewBuilder: (ctx, onSel, opts) {
        final list = opts.toList();
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 240),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: list.length,
                itemBuilder: (_, i) => ListTile(
                  dense: true,
                  title: Text(list[i]),
                  onTap: () => onSel(list[i]),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ── Autocomplete для країн ────────────────────────────────────────────────────

class _CountryAutocomplete extends StatelessWidget {
  const _CountryAutocomplete({
    required this.initialValue,
    required this.onChanged,
  });

  final String initialValue;
  final ValueChanged<String> onChanged;

  static const _countries = [
    'Австрія', 'Австралія', 'Азербайджан', 'Албанія', 'Бельгія',
    'Білорусь', 'Болгарія', 'Боснія і Герцеговина', 'Велика Британія',
    'Греція', 'Грузія', 'Данія', 'Естонія', 'Ізраїль', 'Іспанія',
    'Італія', 'Канада', 'Кіпр', 'Латвія', 'Литва', 'Люксембург',
    'Молдова', 'Нідерланди', 'Німеччина', 'Норвегія', 'Польща',
    'Португалія', 'Румунія', 'Словаччина', 'Словенія', 'США',
    'Туреччина', 'Угорщина', 'Україна', 'Фінляндія', 'Франція',
    'Хорватія', 'Чехія', 'Швейцарія', 'Швеція',
  ];

  @override
  Widget build(BuildContext context) {
    return Autocomplete<String>(
      initialValue: initialValue.isNotEmpty
          ? TextEditingValue(text: initialValue)
          : null,
      optionsBuilder: (val) {
        final q = val.text.toLowerCase();
        if (q.isEmpty) return _countries;
        return _countries.where((c) => c.toLowerCase().contains(q));
      },
      onSelected: onChanged,
      fieldViewBuilder: (ctx, ctrl, focusNode, _) => TextFormField(
        controller: ctrl,
        focusNode: focusNode,
        decoration: const InputDecoration(labelText: 'Країна'),
        onChanged: onChanged,
        textCapitalization: TextCapitalization.words,
      ),
      optionsViewBuilder: (ctx, onSel, opts) {
        final list = opts.toList();
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 200),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: list.length,
                itemBuilder: (_, i) => ListTile(
                  dense: true,
                  title: Text(list[i]),
                  onTap: () => onSel(list[i]),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ── Заголовок секції ──────────────────────────────────────────────────────────

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
