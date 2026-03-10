import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_app/controllers/auth_controller.dart';
import 'package:todo_app/providers/task_providers.dart';
import 'package:todo_app/views/widgets/app_widgets.dart';
import 'package:todo_app/views/tasks/add_task_view.dart';
import 'package:todo_app/views/auth/login_view.dart';
import 'package:todo_app/views/widgets/task_tittle.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  final _authController = AuthController();
  bool _isLoggingOut = false;

  int _filter = 0;
  static const _filters = ['All', 'Pending', 'Done'];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnim =
        CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();

    Future.microtask(
        () => Provider.of<TaskProvider>(context, listen: false).loadTasks());
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _openAddTask(TaskProvider provider) async {
    final added = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const AddTaskView()),
    );
    if (added == true && mounted) {
      AppSnackBar.show(context, 'Task added!', isSuccess: true);
    }
  }

  // ── Logout ──────────────────────────────────────────────
  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
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
                child: const Icon(Icons.logout_rounded,
                    color: AppColors.error, size: 26),
              ),
              const SizedBox(height: AppSpacing.md),
              const Text('Sign Out', style: AppTextStyles.title),
              const SizedBox(height: 8),
              const Text(
                'Are you sure you want to\nsign out of your account?',
                style: AppTextStyles.subtitle,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(children: [
                Expanded(
                  child: AppOutlinedButton(
                    label: 'Cancel',
                    height: 46,
                    onPressed: () => Navigator.pop(context, false),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: SizedBox(
                    height: 46,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                        foregroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(AppRadius.lg)),
                        elevation: 0,
                      ),
                      child: const Text('Sign Out',
                          style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ),
                ),
              ]),
            ],
          ),
        ),
      ),
    );

    if (confirm != true || !mounted) return;
    setState(() => _isLoggingOut = true);

    try {
      await _authController.logout();
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginView()),
        (route) => false, // clear entire stack
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoggingOut = false);
      AppSnackBar.show(context, 'Failed to sign out. Try again.',
          isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TaskProvider>(context);
    final tasks    = provider.tasks;

    final total    = tasks.length;
    final done     = tasks.where((t) => t.completed).length;
    final pending  = total - done;
    final progress = total == 0 ? 0.0 : done / total;

    final filtered = tasks.where((t) {
      if (_filter == 1) return !t.completed;
      if (_filter == 2) return t.completed;
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ──────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('My Tasks',
                              style: AppTextStyles.headline),
                          const SizedBox(height: 4),
                          Text(
                            '$pending task${pending == 1 ? '' : 's'} remaining',
                            style: AppTextStyles.subtitle,
                          ),
                        ],
                      ),
                    ),

                    // ── Logout button ──────────────────────
                    GestureDetector(
                      onTap: _isLoggingOut ? null : _handleLogout,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.error.withOpacity(0.10),
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: AppColors.error.withOpacity(0.35),
                              width: 1.2),
                        ),
                        child: _isLoggingOut
                            ? const Padding(
                                padding: EdgeInsets.all(12),
                                child: CircularProgressIndicator(
                                    color: AppColors.error,
                                    strokeWidth: 2),
                              )
                            : const Icon(Icons.logout_rounded,
                                color: AppColors.error, size: 20),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // ── Progress card ────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg),
                child: AppCard(
                  glowColor: AppColors.accent,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Today's Progress",
                              style: AppTextStyles.caption),
                          Text(
                            '$done / $total completed',
                            style: const TextStyle(
                              color: AppColors.accent,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(99),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 6,
                          backgroundColor: AppColors.inputBorder,
                          valueColor: const AlwaysStoppedAnimation(
                              AppColors.accent),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          _StatChip(
                              label: 'Total',
                              value: '$total',
                              color: AppColors.primary),
                          const SizedBox(width: AppSpacing.sm),
                          _StatChip(
                              label: 'Done',
                              value: '$done',
                              color: AppColors.success),
                          const SizedBox(width: AppSpacing.sm),
                          _StatChip(
                              label: 'Pending',
                              value: '$pending',
                              color: AppColors.warning),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // ── Filter tabs ──────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg),
                child: Row(
                  children: List.generate(_filters.length, (i) {
                    final active = _filter == i;
                    return GestureDetector(
                      onTap: () => setState(() => _filter = i),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: EdgeInsets.only(
                            right: i < 2 ? AppSpacing.sm : 0),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 8),
                        decoration: BoxDecoration(
                          color: active
                              ? AppColors.accent
                              : AppColors.card,
                          borderRadius:
                              BorderRadius.circular(AppRadius.xxl),
                          border: Border.all(
                            color: active
                                ? AppColors.accent
                                : AppColors.inputBorder,
                          ),
                        ),
                        child: Text(
                          _filters[i],
                          style: TextStyle(
                            color: active
                                ? AppColors.bg
                                : AppColors.secondary,
                            fontSize: 13,
                            fontWeight: active
                                ? FontWeight.w700
                                : FontWeight.w400,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // ── Task list ────────────────────────────────
              Expanded(
                child: filtered.isEmpty
                    ? _EmptyState(filter: _filters[_filter])
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(
                            AppSpacing.lg,
                            0,
                            AppSpacing.lg,
                            AppSpacing.xl),
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: AppSpacing.sm),
                        itemBuilder: (_, i) {
                          final task = filtered[i];
                          return _AnimatedTaskTile(
                            index: i,
                            child: TaskTile(task: task),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton:
          _AddTaskFAB(onTap: () => _openAddTask(provider)),
    );
  }
}

// ════════════════════════════════════════════════════════════════
//  Animated task tile wrapper
// ════════════════════════════════════════════════════════════════

class _AnimatedTaskTile extends StatefulWidget {
  const _AnimatedTaskTile({required this.index, required this.child});
  final int index;
  final Widget child;

  @override
  State<_AnimatedTaskTile> createState() => _AnimatedTaskTileState();
}

class _AnimatedTaskTileState extends State<_AnimatedTaskTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _c;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _fade = CurvedAnimation(parent: _c, curve: Curves.easeOut);
    _slide =
        Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero)
            .animate(
                CurvedAnimation(parent: _c, curve: Curves.easeOut));
    Future.delayed(Duration(milliseconds: 60 * widget.index), () {
      if (mounted) _c.forward();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
        opacity: _fade,
        child:
            SlideTransition(position: _slide, child: widget.child),
      );
}

// ════════════════════════════════════════════════════════════════
//  Stat chip
// ════════════════════════════════════════════════════════════════

class _StatChip extends StatelessWidget {
  const _StatChip(
      {required this.label,
      required this.value,
      required this.color});
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Text(value,
                style: TextStyle(
                    color: color,
                    fontSize: 20,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 2),
            Text(label,
                style: const TextStyle(
                    color: AppColors.secondary, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
//  Empty state
// ════════════════════════════════════════════════════════════════

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.filter});
  final String filter;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
              color: AppColors.accentSoft,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.task_alt_rounded,
                color: AppColors.accent, size: 36),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            filter == 'All' ? 'No tasks yet' : 'No $filter tasks',
            style: AppTextStyles.title,
          ),
          const SizedBox(height: 8),
          Text(
            filter == 'All'
                ? 'Tap + to add your first task'
                : 'Switch filter to see other tasks',
            style: AppTextStyles.subtitle,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
//  Custom FAB
// ════════════════════════════════════════════════════════════════

class _AddTaskFAB extends StatelessWidget {
  const _AddTaskFAB({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          color: AppColors.accent,
          borderRadius: BorderRadius.circular(AppRadius.xxl),
          boxShadow: [
            BoxShadow(
              color: AppColors.accent.withOpacity(0.35),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add_rounded, color: AppColors.bg, size: 22),
            SizedBox(width: 8),
            Text(
              'Add Task',
              style: TextStyle(
                color: AppColors.bg,
                fontSize: 15,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}