import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_app/providers/task_providers.dart';
import 'package:todo_app/views/widgets/app_widgets.dart';

class AddTaskView extends StatefulWidget {
  const AddTaskView({super.key});

  @override
  State<AddTaskView> createState() => _AddTaskViewState();
}

class _AddTaskViewState extends State<AddTaskView>
    with SingleTickerProviderStateMixin {
  final _formKey    = GlobalKey<FormState>();
  final _title      = TextEditingController();
  final _note       = TextEditingController();
  bool _isLoading   = false;

  // Priority selection
  int _priority = 1; // 0 = Low, 1 = Medium, 2 = High

  // Due date
  DateTime? _dueDate;

  late AnimationController _animController;
  late Animation<double>   _fadeAnim;
  late Animation<Offset>   _slideAnim;

  static const _priorities = [
    {'label': 'Low',    'color': Color(0xFF4CAF50), 'icon': Icons.arrow_downward_rounded},
    {'label': 'Medium', 'color': Color(0xFFFFA726), 'icon': Icons.remove_rounded},
    {'label': 'High',   'color': Color(0xFFE05555), 'icon': Icons.arrow_upward_rounded},
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _fadeAnim  = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _title.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (ctx, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppColors.accent,
            onPrimary: AppColors.bg,
            surface: AppColors.card,
            onSurface: AppColors.primary,
          ),
          dialogBackgroundColor: AppColors.surface,
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  Future<void> _handleAddTask() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final provider = Provider.of<TaskProvider>(context, listen: false);

    try {
      await provider.addTask(
        title: _title.text.trim(),
        note: _note.text.trim(),
        priority: _priority,
        dueDate: _dueDate,
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      // Pop first, then show snackbar on the previous screen
      Navigator.pop(context, true); // pass `true` so HomeView can react

      AppSnackBar.show(context, 'Task added successfully!', isSuccess: true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      AppSnackBar.show(context, 'Error: $e', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final priorityColor =
        _priorities[_priority]['color'] as Color;
    final priorityLabel =
        _priorities[_priority]['label'] as String;

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        leading: AppIconButton(
          icon: Icons.close_rounded,
          onTap: () => Navigator.pop(context),
          bgColor: AppColors.card,
        ),
        leadingWidth: 64,
        title: const Text(
          'New Task',
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          // Badge showing selected priority
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: AppBadge(label: priorityLabel, color: priorityColor),
          ),
        ],
      ),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: SlideTransition(
            position: _slideAnim,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg, vertical: AppSpacing.md),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Task title ─────────────────────────
                    AppCard(
                      child: Column(
                        children: [
                          AppTextField(
                            controller: _title,
                            label: 'Task title',
                            hint: 'What needs to be done?',
                            icon: Icons.task_alt_rounded,
                            validator: (v) {
                              if (v == null || v.trim().isEmpty)
                                return 'Task title is required';
                              if (v.trim().length < 3)
                                return 'Title must be at least 3 characters';
                              return null;
                            },
                          ),
                          const SizedBox(height: AppSpacing.md),

                          // Note / description
                          AppTextField(
                            controller: _note,
                            label: 'Note (optional)',
                            hint: 'Add more details…',
                            icon: Icons.notes_rounded,
                            maxLines: 3,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // ── Priority selector ──────────────────
                    const Text('Priority', style: AppTextStyles.caption),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: List.generate(_priorities.length, (i) {
                        final selected = _priority == i;
                        final color =
                            _priorities[i]['color'] as Color;
                        final icon =
                            _priorities[i]['icon'] as IconData;
                        final lbl =
                            _priorities[i]['label'] as String;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _priority = i),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin: EdgeInsets.only(
                                  right: i < 2 ? AppSpacing.sm : 0),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 14),
                              decoration: BoxDecoration(
                                color: selected
                                    ? color.withOpacity(0.15)
                                    : AppColors.card,
                                borderRadius: BorderRadius.circular(
                                    AppRadius.md),
                                border: Border.all(
                                  color: selected
                                      ? color
                                      : AppColors.inputBorder,
                                  width: selected ? 1.5 : 1,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Icon(icon,
                                      color: selected
                                          ? color
                                          : AppColors.secondary,
                                      size: 20),
                                  const SizedBox(height: 4),
                                  Text(
                                    lbl,
                                    style: TextStyle(
                                      color: selected
                                          ? color
                                          : AppColors.secondary,
                                      fontSize: 12,
                                      fontWeight: selected
                                          ? FontWeight.w600
                                          : FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // ── Due date picker ────────────────────
                    const Text('Due date', style: AppTextStyles.caption),
                    const SizedBox(height: AppSpacing.sm),
                    GestureDetector(
                      onTap: _pickDate,
                      child: AppCard(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today_rounded,
                                color: AppColors.accent, size: 20),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _dueDate == null
                                    ? 'Pick a due date'
                                    : '${_dueDate!.day} / ${_dueDate!.month} / ${_dueDate!.year}',
                                style: TextStyle(
                                  color: _dueDate == null
                                      ? AppColors.secondary
                                      : AppColors.primary,
                                  fontSize: 14.5,
                                ),
                              ),
                            ),
                            if (_dueDate != null)
                              GestureDetector(
                                onTap: () =>
                                    setState(() => _dueDate = null),
                                child: const Icon(
                                    Icons.close_rounded,
                                    color: AppColors.secondary,
                                    size: 18),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    // ── Submit button ──────────────────────
                    AppPrimaryButton(
                      label: 'Add Task',
                      icon: Icons.add_task_rounded,
                      isLoading: _isLoading,
                      onPressed: _handleAddTask,
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // ── Cancel ─────────────────────────────
                    AppOutlinedButton(
                      label: 'Cancel',
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(height: AppSpacing.md),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}