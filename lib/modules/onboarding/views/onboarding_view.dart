import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../controllers/onboarding_controller.dart';

class OnboardingView extends GetView<OnboardingController> {
  const OnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [

            Expanded(
              child: PageView.builder(
                controller: controller.pageController,
                onPageChanged: controller.onPageChanged,
                itemCount: controller.onboardingData.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(40.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          controller.onboardingData[index]['image']!,
                          height: 120,
                        ),
                        const SizedBox(height: 40),
                        Text(
                          controller.onboardingData[index]['title']!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryTeal,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          controller.onboardingData[index]['description']!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Obx(() {
              bool isLastPage = controller.currentPage.value == controller.onboardingData.length - 1;
              return Column(
                children: [
                  if (!isLastPage) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        controller.onboardingData.length,
                        (index) => buildDot(index),
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                  Padding(
                    padding: const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 30.0),
                    child: isLastPage
                        ? SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: controller.nextPage,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryTeal,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 15),
                              ),
                              child: const Text(
                                'Mulai',
                                style: TextStyle(color: Colors.white, fontSize: 16),
                              ),
                            ),
                          )
                        : Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: controller.skip,
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(color: AppColors.softTeal),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: const EdgeInsets.symmetric(vertical: 15),
                                  ),
                                  child: const Text(
                                    'Lewati',
                                    style: TextStyle(color: Colors.black54, fontSize: 16),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 15),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: controller.nextPage,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primaryTeal,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: const EdgeInsets.symmetric(vertical: 15),
                                  ),
                                  child: const Text(
                                    'Lanjut',
                                    style: TextStyle(color: Colors.white, fontSize: 16),
                                  ),
                                ),
                              ),
                            ],
                          ),
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget buildDot(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(right: 5),
      height: 10,
      width: controller.currentPage.value == index ? 20 : 10,
      decoration: BoxDecoration(
        color: controller.currentPage.value == index ? AppColors.primaryTeal : AppColors.softTeal,
        borderRadius: BorderRadius.circular(5),
      ),
    );
  }
}
