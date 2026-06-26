import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/app_category.dart';
import '../../../core/app_spacing.dart';
import '../../../core/models/event_model.dart';
import '../../../core/providers/event_provider.dart';
import '../../../core/services/announcement_service.dart' show LimitExceededException;
import '../../../features/auth/domain/auth_state.dart';
import '../../../features/auth/presentation/providers/auth_provider.dart';
import '../../../features/user/presentation/providers/user_provider.dart';

class CreateEventScreen extends ConsumerStatefulWidget {
  const CreateEventScreen({super.key, this.existing});

  final EventModel? existing;

  @override
  ConsumerState<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends ConsumerState<CreateEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _linkCtrl = TextEditingController();
  final _contactCtrl = TextEditingController();
  final _maxCtrl = TextEditingController();

  EventCategory? _selectedCategory;
  DateTime? _eventDate;
  DateTime? _eventEndDate;
  bool _isOnline = false;
  bool _loading = false;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final e = widget.existing!;
      _titleCtrl.text = e.title;
      _descCtrl.text = e.description;
      _addressCtrl.text = e.address ?? '';
      _linkCtrl.text = e.onlineLink ?? '';
      _contactCtrl.text = e.contactInfo ?? '';
      _maxCtrl.text = e.maxParticipants?.toString() ?? '';
      _selectedCategory = e.category;
      _eventDate = e.eventDate;
      _eventEndDate = e.eventEndDate;
      _isOnline = e.isOnline;
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _addressCtrl.dispose();
    _linkCtrl.dispose();
    _contactCtrl.dispose();
    _maxCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool isEnd}) async {
    final initial = isEnd ? (_eventEndDate ?? _eventDate ?? DateTime.now()) : (_eventDate ?? DateTime.now());
    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
    );
    if (time == null || !mounted) return;
    final result = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    setState(() {
      if (isEnd) {
        _eventEndDate = result;
      } else {
        _eventDate = result;
        // Скидаємо дату завершення якщо вона стала раніше початку
        if (_eventEndDate != null && _eventEndDate!.isBefore(result)) {
          _eventEndDate = null;
        }
      }
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Оберіть категорію')),
      );
      return;
    }
    if (_eventDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Вкажіть дату і час івенту')),
      );
      return;
    }

    final authState = ref.read(authProvider);
    if (authState is! AuthStateAuthenticated) return;
    final user = authState.user;
    final profile = ref.read(currentUserProfileProvider).value;

    setState(() => _loading = true);
    try {
      final service = ref.read(eventServiceProvider);
      if (_isEditing) {
        await service.updateEvent(widget.existing!.id, {
          'title': _titleCtrl.text.trim(),
          'description': _descCtrl.text.trim(),
          'category': _selectedCategory!.name,
          'eventDate': _eventDate!.toIso8601String(),
          'eventEndDate': _eventEndDate?.toIso8601String(),
          'isOnline': _isOnline,
          'onlineLink': _isOnline && _linkCtrl.text.trim().isNotEmpty
              ? _linkCtrl.text.trim()
              : null,
          'address': !_isOnline && _addressCtrl.text.trim().isNotEmpty
              ? _addressCtrl.text.trim()
              : null,
          'maxParticipants': _maxCtrl.text.trim().isNotEmpty
              ? int.tryParse(_maxCtrl.text.trim())
              : null,
          'contactInfo': _contactCtrl.text.trim().isNotEmpty
              ? _contactCtrl.text.trim()
              : null,
        });
      } else {
        final now = DateTime.now();
        final event = EventModel(
          id: '',
          authorUid: user.uid,
          authorName: profile?.displayName ?? user.displayName ?? '',
          authorPhotoUrl: profile?.photoUrl ?? user.photoURL,
          title: _titleCtrl.text.trim(),
          description: _descCtrl.text.trim(),
          category: _selectedCategory!,
          country: profile?.country ?? '',
          city: profile?.city,
          address: !_isOnline && _addressCtrl.text.trim().isNotEmpty
              ? _addressCtrl.text.trim()
              : null,
          eventDate: _eventDate!,
          eventEndDate: _eventEndDate,
          isOnline: _isOnline,
          onlineLink: _isOnline && _linkCtrl.text.trim().isNotEmpty
              ? _linkCtrl.text.trim()
              : null,
          maxParticipants: _maxCtrl.text.trim().isNotEmpty
              ? int.tryParse(_maxCtrl.text.trim())
              : null,
          contactInfo: _contactCtrl.text.trim().isNotEmpty
              ? _contactCtrl.text.trim()
              : null,
          createdAt: now,
        );
        await service.createEvent(event);
      }
      if (mounted) Navigator.pop(context);
    } on LimitExceededException catch (e) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Ліміт івентів'),
            content: Text(e.message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Зрозуміло'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Помилка: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Редагувати' : 'Новий івент'),
        actions: [
          TextButton(
            onPressed: _loading ? null : _submit,
            child: _loading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(_isEditing ? 'Зберегти' : 'Створити'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            // ── Категорія ─────────────────────────────────────────────────
            _Label('Категорія *'),
            const SizedBox(height: AppSpacing.sm),
            _CategorySelector(
              selected: _selectedCategory,
              onSelected: (cat) => setState(() => _selectedCategory = cat),
            ),
            const SizedBox(height: AppSpacing.xl),

            // ── Заголовок ─────────────────────────────────────────────────
            TextFormField(
              controller: _titleCtrl,
              decoration: const InputDecoration(labelText: 'Заголовок *'),
              maxLength: 100,
              inputFormatters: [LengthLimitingTextInputFormatter(100)],
              textCapitalization: TextCapitalization.sentences,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Введіть заголовок' : null,
            ),
            const SizedBox(height: AppSpacing.md),

            // ── Опис ──────────────────────────────────────────────────────
            TextFormField(
              controller: _descCtrl,
              decoration: const InputDecoration(
                labelText: 'Опис *',
                alignLabelWithHint: true,
              ),
              maxLines: 5,
              maxLength: 1000,
              inputFormatters: [LengthLimitingTextInputFormatter(1000)],
              textCapitalization: TextCapitalization.sentences,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Введіть опис' : null,
            ),
            const SizedBox(height: AppSpacing.xl),

            // ── Дата і час ────────────────────────────────────────────────
            _Label('Дата і час *'),
            const SizedBox(height: AppSpacing.sm),
            _DateButton(
              label: _eventDate == null
                  ? 'Вибрати дату початку'
                  : _formatDateTime(_eventDate!),
              icon: Icons.calendar_today_outlined,
              onTap: () => _pickDate(isEnd: false),
            ),
            const SizedBox(height: AppSpacing.sm),
            _DateButton(
              label: _eventEndDate == null
                  ? 'Дата завершення (необов\'язково)'
                  : _formatDateTime(_eventEndDate!),
              icon: Icons.calendar_today_outlined,
              onTap: () => _pickDate(isEnd: true),
              isSecondary: true,
            ),
            const SizedBox(height: AppSpacing.xl),

            // ── Онлайн/Офлайн ────────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Онлайн івент', style: textTheme.titleSmall),
                      Text(
                        'Проводиться у відеоконференції',
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: _isOnline,
                  onChanged: (v) => setState(() => _isOnline = v),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            // ── Онлайн або офлайн поле ────────────────────────────────────
            if (_isOnline)
              TextFormField(
                controller: _linkCtrl,
                decoration: const InputDecoration(
                  labelText: 'Посилання на зустріч',
                  hintText: 'https://meet.google.com/...',
                ),
                keyboardType: TextInputType.url,
              )
            else
              TextFormField(
                controller: _addressCtrl,
                decoration: const InputDecoration(
                  labelText: 'Адреса або місце',
                  hintText: 'вул. Хрещатик 1, Варшава',
                ),
                textCapitalization: TextCapitalization.sentences,
              ),
            const SizedBox(height: AppSpacing.xl),

            // ── Кількість учасників ───────────────────────────────────────
            TextFormField(
              controller: _maxCtrl,
              decoration: const InputDecoration(
                labelText: 'Максимум учасників',
                hintText: 'Залиште порожнім — без обмежень',
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            const SizedBox(height: AppSpacing.md),

            // ── Контакт ───────────────────────────────────────────────────
            TextFormField(
              controller: _contactCtrl,
              decoration: const InputDecoration(
                labelText: 'Контактна інформація',
                hintText: '+48 000 000 000 або @telegram',
              ),
            ),
            const SizedBox(height: AppSpacing.xxxl),

            // ── Кнопка ────────────────────────────────────────────────────
            FilledButton(
              onPressed: _loading ? null : _submit,
              child: _loading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : Text(_isEditing ? 'Зберегти зміни' : 'Створити івент'),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    final months = [
      '', 'січ.', 'лют.', 'бер.', 'квіт.', 'трав.', 'черв.',
      'лип.', 'серп.', 'вер.', 'жовт.', 'лист.', 'груд.',
    ];
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '${dt.day} ${months[dt.month]} ${dt.year}, $h:$m';
  }
}

// ── Допоміжні віджети ─────────────────────────────────────────────────────────

class _Label extends StatelessWidget {
  const _Label(this.text);

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

class _DateButton extends StatelessWidget {
  const _DateButton({
    required this.label,
    required this.icon,
    required this.onTap,
    this.isSecondary = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool isSecondary;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg, vertical: AppSpacing.md),
        decoration: BoxDecoration(
          color: isSecondary
              ? colorScheme.surfaceContainerLow
              : colorScheme.surfaceContainerLowest,
          border: Border.all(color: colorScheme.outlineVariant),
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        child: Row(
          children: [
            Icon(icon,
                size: AppSpacing.iconMd,
                color: isSecondary
                    ? colorScheme.onSurfaceVariant
                    : colorScheme.primary),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: isSecondary
                          ? colorScheme.onSurfaceVariant
                          : colorScheme.onSurface,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategorySelector extends StatelessWidget {
  const _CategorySelector({required this.selected, required this.onSelected});

  final EventCategory? selected;
  final ValueChanged<EventCategory> onSelected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: EventCategory.values.map((cat) {
        final isSelected = selected == cat;
        return GestureDetector(
          onTap: () => onSelected(cat),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md, vertical: AppSpacing.sm),
            decoration: BoxDecoration(
              color: isSelected
                  ? cat.color.withValues(alpha: 0.15)
                  : colorScheme.surfaceContainerLow,
              border: Border.all(
                color: isSelected ? cat.color : colorScheme.outlineVariant,
                width: isSelected ? 1.5 : 1,
              ),
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(cat.icon,
                    size: AppSpacing.iconMd,
                    color: isSelected
                        ? cat.color
                        : colorScheme.onSurfaceVariant),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  cat.label,
                  style: textTheme.labelMedium?.copyWith(
                    color: isSelected ? cat.color : colorScheme.onSurface,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
