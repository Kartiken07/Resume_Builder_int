import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../cards/Daily_Utility_Tool/age_calculator/age_result_card.dart';
import '../../widgets/Daily_Utility_Tool/age_calculator/timezone_dropdown.dart';
import '../../providers/Daily_Utility_Tool/age_calculator_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/Daily_Utility_Tool/age_calculator/age_date_picker_tile.dart';

class AgeCalculatorScreen extends ConsumerWidget {
  const AgeCalculatorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(ageCalculatorProvider);
    final notifier = ref.read(ageCalculatorProvider.notifier);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Stack(
        children: [
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: MediaQuery.of(context).size.height * 0.45,
            child: ClipPath(
              clipper: _CurveClipper(),
              child: Container(
                decoration: BoxDecoration(
                  gradient: AppTheme.curvedBackgroundGradient,
                ),
              ),
            ),
          ),

          Center(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 40),

                  _buildDecorativeLine(),
                  const SizedBox(height: 20),

                  Text("AGE", style: AppTheme.headingLarge)
                      .animate()
                      .fade()
                      .slideY(begin: -0.2),

                  Text("Calculator", style: AppTheme.decorative)
                      .animate()
                      .fade(delay: 150.ms),

                  const SizedBox(height: 20),

                  Text(
                    "FIND YOUR EXACT AGE",
                    style: AppTheme.labelMedium.copyWith(letterSpacing: 6),
                  ),

                  const SizedBox(height: 40),

                  // 🔥 INPUT CARD
                  Container(
                    width: 420,
                    padding: const EdgeInsets.all(36),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius:
                          BorderRadius.circular(AppTheme.radiusXLarge),
                      boxShadow: AppTheme.shadowLarge,
                    ),
                    child: Column(
                      children: [
                        AgeDatePickerTile(
                          selectedDate: state.selectedDate,
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate:
                                  state.selectedDate ?? DateTime(2000),
                              firstDate: DateTime(1900),
                              lastDate: DateTime.now(),
                            );
                            if (picked != null) {
                              notifier.updateSelectedDate(picked);
                            }
                          },
                        ),

                        const SizedBox(height: 18),

                        SizedBox(
                          width: double.infinity,
                          child: TimezoneDropdown(
                            selected: state.timezoneOffset,
                            onChanged: notifier.updateTimezone,
                          ),
                        ),

                        const SizedBox(height: 28),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: notifier.calculateAge,
                            child: const Text("Calculate Age"),
                          ),
                        ),

                        if (state.errorMessage != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Text(
                              state.errorMessage!,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                      ],
                    ),
                  ),

                  // 🔥 RESULT SECTION
                  if (state.hasResult) ...[
                    const SizedBox(height: 24),

                    Container(
                      width: 420,
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusXLarge),
                        boxShadow: AppTheme.shadowLarge,
                      ),
                      child: Column(
                        children: [
                          Text(
                            "YOUR AGE",
                            style: AppTheme.labelMedium,
                          ),

                          const SizedBox(height: 20),

                          AgeResultCard(
                            title: '🎂 Age',
                            value: state.result!.ageText,
                          ),

                          AgeResultCard(
                            title: '🎉 Next Birthday',
                            value: state.result!.nextBirthdayText,
                          ),

                          AgeResultCard(
                            title: '⏳ Total Days',
                            value: state.result!.totalDaysText,
                          ),

                          AgeResultCard(
                            title: '⏱ Total Hours',
                            value: state.result!.totalHoursText,
                          ),

                          AgeResultCard(
                            title: '♈ Zodiac',
                            value: state.result!.zodiacText,
                          ),

                          const SizedBox(height: 24),

                          Text(
                            "AGE ON PLANETS 🌍",
                            style: AppTheme.labelLarge,
                          ),

                          const SizedBox(height: 12),

                          Column(
                            children: state.result!.planetAges.entries.map((e) {
                              return Container(
                                margin: const EdgeInsets.symmetric(vertical: 6),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                                decoration: BoxDecoration(
                                  color: AppTheme.background.withOpacity(0.6),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.08),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      e.key,
                                      style: AppTheme.bodyMedium.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      "${e.value.toStringAsFixed(1)} yrs",
                                      style: AppTheme.bodyMedium.copyWith(
                                        color: Colors.amber,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),

                          const SizedBox(height: 28),

                          // 📜 EVENTS
                          if (state.result!.historicalEvents.isNotEmpty) ...[
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "📜 Historical Events",
                                style: AppTheme.labelLarge,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Column(
                              children: state.result!.historicalEvents
                                  .map((event) => _infoCard(event, "•"))
                                  .toList(),
                            ),
                          ],

                          const SizedBox(height: 20),

                          // 🎂 BIRTHDAYS
                          if (state.result!.famousBirthdays.isNotEmpty) ...[
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "🎂 Famous Birthdays",
                                style: AppTheme.labelLarge,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Column(
                              children: state.result!.famousBirthdays
                                  .map((p) => _infoCard(p, "🎉"))
                                  .toList(),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),

          Positioned(
            top: 32,
            left: 32,
            child: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.go('/daily-utility-tool'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoCard(String text, String icon) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.background.withOpacity(0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(color: Colors.amber)),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: AppTheme.bodySmall.copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDecorativeLine() => const SizedBox();
}

class _CurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) => Path()
    ..moveTo(0, size.height * 0.2)
    ..quadraticBezierTo(
        size.width / 2, -size.height * 0.1, size.width, size.height * 0.2)
    ..lineTo(size.width, size.height)
    ..lineTo(0, size.height)
    ..close();

  @override
  bool shouldReclip(_) => false;
}