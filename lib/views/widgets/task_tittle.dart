import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_app/providers/task_providers.dart';
import 'package:todo_app/views/widgets/app_widgets.dart';
import '../../models/task_model.dart';

class TaskTile extends StatelessWidget {
  final Task task;
  const TaskTile({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TaskProvider>(context, listen: false);

    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          // ── Checkbox ──────────────────────────────────
          GestureDetector(
            onTap: () => provider.toggleTask(task),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: task.completed ? AppColors.accent : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color:
                      task.completed ? AppColors.accent : AppColors.secondary,
                  width: 1.8,
                ),
              ),
              child: task.completed
                  ? const Icon(Icons.check_rounded,
                      color: AppColors.bg, size: 15)
                  : null,
            ),
          ),
          const SizedBox(width: 14),

          // ── Title + metadata ──────────────────────────
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
                    fontWeight: FontWeight.w500,
                    decoration: task.completed
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                    decorationColor: AppColors.secondary,
                  ),
                  child: Text(task.title,
                      maxLines: 2, overflow: TextOverflow.ellipsis),
                ),
                if (task.completed) ...[
                  const SizedBox(height: 4),
                  const Text('Completed',
                      style: TextStyle(
                          color: AppColors.success,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500)),
                ],
              ],
            ),
          ),

          // ── Actions ───────────────────────────────────
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Edit
              _TileIconButton(
                icon: Icons.edit_rounded,
                color: AppColors.accent,
                onTap: () => _openEditDialog(context, task, provider),
              ),
              const SizedBox(width: 8),
              // Delete
              _TileIconButton(
                icon: Icons.delete_outline_rounded,
                color: AppColors.error,
                onTap: () => _confirmDelete(context, task, provider),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Edit dialog ───────────────────────────────────────────────
  void _openEditDialog(BuildContext context, Task task, TaskProvider provider) {
    final ctrl = TextEditingController(text: task.title);
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.xl)),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.accentSoft,
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: const Icon(Icons.edit_rounded,
                          color: AppColors.accent, size: 18),
                    ),
                    const SizedBox(width: 12),
                    const Text('Edit Task', style: AppTextStyles.title),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),

                // Field
                AppTextField(
                  controller: ctrl,
                  label: 'Task title',
                  hint: 'Update your task…',
                  icon: Icons.task_alt_rounded,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty)
                      return 'Title cannot be empty';
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.lg),

                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: AppOutlinedButton(
                        label: 'Cancel',
                        height: 46,
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: _DialogUpdateButton(
                        formKey: formKey,
                        ctrl: ctrl,
                        task: task,
                        provider: provider,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Delete confirmation ───────────────────────────────────────
  void _confirmDelete(BuildContext context, Task task, TaskProvider provider) {
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
                'Are you sure you want to delete this task?\nThis action cannot be undone.',
                style: AppTextStyles.subtitle,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  Expanded(
                    child: AppOutlinedButton(
                      label: 'Cancel',
                      height: 46,
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: SizedBox(
                      height: 46,
                      child: ElevatedButton(
                        onPressed: () {
                          provider.deleteTask(task.id);
                          Navigator.pop(context);
                          AppSnackBar.show(context, 'Task deleted',
                              isError: true);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.error,
                          foregroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(AppRadius.lg)),
                          elevation: 0,
                        ),
                        child: const Text('Delete',
                            style: TextStyle(fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
//  Small icon button used in tile actions
// ════════════════════════════════════════════════════════════════

class _TileIconButton extends StatelessWidget {
  const _TileIconButton(
      {required this.icon, required this.color, required this.onTap});

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
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Icon(icon, color: color, size: 17),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
//  Update button with its own loading state (inside dialog)
// ════════════════════════════════════════════════════════════════

class _DialogUpdateButton extends StatefulWidget {
  const _DialogUpdateButton({
    required this.formKey,
    required this.ctrl,
    required this.task,
    required this.provider,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController ctrl;
  final Task task;
  final TaskProvider provider;

  @override
  State<_DialogUpdateButton> createState() => _DialogUpdateButtonState();
}

class _DialogUpdateButtonState extends State<_DialogUpdateButton> {
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
          disabledBackgroundColor: AppColors.accent.withOpacity(0.5),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg)),
          elevation: 0,
        ),
        child: _loading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                    color: AppColors.bg, strokeWidth: 2))
            : const Text('Update',
                style: TextStyle(fontWeight: FontWeight.w700)),
      ),
    );
  }

  Future<void> _handleUpdate() async {
    if (!widget.formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    await widget.provider.editTask(widget.task.id, widget.ctrl.text.trim());
    if (!mounted) return;
    Navigator.pop(context);
    AppSnackBar.show(context, 'Task updated!', isSuccess: true);
  }
}
