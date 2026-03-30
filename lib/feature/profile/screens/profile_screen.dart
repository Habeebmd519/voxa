import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:voxa/core/shimmer_loading/shimmer_loading.dart';
import 'package:voxa/feature/auth/data/model/user_model.dart';
import 'package:voxa/feature/task/profile_cubit/prifile_state.dart';
import 'package:voxa/feature/task/profile_cubit/profile_cubit.dart';

class ProfileScreen extends StatefulWidget {
  final state;
  final uid;
  final bool isEditing;
  const ProfileScreen({
    super.key,
    required this.state,
    required this.uid,
    required this.isEditing,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late UserModel editableUser;
  late TextEditingController nameCtrl;
  late TextEditingController placeCtrl;
  late TextEditingController domainCtrl;

  @override
  void initState() {
    // TODO: implement initState
    nameCtrl = TextEditingController(text: widget.state.user.name);
    placeCtrl = TextEditingController(text: widget.state.user.place ?? "");
    domainCtrl = TextEditingController(text: widget.state.user.domain ?? "");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.state is ProfileLoaded) {
      editableUser = widget.state.user;
    }
    void saveProfile() {
      final updatedUser = editableUser.copyWith(
        name: nameCtrl.text,
        place: placeCtrl.text,
        domain: domainCtrl.text,
      );

      context.read<ProfileCubit>().updateProfile(updatedUser);

      // setState(() => isEditing = false);
    }

    return _buildBottomSection(widget.state, widget.uid);
  }

  Widget _buildBottomSection(ProfileState state, String uid) {
    if (state is ProfileLoading) {
      return const Center(child: ProfileShimmer()); // or mini shimmer
    }

    if (state is ProfileError) {
      return Center(child: Text(state.message));
    }

    if (state is ProfileLoaded) {
      return _ProfileSheetContent(
        state: state,
        uid: uid,
        nameCtrl: nameCtrl,
        placeCtrl: placeCtrl,
        domainCtrl: domainCtrl,
        isEditing: widget.isEditing,
      );
    }

    return const SizedBox();
  }
}

// ── _ProfileSheetContent (goes inside AnimatedBottomContent) ──────────────

class _ProfileSheetContent extends StatelessWidget {
  final ProfileLoaded state;
  final String uid;

  final TextEditingController nameCtrl;
  final TextEditingController placeCtrl;
  final TextEditingController domainCtrl;
  final bool isEditing;

  const _ProfileSheetContent({
    required this.state,
    required this.uid,
    required this.nameCtrl,
    required this.placeCtrl,
    required this.domainCtrl,
    required this.isEditing,
  });
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      children: [
        // Drag handle
        Center(
          child: Container(
            width: 36,
            height: 4,
            margin: const EdgeInsets.only(top: 10, bottom: 20),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        const SizedBox(height: 24),
        _ProfileField(
          label: "NAME",
          controller: nameCtrl,
          editing: isEditing,
          icon: Icons.person,
        ),
        const SizedBox(height: 24),
        _ProfileField(
          label: "EMAIL",
          controller: TextEditingController(text: state.user.email),
          editing: false,
          icon: Icons.email,
          readonlyHint: true,
        ),
        const SizedBox(height: 24),
        _ProfileField(
          label: "PLACE",
          controller: placeCtrl,
          editing: isEditing,
          icon: Icons.location_on,
        ),
        const SizedBox(height: 24),

        _ProfileField(
          label: "DOMAIN",
          controller: domainCtrl,
          editing: isEditing,
          icon: Icons.language,
        ),

        const SizedBox(height: 24),

        // Logout button
        SizedBox(
          width: double.infinity,
          height: 50,
          child: OutlinedButton(
            onPressed: () {
              // logout logic
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF7B2FBE),
              side: const BorderSide(color: Color(0xFF7B2FBE), width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Text(
              "Logout",
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFF7B2FBE),
              ),
            ),
          ),
        ),

        const SizedBox(height: 20),
      ],
    );
  }
}

// // ── _ProfileField ──────────────────────────────────────────────────────────
// class _ProfileField extends StatelessWidget {
//   final String label;
//   final String value;

//   const _ProfileField({required this.label, required this.value});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: 50, // fixed height for uniform look
//       margin: const EdgeInsets.only(bottom: 14),
//       padding: const EdgeInsets.symmetric(horizontal: 18),
//       decoration: BoxDecoration(
//         color: const Color(0xFFEFF5F0), // softer grey
//         borderRadius: BorderRadius.circular(15),
//       ),
//       child: Row(
//         children: [
//           // LEFT LABEL
//           Text(
//             label,
//             style: const TextStyle(
//               fontSize: 13,
//               color: Color(0xFF9E9E9E), // lighter grey
//               fontWeight: FontWeight.w500, // not bold
//               letterSpacing: 1.2, // spacing like design
//             ),
//           ),

//           const Spacer(),

//           // RIGHT VALUE
//           Expanded(
//             flex: 2,
//             child: Text(
//               value,
//               textAlign: TextAlign.right,
//               overflow: TextOverflow.ellipsis,
//               style: const TextStyle(
//                 fontSize: 12,
//                 fontWeight: FontWeight.w500, // medium, not bold
//                 color: Color(0xFF2C2C2C),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

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
