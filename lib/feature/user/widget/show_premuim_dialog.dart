import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// ─────────────────────────────────────────────
//  Drop-in replacement for _showPremiumDealDialog
//  Call this exactly like your original:
//  _showPremiumDealDialog(context, widget.receiverUser.uid)
// ─────────────────────────────────────────────

void showPremiumDealDialog(
  BuildContext context,
  String chatId,
  String receiverId,
) {
  showDialog(
    context: context,
    barrierColor: Colors.black.withOpacity(0.6),
    builder: (_) => _PremiumDealDialog(chatId: chatId),
  );
}

// ─────────────────────────────────────────────
//  Dialog widget — fully self-contained
// ─────────────────────────────────────────────

class _PremiumDealDialog extends StatefulWidget {
  final String chatId;
  const _PremiumDealDialog({required this.chatId});

  @override
  State<_PremiumDealDialog> createState() => _PremiumDealDialogState();
}

class _PremiumDealDialogState extends State<_PremiumDealDialog> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final List<Map<String, dynamic>> _milestones = [];
  DateTime? _endDate;
  bool _sending = false;

  int get _total => _milestones.fold(0, (sum, m) => sum + (m['amount'] as int));

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF4F7F2F),
            onPrimary: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _endDate = picked);
  }

  void _addMilestone() {
    final mTitle = TextEditingController();
    final mAmount = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20),
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
                      color: const Color(0xFF1E1E1E),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.flag_rounded,
                      color: Colors.amber,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Add milestone',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              _StyledField(
                controller: mTitle,
                label: 'Milestone title',
                hint: 'e.g. UI Design, Backend API...',
                icon: Icons.check_circle_outline_rounded,
              ),
              const SizedBox(height: 12),
              _StyledField(
                controller: mAmount,
                label: 'Amount (₹)',
                hint: '0',
                icon: Icons.currency_rupee_rounded,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _OutlineBtn(
                      label: 'Cancel',
                      onTap: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: _GreenBtn(
                      label: 'Add',
                      icon: Icons.add_rounded,
                      onTap: () {
                        final amt = int.tryParse(mAmount.text) ?? 0;
                        if (mTitle.text.trim().isEmpty) return;
                        setState(() {
                          _milestones.add({
                            'title': mTitle.text.trim(),
                            'amount': amt,
                            'status': 'pending',
                            'deadline': _endDate?.toIso8601String(),
                            'startDate': null,
                          });
                        });
                        Navigator.pop(context);
                      },
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

  Future<void> _sendDeal() async {
    if (_titleCtrl.text.trim().isEmpty) {
      _showSnack('Please enter a deal title');
      return;
    }
    if (_milestones.isEmpty) {
      _showSnack('Add at least one milestone');
      return;
    }

    setState(() => _sending = true);

    try {
      final currentUser = FirebaseAuth.instance.currentUser!;
      final docRef = FirebaseFirestore.instance
          .collection('chats')
          .doc(widget.chatId)
          .collection('messages')
          .doc();

      await docRef.set({
        'id': docRef.id,
        'type': 'premium_deal',
        'title': _titleCtrl.text.trim(),
        'description': _descCtrl.text.trim(),
        'totalPrice': _total,
        'milestones': _milestones,
        'deadline': _endDate?.toIso8601String(),
        'startDate': null,
        'status': 'pending',
        'senderId': currentUser.uid,
        'timestamp': FieldValue.serverTimestamp(),
      });

      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() => _sending = false);
      _showSnack('Failed to send deal. Try again.');
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: const Color(0xFF2A4A1A),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Dark header ──────────────────────
            Container(
              color: const Color(0xFF1E1E1E),
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5C518),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.workspace_premium_rounded,
                      color: Color(0xFF1a1a1a),
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Premium Deal',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -.3,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Full contract with milestones',
                        style: TextStyle(color: Colors.white54, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ── White body ───────────────────────
            Container(
              color: Colors.white,
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.72,
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    _StyledField(
                      controller: _titleCtrl,
                      label: 'Deal title',
                      hint: 'e.g. Logo Design, Mobile App...',
                      icon: Icons.title_rounded,
                    ),
                    const SizedBox(height: 14),

                    // Description
                    _StyledField(
                      controller: _descCtrl,
                      label: 'Description',
                      hint: 'What will you deliver?',
                      icon: Icons.notes_rounded,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 14),

                    // Deadline
                    const _SectionLabel('Deadline'),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: _pickDate,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 13,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAF6),
                          border: Border.all(
                            color: const Color(0xFFE2EED8),
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.calendar_today_rounded,
                              size: 17,
                              color: Color(0xFF5a9a3a),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              _endDate == null
                                  ? 'Select end date'
                                  : DateFormat('dd MMM yyyy').format(_endDate!),
                              style: TextStyle(
                                fontSize: 14,
                                color: _endDate == null
                                    ? const Color(0xFF9CA3AF)
                                    : const Color(0xFF1a2e1a),
                                fontWeight: _endDate != null
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              ),
                            ),
                            const Spacer(),
                            if (_endDate != null)
                              GestureDetector(
                                onTap: () => setState(() => _endDate = null),
                                child: const Icon(
                                  Icons.close_rounded,
                                  size: 16,
                                  color: Color(0xFF9CA3AF),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Milestones
                    const _SectionLabel('Milestones'),
                    const SizedBox(height: 8),

                    // Milestone list
                    ..._milestones.asMap().entries.map((entry) {
                      final i = entry.key;
                      final m = entry.value;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0F7E8),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFFD4EAB8),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF97C459),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  m['title'],
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF1a2e1a),
                                  ),
                                ),
                              ),
                              Text(
                                '₹${m['amount']}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF3B6D11),
                                ),
                              ),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: () =>
                                    setState(() => _milestones.removeAt(i)),
                                child: Container(
                                  width: 22,
                                  height: 22,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFEE2E2),
                                    borderRadius: BorderRadius.circular(11),
                                  ),
                                  child: const Icon(
                                    Icons.close_rounded,
                                    size: 13,
                                    color: Color(0xFFEF4444),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),

                    // Add milestone button
                    GestureDetector(
                      onTap: _addMilestone,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAF6),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFF97C459),
                            width: 1.5,
                            // ignore: deprecated_member_use
                            strokeAlign: BorderSide.strokeAlignInside,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(
                              Icons.add_circle_outline_rounded,
                              size: 18,
                              color: Color(0xFF5a9a3a),
                            ),
                            SizedBox(width: 7),
                            Text(
                              'Add milestone',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF3B6D11),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Total bar
                    if (_milestones.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E1E1E),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.account_balance_wallet_rounded,
                              color: Colors.white54,
                              size: 18,
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              'Total amount',
                              style: TextStyle(
                                color: Colors.white54,
                                fontSize: 13,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '₹ ${_total.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}',
                              style: const TextStyle(
                                color: Color(0xFF97C459),
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 18),

                    // Action buttons
                    Row(
                      children: [
                        Expanded(
                          child: _OutlineBtn(
                            label: 'Cancel',
                            onTap: () => Navigator.pop(context),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 2,
                          child: _sending
                              ? Container(
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF4F7F2F),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: const Center(
                                    child: SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                )
                              : _GreenBtn(
                                  label: 'Send Deal',
                                  icon: Icons.send_rounded,
                                  onTap: _sendDeal,
                                ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Reusable sub-widgets
// ─────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: Color(0xFF6B7280),
        letterSpacing: .7,
      ),
    );
  }
}

class _StyledField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final int maxLines;
  final TextInputType keyboardType;

  const _StyledField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.maxLines = 1,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionLabel(label),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF1a2e1a),
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              color: Color(0xFF9CA3AF),
              fontWeight: FontWeight.normal,
            ),
            prefixIcon: Icon(icon, size: 18, color: const Color(0xFF5a9a3a)),
            filled: true,
            fillColor: const Color(0xFFF8FAF6),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 13,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFFE2EED8),
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFF5a9a3a),
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _OutlineBtn extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _OutlineBtn({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE2EED8), width: 1.5),
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF6B7280),
            ),
          ),
        ),
      ),
    );
  }
}

class _GreenBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  const _GreenBtn({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: const Color(0xFF4F7F2F),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 17),
            const SizedBox(width: 7),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
