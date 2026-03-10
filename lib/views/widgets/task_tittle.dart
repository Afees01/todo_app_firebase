import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_app/providers/task_providers.dart';
import 'package:todo_app/views/widgets/app_widgets.dart';
import '../../models/task_model.dart';

class TaskTile extends StatelessWidget {
  final Task task;
  const TaskTile({super.key, required this.task});

  static const _priorityLabel = ['Low', 'Medium', 'High'];
  static const _priorityColor = [
    Color(0xFF4CAF50),
    Color(0xFFFFA726),
    Color(0xFFE05555),
  ];
  static const _priorityIcon = [
    Icons.arrow_downward_rounded,
    Icons.remove_rounded,
    Icons.arrow_upward_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TaskProvider>(context, listen: false);
    final p        = task.priority.clamp(0, 2);
    final pColor   = _priorityColor[p];
    final pLabel   = _priorityLabel[p];
    final pIcon    = _priorityIcon[p];
    final hasDue   = task.dueDate != null;
    final isOverdue = hasDue && !task.completed &&
        task.dueDate!.isBefore(DateTime.now());

    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Row 1: checkbox  title  actions ─────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Animated checkbox
              GestureDetector(
                onTap: () => provider.toggleTask(task),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 26,
                  height: 26,
                  margin: const EdgeInsets.only(top: 2),
                  decoration: BoxDecoration(
                    color: task.completed
                        ? AppColors.accent
                        : Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: task.completed
                          ? AppColors.accent
                          : AppColors.secondary,
                      width: 1.8,
                    ),
                  ),
                  child: task.completed
                      ? const Icon(Icons.check_rounded,
                          color: AppColors.bg, size: 15)
                      : null,
                ),
              ),
              const SizedBox(width: 12),

              // Title + note
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 200),
                      style: TextStyle(
                        color: task.completed
                            ? AppColors.secondary
                            : AppColors.primary,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        decoration: task.completed
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                        decorationColor: AppColors.secondary,
                      ),
                      child: Text(task.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis),
                    ),
                    // Note
                    if (task.note != null && task.note!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        task.note!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.secondary,
                          fontSize: 12.5,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Edit + Delete
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _TileIconButton(
                    icon: Icons.edit_rounded,
                    color: AppColors.accent,
                    onTap: () =>
                        _openEditDialog(context, task, provider),
                  ),
                  const SizedBox(width: 6),
                  _TileIconButton(
                    icon: Icons.delete_outline_rounded,
                    color: AppColors.error,
                    onTap: () =>
                        _confirmDelete(context, task, provider),
                  ),
                ],
              ),
            ],
          ),

          // ── Divider ──────────────────────────────────
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(
                color: AppColors.inputBorder,
                thickness: 1,
                height: 1),
          ),

          // ── Row 2: priority  due date  status ────────
          Row(
            children: [
              // Priority
              _MetaChip(
                  icon: pIcon, label: pLabel, color: pColor),
              const SizedBox(width: 8),

              // Due date
              if (hasDue)
                _MetaChip(
                  icon: isOverdue
                      ? Icons.warning_amber_rounded
                      : Icons.calendar_today_rounded,
                  label: _fmt(task.dueDate!),
                  color: isOverdue
                      ? AppColors.error
                      : AppColors.secondary,
                ),

              const Spacer(),

              // Status
              _MetaChip(
                icon: task.completed
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked_rounded,
                label: task.completed ? 'Done' : 'Pending',
                color: task.completed
                    ? AppColors.success
                    : AppColors.warning,
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  // ══════════════════════════════════════════════════════════════
  //  Edit dialog — title, note, priority, due date
  // ══════════════════════════════════════════════════════════════
  void _openEditDialog(
      BuildContext context, Task task, TaskProvider provider) {
    final titleCtrl = TextEditingController(text: task.title);
    final noteCtrl  = TextEditingController(text: task.note ?? '');
    final formKey   = GlobalKey<FormState>();
    int priority    = task.priority.clamp(0, 2);
    DateTime? due   = task.dueDate;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => Dialog(
          backgroundColor: AppColors.card,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.xl)),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Header ─────────────────────────────
                  Row(children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.accentSoft,
                        borderRadius:
                            BorderRadius.circular(AppRadius.sm),
                      ),
                      child: const Icon(Icons.edit_rounded,
                          color: AppColors.accent, size: 18),
                    ),
                    const SizedBox(width: 12),
                    const Text('Edit Task',
                        style: AppTextStyles.title),
                  ]),
                  const SizedBox(height: AppSpacing.lg),

                  // ── Title ──────────────────────────────
                  AppTextField(
                    controller: titleCtrl,
                    label: 'Task title',
                    hint: 'What needs to be done?',
                    icon: Icons.task_alt_rounded,
                    validator: (v) =>
                        (v == null || v.trim().isEmpty)
                            ? 'Title cannot be empty'
                            : null,
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // ── Note ───────────────────────────────
                  AppTextField(
                    controller: noteCtrl,
                    label: 'Note (optional)',
                    hint: 'Add more details…',
                    icon: Icons.notes_rounded,
                    maxLines: 3,
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // ── Priority ───────────────────────────
                  const Text('Priority',
                      style: AppTextStyles.caption),
                  const SizedBox(height: 8),
                  Row(
                    children: List.generate(3, (i) {
                      final col = _priorityColor[i];
                      final ico = _priorityIcon[i];
                      final lbl = _priorityLabel[i];
                      final sel = priority == i;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () =>
                              setLocal(() => priority = i),
                          child: AnimatedContainer(
                            duration:
                                const Duration(milliseconds: 200),
                            margin: EdgeInsets.only(
                                right: i < 2 ? 8 : 0),
                            padding: const EdgeInsets.symmetric(
                                vertical: 12),
                            decoration: BoxDecoration(
                              color: sel
                                  ? col.withOpacity(0.15)
                                  : AppColors.surface,
                              borderRadius:
                                  BorderRadius.circular(AppRadius.md),
                              border: Border.all(
                                color: sel
                                    ? col
                                    : AppColors.inputBorder,
                                width: sel ? 1.5 : 1,
                              ),
                            ),
                            child: Column(children: [
                              Icon(ico,
                                  color: sel
                                      ? col
                                      : AppColors.secondary,
                                  size: 18),
                              const SizedBox(height: 4),
                              Text(lbl,
                                  style: TextStyle(
                                    color: sel
                                        ? col
                                        : AppColors.secondary,
                                    fontSize: 11,
                                    fontWeight: sel
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                  )),
                            ]),
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // ── Due date ───────────────────────────
                  const Text('Due date',
                      style: AppTextStyles.caption),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: ctx,
                        initialDate: due ?? DateTime.now(),
                        firstDate: DateTime.now().subtract(
                            const Duration(days: 365)),
                        lastDate: DateTime.now()
                            .add(const Duration(days: 365)),
                        builder: (c, child) => Theme(
                          data: ThemeData.dark().copyWith(
                            colorScheme: const ColorScheme.dark(
                              primary: AppColors.accent,
                              onPrimary: AppColors.bg,
                              surface: AppColors.card,
                              onSurface: AppColors.primary,
                            ),
                            dialogBackgroundColor:
                                AppColors.surface,
                          ),
                          child: child!,
                        ),
                      );
                      if (picked != null)
                        setLocal(() => due = picked);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 14),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius:
                            BorderRadius.circular(AppRadius.md),
                        border: Border.all(
                            color: AppColors.inputBorder),
                      ),
                      child: Row(children: [
                        const Icon(Icons.calendar_today_rounded,
                            color: AppColors.accent, size: 18),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            due == null
                                ? 'Pick a due date'
                                : '${due!.day.toString().padLeft(2, '0')}/${due!.month.toString().padLeft(2, '0')}/${due!.year}',
                            style: TextStyle(
                              color: due == null
                                  ? AppColors.secondary
                                  : AppColors.primary,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        if (due != null)
                          GestureDetector(
                            onTap: () =>
                                setLocal(() => due = null),
                            child: const Icon(
                                Icons.close_rounded,
                                color: AppColors.secondary,
                                size: 16),
                          ),
                      ]),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // ── Buttons ────────────────────────────
                  Row(children: [
                    Expanded(
                      child: AppOutlinedButton(
                        label: 'Cancel',
                        height: 46,
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _DialogUpdateButton(
                        formKey: formKey,
                        titleCtrl: titleCtrl,
                        noteCtrl: noteCtrl,
                        getPriority: () => priority,
                        getDueDate: () => due,
                        task: task,
                        provider: provider,
                      ),
                    ),
                  ]),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  //  Delete confirmation
  // ══════════════════════════════════════════════════════════════
  void _confirmDelete(
      BuildContext context, Task task, TaskProvider provider) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.xl)),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.delete_outline_rounded,
                    color: AppColors.error, size: 28),
              ),
              const SizedBox(height: AppSpacing.md),
              const Text('Delete Task', style: AppTextStyles.title),
              const SizedBox(height: 8),
              const Text(
                'Are you sure you want to delete\nthis task? This cannot be undone.',
                style: AppTextStyles.subtitle,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(children: [
                Expanded(
                  child: AppOutlinedButton(
                    label: 'Cancel',
                    height: 46,
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: SizedBox(
                    height: 46,
                    child: ElevatedButton(
                      onPressed: () {
                        provider.deleteTask(task.id);
                        Navigator.pop(context);
                        AppSnackBar.show(
                            context, 'Task deleted',
                            isError: true);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                        foregroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                AppRadius.lg)),
                        elevation: 0,
                      ),
                      child: const Text('Delete',
                          style: TextStyle(
                              fontWeight: FontWeight.w700)),
                    ),
                  ),
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
//  Meta chip  (priority / due date / status)
// ════════════════════════════════════════════════════════════════

class _MetaChip extends StatelessWidget {
  const _MetaChip(
      {required this.icon,
      required this.label,
      required this.color});
  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 12),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                  color: color,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
//  Tile icon button
// ════════════════════════════════════════════════════════════════

class _TileIconButton extends StatelessWidget {
  const _TileIconButton(
      {required this.icon,
      required this.color,
      required this.onTap});
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: color.withOpacity(0.10),
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Icon(icon, color: color, size: 17),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
//  Update button with loading state
// ════════════════════════════════════════════════════════════════

class _DialogUpdateButton extends StatefulWidget {
  const _DialogUpdateButton({
    required this.formKey,
    required this.titleCtrl,
    required this.noteCtrl,
    required this.getPriority,
    required this.getDueDate,
    required this.task,
    required this.provider,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController titleCtrl;
  final TextEditingController noteCtrl;
  final int Function() getPriority;
  final DateTime? Function() getDueDate;
  final Task task;
  final TaskProvider provider;

  @override
  State<_DialogUpdateButton> createState() =>
      _DialogUpdateButtonState();
}

class _DialogUpdateButtonState
    extends State<_DialogUpdateButton> {
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 46,
      child: ElevatedButton(
        onPressed: _loading ? null : _handleUpdate,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: AppColors.bg,
          disabledBackgroundColor:
              AppColors.accent.withOpacity(0.5),
          shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(AppRadius.lg)),
          elevation: 0,
        ),
        child: _loading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                    color: AppColors.bg, strokeWidth: 2))
            : const Text('Update',
                style:
                    TextStyle(fontWeight: FontWeight.w700)),
      ),
    );
  }

  Future<void> _handleUpdate() async {
    if (!widget.formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    await widget.provider.editTask(
      widget.task.id,
      widget.titleCtrl.text.trim(),
      note: widget.noteCtrl.text.trim(),
      priority: widget.getPriority(),
      dueDate: widget.getDueDate(),
    );

    if (!mounted) return;
    Navigator.pop(context);
    AppSnackBar.show(context, 'Task updated!', isSuccess: true);
  }
}