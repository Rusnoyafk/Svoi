import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/app_category.dart';
import '../../../core/app_spacing.dart';
import '../../../core/models/announcement_model.dart';
import '../../../core/providers/announcement_provider.dart';
import '../../../core/services/announcement_service.dart';
import '../../../features/auth/domain/auth_state.dart';
import '../../../features/auth/presentation/providers/auth_provider.dart';
import '../../../features/user/presentation/providers/user_provider.dart';

class CreateAnnouncementScreen extends ConsumerStatefulWidget {
  const CreateAnnouncementScreen({super.key, this.existing});

  /// Якщо передано — режим редагування
  final AnnouncementModel? existing;

  @override
  ConsumerState<CreateAnnouncementScreen> createState() =>
      _CreateAnnouncementScreenState();
}

class _CreateAnnouncementScreenState
    extends ConsumerState<CreateAnnouncementScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _contactCtrl = TextEditingController();

  AnnouncementCategory? _selectedCategory;
  bool _loading = false;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final ann = widget.existing!;
      _titleCtrl.text = ann.title;
      _descCtrl.text = ann.description;
      _contactCtrl.text = ann.contactInfo ?? '';
      _selectedCategory = ann.category;
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _contactCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Оберіть категорію')),
      );
      return;
    }

    final authState = ref.read(authProvider);
    if (authState is! AuthStateAuthenticated) return;
    final user = authState.user;
    final profile = ref.read(currentUserProfileProvider).value;

    setState(() => _loading = true);
    try {
      final service = ref.read(announcementServiceProvider);
      if (_isEditing) {
        await service.updateAnnouncement(widget.existing!.id, {
          'title': _titleCtrl.text.trim(),
          'description': _descCtrl.text.trim(),
          'category': _selectedCategory!.name,
          'contactInfo': _contactCtrl.text.trim().isEmpty
              ? null
              : _contactCtrl.text.trim(),
        });
      } else {
        final now = DateTime.now();
        final ann = AnnouncementModel(
          id: '',
          authorUid: user.uid,
          authorName: profile?.displayName ?? user.displayName ?? '',
          authorPhotoUrl: profile?.photoUrl ?? user.photoURL,
          title: _titleCtrl.text.trim(),
          description: _descCtrl.text.trim(),
          category: _selectedCategory!,
          country: profile?.country ?? '',
          city: profile?.city,
          contactInfo: _contactCtrl.text.trim().isEmpty
              ? null
              : _contactCtrl.text.trim(),
          createdAt: now,
          expiresAt: now.add(const Duration(days: 30)),
        );
        await service.createAnnouncement(ann);
      }
      if (mounted) Navigator.pop(context);
    } on LimitExceededException catch (e) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Ліміт оголошень'),
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

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Редагувати' : 'Нове оголошення'),
        actions: [
          TextButton(
            onPressed: _loading ? null : _submit,
            child: _loading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(_isEditing ? 'Зберегти' : 'Опублікувати'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            // ── Категорія ─────────────────────────────────────────────────
            Text(
              'Категорія *',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: AppSpacing.sm),
            _CategorySelector(
              selected: _selectedCategory,
              onSelected: (cat) => setState(() => _selectedCategory = cat),
            ),
            const SizedBox(height: AppSpacing.xl),

            // ── Заголовок ─────────────────────────────────────────────────
            TextFormField(
              controller: _titleCtrl,
              decoration: const InputDecoration(
                labelText: 'Заголовок *',
                hintText: 'Коротко суть оголошення',
              ),
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
                hintText: 'Детальний опис, умови, вимоги…',
                alignLabelWithHint: true,
              ),
              maxLines: 6,
              maxLength: 1000,
              inputFormatters: [LengthLimitingTextInputFormatter(1000)],
              textCapitalization: TextCapitalization.sentences,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Введіть опис' : null,
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
                  : Text(_isEditing ? 'Зберегти зміни' : 'Опублікувати'),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Вибір категорії через wrapped chips ───────────────────────────────────────

class _CategorySelector extends StatelessWidget {
  const _CategorySelector({required this.selected, required this.onSelected});

  final AnnouncementCategory? selected;
  final ValueChanged<AnnouncementCategory> onSelected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: AnnouncementCategory.values.map((cat) {
        final isSelected = selected == cat;
        return GestureDetector(
          onTap: () => onSelected(cat),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
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
                Icon(
                  cat.icon,
                  size: AppSpacing.iconMd,
                  color: isSelected ? cat.color : colorScheme.onSurfaceVariant,
                ),
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
