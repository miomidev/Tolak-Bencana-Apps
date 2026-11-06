import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/network/api_client.dart';
import '../../../core/models/help_model.dart';

class HelpController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxList<HelpContactModel> contacts = <HelpContactModel>[].obs;
  final RxList<FaqModel> faqs = <FaqModel>[].obs;
  final RxInt expandedFaqIndex = (-1).obs;

  @override
  void onInit() {
    super.onInit();
    fetchHelp();
  }

  Future<void> fetchHelp() async {
    isLoading.value = true;
    try {
      final response = await ApiClient.dio.get('/help');
      if (response.statusCode == 200) {
        final data = response.data['data'];

        final contactList = (data['contacts'] as List)
            .map((e) => HelpContactModel.fromJson(e as Map<String, dynamic>))
            .toList();
        final faqList = (data['faqs'] as List)
            .map((e) => FaqModel.fromJson(e as Map<String, dynamic>))
            .toList();

        contacts.assignAll(contactList);
        faqs.assignAll(faqList);
      }
    } catch (e) {
      // Offline fallback
      contacts.assignAll([
        const HelpContactModel(id: 1, type: 'phone', title: 'Telepon / WhatsApp', value: '+62 831-8652-3420 WhatsApp', icon: 'whatsapp'),
        const HelpContactModel(id: 2, type: 'email', title: 'Email', value: 'bantuan@tolak-bencana.miomidev.com', icon: 'email'),
        const HelpContactModel(id: 3, type: 'website', title: 'Website Resmi', value: 'tolak-bencana.miomidev.com', icon: 'website'),
      ]);
      faqs.assignAll([
        const FaqModel(id: 1, question: 'Bagaimana cara membuat laporan baru?', answer: "Buka halaman Beranda, lalu ketuk tombol '+' untuk membuat laporan baru. Isi detail masalah, foto, dan lokasi, kemudian kirim."),
        const FaqModel(id: 2, question: 'Berapa lama laporan saya diproses?', answer: 'Laporan biasanya diproses dalam 1â€“3 hari kerja. Anda dapat memantau status laporan melalui menu Riwayat Laporan.'),
        const FaqModel(id: 3, question: 'Apakah laporan saya bisa anonim?', answer: 'Saat ini laporan memerlukan akun terdaftar. Identitas Anda hanya terlihat oleh petugas yang berwenang, bukan publik.'),
        const FaqModel(id: 4, question: 'Bagaimana jika laporan saya ditolak?', answer: 'Jika laporan ditolak, Anda akan mendapat notifikasi beserta alasannya. Anda dapat mengedit laporan dan mengirim ulang.'),
      ]);
    } finally {
      isLoading.value = false;
    }
  }

  void toggleFaq(int index) {
    expandedFaqIndex.value = expandedFaqIndex.value == index ? -1 : index;
  }

  void onContactTap(HelpContactModel contact) {
    Get.snackbar(
      contact.title,
      contact.value,
      backgroundColor: const Color(0xFF0F767E),
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      icon: Icon(_iconForType(contact.type), color: Colors.white),
    );
  }

  IconData _iconForType(String type) {
    switch (type) {
      case 'phone':
        return Icons.phone_outlined;
      case 'email':
        return Icons.mail_outline;
      default:
        return Icons.language_outlined;
    }
  }
}
