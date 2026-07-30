import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/models/help_model.dart';
import '../controllers/help_controller.dart';

class HelpView extends GetView<HelpController> {
  const HelpView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      body: SafeArea(
        child: Column(
          children: [
            // ── Top Bar ─────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  InkWell(
                    onTap: () => Get.back(),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_back, color: Colors.black87, size: 20),
                    ),
                  ),
                  const Expanded(
                    child: Text(
                      'Bantuan',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),
            ),

            // ── Body ────────────────────────────────────────────
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.primaryTeal),
                  );
                }
                return RefreshIndicator(
                  onRefresh: controller.fetchHelp,
                  color: AppColors.primaryTeal,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                    children: [
                      // ── Contact Card ───────────────────────
                      _ContactsCard(contacts: controller.contacts),
                      const SizedBox(height: 24),

                      // ── FAQ Section ────────────────────────
                      const Text(
                        'Pertanyaan Umum',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _FaqCard(
                        faqs: controller.faqs,
                        expandedIndex: controller.expandedFaqIndex,
                        onToggle: controller.toggleFaq,
                      ),
                      const SizedBox(height: 20),

                      // ── Emergency Banner ───────────────────
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF7ED),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFFED7AA)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.warning_amber_rounded,
                              color: Color(0xFFF97316),
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: RichText(
                                text: const TextSpan(
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF92400E),
                                    height: 1.5,
                                  ),
                                  children: [
                                    TextSpan(text: 'Untuk darurat seperti bencana atau kriminalitas, segera hubungi '),
                                    TextSpan(
                                      text: '112',
                                      style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFF97316)),
                                    ),
                                    TextSpan(text: ' atau layanan darurat setempat.'),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Contact List Card ──────────────────────────────────────────────────
class _ContactsCard extends StatelessWidget {
  final List<HelpContactModel> contacts;
  const _ContactsCard({required this.contacts});

  @override
  Widget build(BuildContext context) {
    if (contacts.isEmpty) return const SizedBox.shrink();
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: List.generate(contacts.length, (i) {
          final contact = contacts[i];
          return Column(
            children: [
              _ContactRow(contact: contact),
              if (i < contacts.length - 1)
                const Divider(height: 1, indent: 68, endIndent: 16, color: Color(0xFFF1F5F9)),
            ],
          );
        }),
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  final HelpContactModel contact;
  const _ContactRow({required this.contact});

  @override
  Widget build(BuildContext context) {
    final iconData = _iconForType(contact.type);
    final iconColor = _colorForType(contact.type);

    return InkWell(
      onTap: () => _onTap(contact),
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(iconData, color: iconColor, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    contact.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    contact.value,
                    style: TextStyle(
                      fontSize: 12.5,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 20),
          ],
        ),
      ),
    );
  }

  void _onTap(HelpContactModel contact) {
    Get.snackbar(
      contact.title,
      contact.value,
      backgroundColor: AppColors.primaryTeal,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  IconData _iconForType(String type) {
    switch (type) {
      case 'phone':
        return Icons.phone_outlined;
      case 'email':
        return Icons.mail_outline_rounded;
      default:
        return Icons.language_outlined;
    }
  }

  Color _colorForType(String type) {
    switch (type) {
      case 'phone':
        return const Color(0xFF059669);
      case 'email':
        return const Color(0xFF7C3AED);
      default:
        return const Color(0xFF0F767E);
    }
  }
}

// ── FAQ Accordion Card ────────────────────────────────────────────────
class _FaqCard extends StatelessWidget {
  final List<FaqModel> faqs;
  final RxInt expandedIndex;
  final void Function(int) onToggle;

  const _FaqCard({
    required this.faqs,
    required this.expandedIndex,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    if (faqs.isEmpty) return const SizedBox.shrink();
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Obx(() => Column(
        children: List.generate(faqs.length, (i) {
          final faq = faqs[i];
          final isExpanded = expandedIndex.value == i;
          return Column(
            children: [
              InkWell(
                onTap: () => onToggle(i),
                borderRadius: BorderRadius.circular(16),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          faq.question,
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: isExpanded ? FontWeight.bold : FontWeight.w500,
                            color: isExpanded ? AppColors.textDark : const Color(0xFF374151),
                            height: 1.4,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      AnimatedRotation(
                        turns: isExpanded ? 0 : -0.25,
                        duration: const Duration(milliseconds: 200),
                        child: Icon(
                          isExpanded ? Icons.keyboard_arrow_down : Icons.chevron_right,
                          color: isExpanded ? AppColors.primaryTeal : Colors.grey.shade400,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              AnimatedCrossFade(
                duration: const Duration(milliseconds: 250),
                crossFadeState: isExpanded ? CrossFadeState.showFirst : CrossFadeState.showSecond,
                firstChild: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Text(
                    faq.answer,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.primaryTeal,
                      height: 1.6,
                    ),
                  ),
                ),
                secondChild: const SizedBox.shrink(),
              ),
              if (i < faqs.length - 1)
                const Divider(height: 1, indent: 16, endIndent: 16, color: Color(0xFFF1F5F9)),
            ],
          );
        }),
      )),
    );
  }
}
