import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void showQuickDealDialog(BuildContext context, String chatId) {
  showDialog(
    context: context,
    barrierColor: Colors.black.withOpacity(0.6),
    builder: (_) => _QuickDealDialog(chatId: chatId),
  );
}

class _QuickDealDialog extends StatefulWidget {
  final String chatId;
  const _QuickDealDialog({required this.chatId});

  @override
  State<_QuickDealDialog> createState() => _QuickDealDialogState();
}

class _QuickDealDialogState extends State<_QuickDealDialog> {
  final _titleCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  DateTime? _endDate;
  bool _sending = false;

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _endDate = picked);
  }

  Future<void> _sendDeal() async {
    if (_titleCtrl.text.trim().isEmpty) {
      _showSnack('Please enter a deal title');
      return;
    }

    if (_priceCtrl.text.trim().isEmpty) {
      _showSnack('Please enter the deal price');
      return;
    }
    ;

    setState(() => _sending = true);

    final user = FirebaseAuth.instance.currentUser!;
    final docRef = FirebaseFirestore.instance
        .collection('chats')
        .doc(widget.chatId)
        .collection('messages')
        .doc();

    await docRef.set({
      "id": docRef.id,
      "title": _titleCtrl.text.trim(),
      "price": _priceCtrl.text.trim(),
      "status": "pending",
      "startDate": null,
      "deadline": _endDate?.toIso8601String(),
      "type": "deal",
      "senderId": user.uid,
      "timestamp": FieldValue.serverTimestamp(),
    });

    if (mounted) Navigator.pop(context);
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            /// 🔥 HEADER
            Container(
              color: const Color(0xFF4F7F2F),
              padding: const EdgeInsets.all(18),
              child: Row(
                children: const [
                  Icon(Icons.flash_on, color: Colors.white),
                  SizedBox(width: 10),
                  Text(
                    "Quick Deal",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            /// BODY
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _StyledField(
                    controller: _titleCtrl,
                    label: "Deal TItle",
                    hint: 'e.g. Fix bugs',
                    icon: Icons.title_rounded,
                  ),
                  // _field(_titleCtrl, "Title"),
                  const SizedBox(height: 12),
                  _StyledField(
                    controller: _priceCtrl,
                    label: 'Amount (₹)',
                    hint: '0',
                    icon: Icons.currency_rupee_rounded,
                    keyboardType: TextInputType.number,
                  ),
                  // _field(_priceCtrl, "Price", type: TextInputType.number),
                  const SizedBox(height: 12),

                  /// DATE
                  GestureDetector(
                    onTap: _pickDate,
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAF6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 16),
                          const SizedBox(width: 10),
                          Text(
                            _endDate == null
                                ? "Select Deadline"
                                : DateFormat('dd MMM yyyy').format(_endDate!),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// BUTTONS
                  Row(
                    children: [
                      Expanded(
                        child: _OutlineBtn(
                          label: "Cancle",
                          onTap: () => Navigator.pop(context),
                          // onPressed: () => Navigator.pop(context),
                          // child: const Text("Cancel"),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _sending
                            ? const Center(child: CircularProgressIndicator())
                            : _GreenBtn(
                                onTap: _sendDeal,
                                label: "Send",
                                icon: Icons.send,
                              ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController ctrl,
    String hint, {
    TextInputType type = TextInputType.text,
  }) {
    return TextField(
      controller: ctrl,
      keyboardType: type,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: const Color(0xFFF8FAF6),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
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
