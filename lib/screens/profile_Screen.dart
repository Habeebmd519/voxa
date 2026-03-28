import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ── Colors ────────────────────────────────────────────────────────────────────
class C {
  static const bgGreen = Color(0xFFC5DBA0);
  static const cardGreen = Color(0xFF5A7A3A);
  static const cardGreenDark = Color(0xFF4A6A2A);
  static const fieldBg = Color(0xFFF2F8F2);
  static const fieldBgEdit = Color(0xFFEFF8EF);
  static const fieldLabel = Color(0xFFAAAAAA);
  static const fieldText = Color(0xFF1A1A1A);
  static const purple = Color(0xFF7C4DFF);
  static const dividerColor = Color(0x33FFFFFF);
  static const chipBorder = Color(0xFFDDDDDD);
  static const chipSelected = Color(0xFF5A7A3A);
}

// ── Models ────────────────────────────────────────────────────────────────────
const kRoles = ['Developer', 'Designer', 'Business', 'Student', 'Other'];

class ProjectItem {
  final TextEditingController nameCtrl;
  final TextEditingController descCtrl;
  ProjectItem()
    : nameCtrl = TextEditingController(),
      descCtrl = TextEditingController();
  ProjectItem.filled(String name, String desc)
    : nameCtrl = TextEditingController(text: name),
      descCtrl = TextEditingController(text: desc);
  void dispose() {
    nameCtrl.dispose();
    descCtrl.dispose();
  }
}

// ─── Screen ───────────────────────────────────────────────────────────────────
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  bool _editing = false;

  // Basic fields
  final _nameCtrl = TextEditingController(text: 'Habeeb');
  final _emailCtrl = TextEditingController(text: 'habeebmd519@gmail.com');
  final _passCtrl = TextEditingController(text: 'password');
  final _userIdCtrl = TextEditingController(text: 'OmHo0cUb');

  // New fields
  String? _selectedRole;
  final _placeCtrl = TextEditingController();
  final _domainCtrl = TextEditingController();
  final List<ProjectItem> _projects = [];

  // Snapshot for cancel
  late String _snapName, _snapEmail, _snapPass, _snapPlace, _snapDomain;
  late String? _snapRole;
  late List<Map<String, String>> _snapProjects;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _userIdCtrl.dispose();
    _placeCtrl.dispose();
    _domainCtrl.dispose();
    for (final p in _projects) p.dispose();
    super.dispose();
  }

  void _startEdit() {
    _snapName = _nameCtrl.text;
    _snapEmail = _emailCtrl.text;
    _snapPass = _passCtrl.text;
    _snapPlace = _placeCtrl.text;
    _snapDomain = _domainCtrl.text;
    _snapRole = _selectedRole;
    _snapProjects = _projects
        .map((p) => {'name': p.nameCtrl.text, 'desc': p.descCtrl.text})
        .toList();
    setState(() => _editing = true);
    HapticFeedback.selectionClick();
  }

  void _saveEdit() {
    HapticFeedback.lightImpact();
    setState(() => _editing = false);
    _showToast('Profile updated ✓');
  }

  void _cancelEdit() {
    _nameCtrl.text = _snapName;
    _emailCtrl.text = _snapEmail;
    _passCtrl.text = _snapPass;
    _placeCtrl.text = _snapPlace;
    _domainCtrl.text = _snapDomain;
    // Restore projects
    for (final p in _projects) p.dispose();
    _projects.clear();
    for (final s in _snapProjects) {
      _projects.add(ProjectItem.filled(s['name']!, s['desc']!));
    }
    setState(() {
      _editing = false;
      _selectedRole = _snapRole;
    });
    HapticFeedback.lightImpact();
  }

  void _addProject() {
    HapticFeedback.selectionClick();
    setState(() => _projects.add(ProjectItem()));
  }

  void _removeProject(int i) {
    HapticFeedback.lightImpact();
    _projects[i].dispose();
    setState(() => _projects.removeAt(i));
  }

  void _showToast(String msg) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: C.cardGreenDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
        margin: const EdgeInsets.only(bottom: 24, left: 40, right: 40),
        duration: const Duration(seconds: 2),
        content: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.check_circle_outline,
              color: Colors.white,
              size: 16,
            ),
            const SizedBox(width: 8),
            Text(
              msg,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: C.bgGreen,
        body: Column(
          children: [
            // ── Green hero ─────────────────────────────────────────────────
            _HeroZone(
              editing: _editing,
              nameCtrl: _nameCtrl,
              onEdit: _startEdit,
              onSave: _saveEdit,
              onCancel: _cancelEdit,
            ),

            // ── White sheet ───────────────────────────────────────────────
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                ),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Drag handle
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          margin: const EdgeInsets.only(bottom: 22),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),

                      // ── Basic fields ──────────────────────────────────
                      _sectionLabel('ACCOUNT INFO'),
                      const SizedBox(height: 10),
                      _ProfileField(
                        label: 'NAME',
                        controller: _nameCtrl,
                        editing: _editing,
                        icon: Icons.person_outline,
                      ),
                      const SizedBox(height: 12),
                      _ProfileField(
                        label: 'EMAIL',
                        controller: _emailCtrl,
                        editing: _editing,
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 12),
                      _ProfileField(
                        label: 'PASSWORD',
                        controller: _passCtrl,
                        editing: _editing,
                        icon: Icons.lock_outline,
                        obscure: true,
                      ),
                      const SizedBox(height: 12),
                      _ProfileField(
                        label: 'USER ID',
                        controller: _userIdCtrl,
                        editing: false,
                        icon: Icons.tag,
                        readonlyHint: true,
                      ),

                      const SizedBox(height: 26),
                      _divider(),
                      const SizedBox(height: 22),

                      // ── Role ──────────────────────────────────────────
                      _sectionLabel('ROLE'),
                      const SizedBox(height: 12),
                      _RolePicker(
                        selected: _selectedRole,
                        editing: _editing,
                        onSelect: (r) => setState(() => _selectedRole = r),
                      ),

                      const SizedBox(height: 22),

                      // ── Place ─────────────────────────────────────────
                      _sectionLabel('DETAILS'),
                      const SizedBox(height: 10),
                      _ProfileField(
                        label: 'PLACE',
                        controller: _placeCtrl,
                        editing: _editing,
                        icon: Icons.location_on_outlined,
                        keyboardType: TextInputType.text,
                      ),
                      const SizedBox(height: 12),
                      _ProfileField(
                        label: 'DOMAIN',
                        controller: _domainCtrl,
                        editing: _editing,
                        icon: Icons.language_outlined,
                      ),

                      const SizedBox(height: 26),
                      _divider(),
                      const SizedBox(height: 22),

                      // ── Portfolio ─────────────────────────────────────
                      Row(
                        children: [
                          _sectionLabel('PORTFOLIO'),
                          const Spacer(),
                          if (_editing)
                            GestureDetector(
                              onTap: _addProject,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 7,
                                ),
                                decoration: BoxDecoration(
                                  color: C.cardGreen,
                                  borderRadius: BorderRadius.circular(50),
                                  boxShadow: [
                                    BoxShadow(
                                      color: C.cardGreen.withOpacity(0.3),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.add,
                                      color: Colors.white,
                                      size: 14,
                                    ),
                                    SizedBox(width: 5),
                                    Text(
                                      'Add Project',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Project list
                      if (_projects.isEmpty)
                        _EmptyPortfolio(editing: _editing)
                      else
                        ...List.generate(
                          _projects.length,
                          (i) => Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: _ProjectCard(
                              index: i,
                              project: _projects[i],
                              editing: _editing,
                              onRemove: () => _removeProject(i),
                            ),
                          ),
                        ),

                      const SizedBox(height: 28),
                      _divider(),
                      const SizedBox(height: 22),

                      // ── Bottom actions ────────────────────────────────
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 280),
                        child: _editing
                            ? _EditActions(
                                key: const ValueKey('edit'),
                                onSave: _saveEdit,
                                onCancel: _cancelEdit,
                              )
                            : _LogoutButton(
                                key: const ValueKey('logout'),
                                onTap: () => _showToast('Logged out'),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ── Bottom nav ────────────────────────────────────────────────
            _BottomNav(safeBottom: mq.padding.bottom),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) => Text(
    text,
    style: const TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.w800,
      letterSpacing: 1.8,
      color: C.fieldLabel,
    ),
  );

  Widget _divider() => Container(height: 1, color: const Color(0xFFEEEEEE));
}

// ─── Hero Zone ────────────────────────────────────────────────────────────────
class _HeroZone extends StatelessWidget {
  final bool editing;
  final TextEditingController nameCtrl;
  final VoidCallback onEdit, onSave, onCancel;
  const _HeroZone({
    required this.editing,
    required this.nameCtrl,
    required this.onEdit,
    required this.onSave,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    return Container(
      padding: EdgeInsets.only(top: top + 12, left: 18, right: 18),
      color: C.bgGreen,
      child: Column(
        children: [
          // App bar
          Row(
            children: [
              _CircleBtn(
                color: C.cardGreenDark,
                child: const Icon(Icons.menu, color: Colors.white, size: 22),
              ),
              const Spacer(),
              Text(
                'Hi, ${nameCtrl.text}',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const Spacer(),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                child: editing
                    ? _CircleBtn(
                        key: const ValueKey('done'),
                        color: C.cardGreenDark,
                        onTap: onSave,
                        child: const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 22,
                        ),
                      )
                    : _CircleBtn(
                        key: const ValueKey('edit'),
                        color: Colors.white,
                        onTap: onEdit,
                        child: const Icon(
                          Icons.edit_outlined,
                          color: Color(0xFF333333),
                          size: 20,
                        ),
                      ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Profile card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: C.cardGreen,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    // Avatar
                    Stack(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                            image: const DecorationImage(
                              image: NetworkImage(
                                'https://picsum.photos/seed/flowers/200',
                              ),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            width: 26,
                            height: 26,
                            decoration: BoxDecoration(
                              color: C.cardGreenDark,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          editing
                              ? TextField(
                                  controller: nameCtrl,
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                  cursorColor: Colors.white,
                                  decoration: const InputDecoration(
                                    isDense: true,
                                    contentPadding: EdgeInsets.zero,
                                    border: InputBorder.none,
                                  ),
                                )
                              : Text(
                                  nameCtrl.text,
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                          const SizedBox(height: 3),
                          const Text(
                            'NEW YORK',
                            style: TextStyle(
                              fontSize: 11,
                              letterSpacing: 1.5,
                              color: Colors.white70,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: const Text(
                              'habeebmd519@gmail.com',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Divider(color: Colors.white.withOpacity(0.2), thickness: 1),
                const SizedBox(height: 12),
                Row(
                  children: const [
                    Expanded(
                      child: _StatItem(value: '221', label: 'MESSAGES'),
                    ),
                    _VDivider(),
                    Expanded(
                      child: _StatItem(value: '48', label: 'CONTACTS'),
                    ),
                    _VDivider(),
                    Expanded(
                      child: _StatItem(value: '5', label: 'GROUPS'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 0),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value, label;
  const _StatItem({required this.value, required this.label});
  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(
        value,
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
      ),
      const SizedBox(height: 2),
      Text(
        label,
        style: const TextStyle(
          fontSize: 9,
          letterSpacing: 1.2,
          color: Colors.white70,
          fontWeight: FontWeight.w600,
        ),
      ),
    ],
  );
}

class _VDivider extends StatelessWidget {
  const _VDivider();
  @override
  Widget build(BuildContext context) =>
      Container(width: 1, height: 36, color: Colors.white.withOpacity(0.2));
}

class _CircleBtn extends StatelessWidget {
  final Color color;
  final Widget child;
  final VoidCallback? onTap;
  const _CircleBtn({
    super.key,
    required this.color,
    required this.child,
    this.onTap,
  });
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(child: child),
    ),
  );
}

// ─── Profile Field ────────────────────────────────────────────────────────────
class _ProfileField extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final bool editing, obscure, readonlyHint;
  final TextInputType keyboardType;
  final IconData icon;
  const _ProfileField({
    required this.label,
    required this.controller,
    required this.editing,
    required this.icon,
    this.obscure = false,
    this.readonlyHint = false,
    this.keyboardType = TextInputType.text,
  });
  @override
  State<_ProfileField> createState() => _ProfileFieldState();
}

class _ProfileFieldState extends State<_ProfileField> {
  bool _obscured = true;
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 230),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: widget.editing ? C.fieldBgEdit : C.fieldBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: widget.editing
              ? C.cardGreen.withOpacity(0.45)
              : Colors.transparent,
          width: 1.5,
        ),
        boxShadow: widget.editing
            ? [
                BoxShadow(
                  color: C.cardGreen.withOpacity(0.1),
                  blurRadius: 12,
                  offset: const Offset(0, 3),
                ),
              ]
            : [],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(
              widget.label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.0,
                color: C.fieldLabel,
              ),
            ),
          ),
          Expanded(
            child: TextField(
              controller: widget.controller,
              enabled: widget.editing && !widget.readonlyHint,
              obscureText: widget.obscure && _obscured,
              keyboardType: widget.keyboardType,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: widget.readonlyHint
                    ? const Color(0xFF9E9E9E)
                    : C.fieldText,
              ),
              cursorColor: C.cardGreen,
              decoration: InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.zero,
                border: InputBorder.none,
                hintText: widget.editing
                    ? 'Enter ${widget.label.toLowerCase()}'
                    : null,
                hintStyle: const TextStyle(
                  color: Color(0xFFBBBBBB),
                  fontSize: 14,
                ),
                suffixIcon: widget.obscure && widget.editing
                    ? GestureDetector(
                        onTap: () => setState(() => _obscured = !_obscured),
                        child: Icon(
                          _obscured
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          size: 18,
                          color: const Color(0xFF9E9E9E),
                        ),
                      )
                    : null,
              ),
            ),
          ),
          if (!widget.editing && widget.readonlyHint)
            const Padding(
              padding: EdgeInsets.only(left: 6),
              child: Icon(
                Icons.lock_outline,
                size: 14,
                color: Color(0xFFCCCCCC),
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Role Picker ─────────────────────────────────────────────────────────────
class _RolePicker extends StatelessWidget {
  final String? selected;
  final bool editing;
  final void Function(String) onSelect;
  const _RolePicker({
    required this.selected,
    required this.editing,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    // In view mode show only selected or placeholder
    if (!editing) {
      if (selected == null) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: C.fieldBg,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Row(
            children: [
              Icon(Icons.work_outline, color: C.fieldLabel, size: 18),
              SizedBox(width: 10),
              Text(
                'No role selected',
                style: TextStyle(fontSize: 14, color: C.fieldLabel),
              ),
            ],
          ),
        );
      }
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: C.fieldBg,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            const Icon(Icons.work_outline, color: C.cardGreen, size: 18),
            const SizedBox(width: 10),
            Text(
              selected!,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: C.fieldText,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: C.cardGreen.withOpacity(0.12),
                borderRadius: BorderRadius.circular(50),
              ),
              child: const Text(
                'Role',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: C.cardGreen,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Edit mode: chip grid
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: kRoles.map((role) {
        final isSelected = selected == role;
        return GestureDetector(
          onTap: () => onSelect(role),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
            decoration: BoxDecoration(
              color: isSelected ? C.cardGreen : Colors.white,
              borderRadius: BorderRadius.circular(50),
              border: Border.all(
                color: isSelected ? C.cardGreen : C.chipBorder,
                width: 1.5,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: C.cardGreen.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 3),
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isSelected) ...[
                  const Icon(Icons.check, color: Colors.white, size: 13),
                  const SizedBox(width: 5),
                ],
                Text(
                  role,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : const Color(0xFF555555),
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

// ─── Empty Portfolio ──────────────────────────────────────────────────────────
class _EmptyPortfolio extends StatelessWidget {
  final bool editing;
  const _EmptyPortfolio({required this.editing});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
      decoration: BoxDecoration(
        color: C.fieldBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE0E0E0),
          style: BorderStyle.none,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.folder_open_outlined,
            size: 36,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 10),
          Text(
            editing
                ? 'Tap "Add Project" to add your work'
                : 'No projects added yet',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade500,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Project Card ─────────────────────────────────────────────────────────────
class _ProjectCard extends StatelessWidget {
  final int index;
  final ProjectItem project;
  final bool editing;
  final VoidCallback onRemove;
  const _ProjectCard({
    required this.index,
    required this.project,
    required this.editing,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: editing
              ? C.cardGreen.withOpacity(0.3)
              : const Color(0xFFE8E8E8),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: editing
                ? C.cardGreen.withOpacity(0.08)
                : Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            decoration: BoxDecoration(
              color: C.fieldBg,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(17),
              ),
              border: const Border(
                bottom: BorderSide(color: Color(0xFFE8E8E8)),
              ),
            ),
            child: Row(
              children: [
                // Number badge
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: C.cardGreen,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      (index + 1).toString().padLeft(2, '0'),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: project.nameCtrl,
                    enabled: editing,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: C.fieldText,
                    ),
                    cursorColor: C.cardGreen,
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                      border: InputBorder.none,
                      hintText: editing
                          ? 'Project name...'
                          : 'Untitled Project',
                      hintStyle: const TextStyle(
                        color: Color(0xFFBBBBBB),
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                if (editing)
                  GestureDetector(
                    onTap: onRemove,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF0EE),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFFD4614A).withOpacity(0.25),
                        ),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.close,
                          size: 14,
                          color: Color(0xFFD4614A),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Description
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'DESCRIPTION',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                    color: C.fieldLabel,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: project.descCtrl,
                  enabled: editing,
                  maxLines: 3,
                  minLines: 2,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF5C5248),
                    height: 1.6,
                  ),
                  cursorColor: C.cardGreen,
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: editing
                        ? const EdgeInsets.all(12)
                        : EdgeInsets.zero,
                    border: editing
                        ? OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: Color(0xFFE0E0E0),
                            ),
                          )
                        : InputBorder.none,
                    enabledBorder: editing
                        ? OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: Color(0xFFE0E0E0),
                            ),
                          )
                        : InputBorder.none,
                    focusedBorder: editing
                        ? OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: C.cardGreen,
                              width: 1.5,
                            ),
                          )
                        : InputBorder.none,
                    filled: editing,
                    fillColor: C.fieldBg,
                    hintText: editing ? 'Describe your project...' : null,
                    hintStyle: const TextStyle(
                      color: Color(0xFFBBBBBB),
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Edit Actions ─────────────────────────────────────────────────────────────
class _EditActions extends StatelessWidget {
  final VoidCallback onSave, onCancel;
  const _EditActions({super.key, required this.onSave, required this.onCancel});
  @override
  Widget build(BuildContext context) => Column(
    children: [
      GestureDetector(
        onTap: onSave,
        child: Container(
          width: double.infinity,
          height: 54,
          decoration: BoxDecoration(
            color: C.cardGreen,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: C.cardGreen.withOpacity(0.35),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Center(
            child: Text(
              'Save Changes',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
      const SizedBox(height: 12),
      GestureDetector(
        onTap: onCancel,
        child: Container(
          width: double.infinity,
          height: 54,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFDDDDDD), width: 1.5),
          ),
          child: const Center(
            child: Text(
              'Cancel',
              style: TextStyle(
                color: Color(0xFF888888),
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    ],
  );
}

// ─── Logout Button ────────────────────────────────────────────────────────────
class _LogoutButton extends StatelessWidget {
  final VoidCallback onTap;
  const _LogoutButton({super.key, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: double.infinity,
      height: 54,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: C.purple, width: 1.5),
      ),
      child: const Center(
        child: Text(
          'Logout',
          style: TextStyle(
            color: C.purple,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    ),
  );
}

// ─── Bottom Nav ───────────────────────────────────────────────────────────────
class _BottomNav extends StatelessWidget {
  final double safeBottom;
  const _BottomNav({required this.safeBottom});
  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.only(
      bottom: safeBottom + 4,
      top: 10,
      left: 20,
      right: 20,
    ),
    decoration: BoxDecoration(
      color: const Color(0xFFF5F5F5),
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.06),
          blurRadius: 12,
          offset: const Offset(0, -3),
        ),
      ],
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: const [
        _NavIcon(icon: Icons.chat_bubble_outline, active: false),
        _NavIcon(icon: Icons.mic_none, active: false),
        _NavIcon(icon: Icons.video_call_outlined, active: false),
        _NavIcon(icon: Icons.person, active: true),
      ],
    ),
  );
}

class _NavIcon extends StatelessWidget {
  final IconData icon;
  final bool active;
  const _NavIcon({required this.icon, required this.active});
  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(
        icon,
        size: 26,
        color: active ? C.cardGreen : const Color(0xFF999999),
      ),
      if (active)
        Container(
          margin: const EdgeInsets.only(top: 4),
          width: 18,
          height: 3,
          decoration: BoxDecoration(
            color: C.cardGreen,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
    ],
  );
}
