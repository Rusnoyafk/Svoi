import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/app_spacing.dart';
import '../../../core/models/poll_model.dart';
import '../../../core/providers/poll_provider.dart';
import '../../../core/services/announcement_service.dart' show LimitExceededException;
import '../../../features/auth/domain/auth_state.dart';
import '../../../features/auth/presentation/providers/auth_provider.dart';
import '../../../features/user/presentation/providers/user_provider.dart';

class CreatePollScreen extends ConsumerStatefulWidget {
  const CreatePollScreen({super.key});

  @override
  ConsumerState<CreatePollScreen> createState() => _CreatePollScreenState();
}

class _CreatePollScreenState extends ConsumerState<CreatePollScreen> {
  final _formKey = GlobalKey<FormState>();
  final _questionCtrl = TextEditingController();

  // Мінімум 2 варіанти при старті
  final List<TextEditingController> _optionCtrls = [
    TextEditingController(),
    TextEditingController(),
  ];

  int _durationDays = 3;
  GeoScope _geoScope = GeoScope.all;
  bool _loading = false;

  @override
  void dispose() {
    _questionCtrl.dispose();
    for (final c in _optionCtrls) {
      c.dispose();
    }
    super.dispose();
  }

  void _addOption() {
    if (_optionCtrls.length >= 5) return;
    setState(() => _optionCtrls.add(TextEditingController()));
  }

  void _removeOption(int index) {
    if (_optionCtrls.length <= 2) return;
    setState(() {
      _optionCtrls[index].dispose();
      _optionCtrls.removeAt(index);
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final filledOptions =
        _optionCtrls.where((c) => c.text.trim().isNotEmpty).toList();
    if (filledOptions.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Заповніть мінімум 2 варіанти відповіді')),
      );
      return;
    }

    final authState = ref.read(authProvider);
    if (authState is! AuthStateAuthenticated) return;
    final user = authState.user;
    final profile = ref.read(currentUserProfileProvider).value;

    setState(() => _loading = true);
    try {
      final now = DateTime.now();
      final endsAt = now.add(Duration(days: _durationDays));

      final options = List.generate(filledOptions.length, (i) {
        return PollOption(id: 'option_$i', text: filledOptions[i].text.trim());
      });

      final poll = PollModel(
        id: '',
        authorUid: user.uid,
        authorName: profile?.displayName ?? user.displayName ?? '',
        authorPhotoUrl: profile?.photoUrl ?? user.photoURL,
        question: _questionCtrl.text.trim(),
        options: options,
        geoScope: _geoScope,
        country: profile?.country ?? '',
        city: profile?.city,
        durationDays: _durationDays,
        createdAt: now,
        endsAt: endsAt,
      );

      await ref.read(pollServiceProvider).createPoll(poll);
      if (mounted) Navigator.pop(context);
    } on LimitExceededException catch (e) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Ліміт опитувань'),
            content: Text(e.message),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Зрозуміло')),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Помилка: $e')));
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
        title: const Text('Нове опитування'),
        actions: [
          TextButton(
            onPressed: _loading ? null : _submit,
            child: _loading
                ? SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: colorScheme.primary),
                  )
                : const Text('Створити'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            // ── Питання ────────────────────────────────────────────────────
            TextFormField(
              controller: _questionCtrl,
              decoration: const InputDecoration(
                labelText: 'Питання *',
                hintText: 'Що хочете дізнатися у спільноти?',
                alignLabelWithHint: true,
              ),
              maxLines: 3,
              maxLength: 200,
              inputFormatters: [LengthLimitingTextInputFormatter(200)],
              textCapitalization: TextCapitalization.sentences,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Введіть питання' : null,
            ),
            const SizedBox(height: AppSpacing.xl),

            // ── Варіанти відповідей ─────────────────────────────────────────
            Text('Варіанти відповідей *',
                style: textTheme.labelLarge?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w600,
                )),
            const SizedBox(height: AppSpacing.sm),

            ..._optionCtrls.asMap().entries.map((entry) {
              final i = entry.key;
              final ctrl = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text('${i + 1}',
                          style: textTheme.labelMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant)),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: TextFormField(
                        controller: ctrl,
                        decoration: InputDecoration(
                          hintText: 'Варіант ${i + 1}',
                          isDense: true,
                        ),
                        maxLength: 100,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(100)
                        ],
                        textCapitalization: TextCapitalization.sentences,
                      ),
                    ),
                    if (i >= 2) ...[
                      const SizedBox(width: AppSpacing.xs),
                      IconButton(
                        icon: Icon(Icons.remove_circle_outline,
                            color: colorScheme.error),
                        onPressed: () => _removeOption(i),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ],
                ),
              );
            }),

            if (_optionCtrls.length < 5)
              TextButton.icon(
                onPressed: _addOption,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Додати варіант'),
              ),
            const SizedBox(height: AppSpacing.xl),

            // ── Тривалість ─────────────────────────────────────────────────
            Text('Тривалість',
                style: textTheme.labelLarge?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w600,
                )),
            const SizedBox(height: AppSpacing.sm),
            SegmentedButton<int>(
              segments: const [
                ButtonSegment(value: 1, label: Text('1 день')),
                ButtonSegment(value: 3, label: Text('3 дні')),
                ButtonSegment(value: 7, label: Text('7 днів')),
              ],
              selected: {_durationDays},
              onSelectionChanged: (s) =>
                  setState(() => _durationDays = s.first),
            ),
            const SizedBox(height: AppSpacing.xl),

            // ── Гео-скоуп ──────────────────────────────────────────────────
            Text('Аудиторія',
                style: textTheme.labelLarge?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w600,
                )),
            const SizedBox(height: AppSpacing.sm),
            SegmentedButton<GeoScope>(
              segments: GeoScope.values
                  .map((g) => ButtonSegment(value: g, label: Text(g.label)))
                  .toList(),
              selected: {_geoScope},
              onSelectionChanged: (s) => setState(() => _geoScope = s.first),
            ),
            const SizedBox(height: AppSpacing.xxxl),

            // ── Кнопка ─────────────────────────────────────────────────────
            FilledButton(
              onPressed: _loading ? null : _submit,
              child: _loading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Створити опитування'),
            ),
          ],
        ),
      ),
    );
  }
}
