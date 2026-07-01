import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/FileSharing/file_provider.dart';
import '../../widgets/FileSharing/brand_kit.dart';
import '../../widgets/FileSharing/theme.dart';

class FileSharingUploadScreen extends ConsumerWidget {
  const FileSharingUploadScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(fileSharingProvider);
    final notifier = ref.read(fileSharingProvider.notifier);

    return Theme(
      // Apply File Sharing's dark theme locally — does not affect the rest of ToolHub
      data: FileSharingTheme.dark(),
      child: FSAuroraScaffold(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth >= 980;
                  final compact =
                      !isWide || constraints.maxHeight < 820;

                  final overviewPanel = FSFrostPanel(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const FSAppPill(
                            label: 'Transfer studio',
                            icon: Icons.waves_rounded),
                        const SizedBox(height: 16),
                        Text('Short links.\nFast uploads.',
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium),
                        const SizedBox(height: 14),
                        const Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            FSAppPill(
                                label: 'Short link output',
                                icon: Icons.link_rounded,
                                tone: FSPillTone.aqua),
                            FSAppPill(
                                label: 'Private access',
                                icon: Icons.lock_rounded),
                            FSAppPill(
                                label: 'Fast upload',
                                icon: Icons.bolt_rounded,
                                tone: FSPillTone.aqua),
                          ],
                        ),
                        const SizedBox(height: 18),
                        FSTransferIllustration(
                            height: compact ? 185 : 230),
                      ],
                    ),
                  );

                  final workspacePanel = FSFrostPanel(
                    padding: EdgeInsets.all(compact ? 20 : 24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const FSBrandWordmark(
                            title: 'Naiyo24 Transfer',
                            subtitle: 'Private upload workspace'),
                        SizedBox(height: compact ? 14 : 18),
                        const Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            FSAppPill(
                                label: 'Upload',
                                icon: Icons.arrow_upward_rounded),
                            FSAppPill(
                                label: 'Share',
                                icon: Icons.link_rounded,
                                tone: FSPillTone.aqua),
                          ],
                        ),
                        SizedBox(height: compact ? 16 : 18),
                        _ChooseFileCard(
                          compact: compact,
                          onTap: () async {
                            final result =
                                await FilePicker.platform.pickFiles(
                              withData: kIsWeb,
                            );
                            if (result != null &&
                                result.files.isNotEmpty) {
                              notifier.setFile(result.files.single);
                            }
                          },
                        ),
                        SizedBox(height: compact ? 12 : 16),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 260),
                          child: state.file == null
                              ? _InfoCard(
                                  key: const ValueKey('empty-file'),
                                  icon: Icons.folder_open_rounded,
                                  title: 'No file selected',
                                  subtitle: 'Pick a file to begin.',
                                  compact: compact,
                                )
                              : _InfoCard(
                                  key: const ValueKey('selected-file'),
                                  icon:
                                      Icons.insert_drive_file_rounded,
                                  title: state.file!.name,
                                  subtitle: kIsWeb
                                      ? '${(state.file!.size / 1024).toStringAsFixed(1)} KB'
                                      : (state.file!.path ??
                                          '${(state.file!.size / 1024).toStringAsFixed(1)} KB'),
                                  compact: compact,
                                  iconColor: FileSharingTheme.sky,
                                  iconBgColor: FileSharingTheme.sky
                                      .withValues(alpha: 0.15),
                                  cardColor: Colors.white
                                      .withValues(alpha: 0.07),
                                ),
                        ),
                        SizedBox(height: compact ? 12 : 16),
                        _ExpirySliderCard(
                          minutes: state.expiryMinutes,
                          compact: compact,
                          onChanged: state.loading
                              ? null
                              : notifier.setExpiryMinutes,
                        ),
                        SizedBox(height: compact ? 12 : 16),
                        if (state.errorMessage != null) ...[
                          FSInfoBanner(
                              message: state.errorMessage!,
                              icon: Icons.error_outline_rounded),
                          SizedBox(height: compact ? 12 : 16),
                        ],
                        FSGradientButton(
                          label: state.loading
                              ? 'Uploading'
                              : 'Upload now',
                          icon: Icons.arrow_upward_rounded,
                          onPressed: state.file == null || state.loading
                              ? null
                              : notifier.upload,
                          isLoading: state.loading,
                        ),
                        SizedBox(height: compact ? 14 : 18),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 280),
                          switchInCurve: Curves.easeOutCubic,
                          switchOutCurve: Curves.easeInCubic,
                          child: state.link == null
                              ? _InfoCard(
                                  key: const ValueKey('empty-link'),
                                  icon: Icons.link_off_rounded,
                                  title: 'No link yet',
                                  subtitle:
                                      'Your short share link will appear here.',
                                  compact: compact,
                                )
                              : _ShareLinkCard(
                                  key: const ValueKey('share-link'),
                                  link: state.link!,
                                  expiryMinutes: state.expiryMinutes,
                                  compact: compact,
                                ),
                        ),
                      ],
                    ),
                  );

                  return Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isWide ? 32 : 18,
                      vertical: isWide ? 24 : 16,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints:
                            const BoxConstraints(maxWidth: 1180),
                        child: isWide
                            ? Row(
                                crossAxisAlignment:
                                    CrossAxisAlignment.stretch,
                                children: [
                                  Expanded(
                                      flex: 9,
                                      child: Center(
                                          child:
                                              SingleChildScrollView(
                                                  child:
                                                      overviewPanel))),
                                  const SizedBox(width: 22),
                                  Expanded(
                                      flex: 11,
                                      child: Center(
                                          child:
                                              SingleChildScrollView(
                                                  child:
                                                      workspacePanel))),
                                ],
                              )
                            : SingleChildScrollView(
                                child: ConstrainedBox(
                                  constraints: const BoxConstraints(
                                      maxWidth: 620),
                                  child: workspacePanel,
                                ),
                              ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          // Back to ToolHub home
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () => context.go('/'),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.arrow_back_ios,
                      color: FileSharingTheme.aqua, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    'HOME',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: FileSharingTheme.aqua.withValues(alpha: 0.8),
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Spacer(),
          // Brand name
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [FileSharingTheme.coral, FileSharingTheme.aqua],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ).createShader(bounds),
            child: const Text(
              'File Sharing',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -0.5),
            ),
          ),
          const Spacer(),
          const SizedBox(width: 60), // balance back button
        ],
      ),
    );
  }
}

// ── Private widgets ───────────────────────────────────────────────────────────

class _ChooseFileCard extends StatelessWidget {
  const _ChooseFileCard({required this.onTap, required this.compact});
  final Future<void> Function() onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final iconSize = compact ? 52.0 : 64.0;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(28),
        onTap: onTap,
        child: Ink(
          padding: EdgeInsets.all(compact ? 18 : 24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
                color: Colors.white.withValues(alpha: 0.12)),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: 0.12),
                Colors.white.withValues(alpha: 0.04)
              ],
            ),
          ),
          child: Row(
            children: [
              SizedBox.square(
                dimension: iconSize,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22),
                    gradient: const LinearGradient(colors: [
                      FileSharingTheme.coral,
                      FileSharingTheme.gold,
                      FileSharingTheme.aqua
                    ]),
                  ),
                  child: Icon(Icons.add_photo_alternate_rounded,
                      color: FileSharingTheme.ink,
                      size: compact ? 24 : 30),
                ),
              ),
              SizedBox(width: compact ? 14 : 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Choose a file',
                        style:
                            Theme.of(context).textTheme.titleMedium),
                    SizedBox(height: compact ? 4 : 6),
                    Text('Tap to browse from your device.',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Icon(Icons.arrow_forward_rounded,
                  color: Colors.white.withValues(alpha: 0.8)),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.compact,
    this.iconColor = Colors.white,
    this.iconBgColor,
    this.cardColor,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool compact;
  final Color iconColor;
  final Color? iconBgColor;
  final Color? cardColor;

  @override
  Widget build(BuildContext context) {
    final dim = compact ? 44.0 : 52.0;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: cardColor ?? Colors.white.withValues(alpha: 0.05),
        border:
            Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Padding(
        padding: EdgeInsets.all(compact ? 14 : 18),
        child: Row(
          children: [
            SizedBox.square(
              dimension: dim,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  color: iconBgColor ??
                      Colors.white.withValues(alpha: 0.08),
                ),
                child: Icon(icon, color: iconColor),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExpirySliderCard extends StatelessWidget {
  const _ExpirySliderCard(
      {required this.minutes,
      required this.compact,
      required this.onChanged});
  final int minutes;
  final bool compact;
  final ValueChanged<int>? onChanged;

  @override
  Widget build(BuildContext context) {
    final enabled = onChanged != null;
    final iconDim = compact ? 40.0 : 46.0;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: Colors.white.withValues(alpha: 0.06),
        border:
            Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(compact ? 14 : 18,
            compact ? 12 : 16, compact ? 14 : 18, compact ? 10 : 14),
        child: Column(
          children: [
            Row(
              children: [
                SizedBox.square(
                  dimension: iconDim,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: FileSharingTheme.gold
                          .withValues(alpha: 0.14),
                    ),
                    child: const Icon(Icons.timer_rounded,
                        color: FileSharingTheme.gold),
                  ),
                ),
                SizedBox(width: compact ? 12 : 14),
                Expanded(
                    child: Text('Link expiry',
                        style: Theme.of(context).textTheme.titleMedium)),
                const SizedBox(width: 12),
                DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    color: FileSharingTheme.aqua.withValues(
                        alpha: enabled ? 0.18 : 0.08),
                    border: Border.all(
                        color: FileSharingTheme.aqua.withValues(
                            alpha: enabled ? 0.24 : 0.1)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    child: Text(
                      _expiryLabel(minutes),
                      style: Theme.of(context)
                          .textTheme
                          .labelLarge
                          ?.copyWith(
                            color: enabled
                                ? FileSharingTheme.aqua
                                : Colors.white.withValues(alpha: 0.48),
                          ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: compact ? 4 : 8),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: FileSharingTheme.aqua,
                inactiveTrackColor:
                    Colors.white.withValues(alpha: 0.16),
                thumbColor: FileSharingTheme.gold,
                overlayColor:
                    FileSharingTheme.gold.withValues(alpha: 0.14),
                valueIndicatorColor: FileSharingTheme.surfaceStrong,
                valueIndicatorTextStyle: Theme.of(context)
                    .textTheme
                    .labelLarge
                    ?.copyWith(color: Colors.white),
              ),
              child: Slider(
                value: minutes.toDouble(),
                min: minLinkExpiryMinutes.toDouble(),
                max: maxLinkExpiryMinutes.toDouble(),
                divisions: 5,
                label: _expiryLabel(minutes),
                onChanged: enabled ? (v) => onChanged!(v.round()) : null,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_expiryLabel(minLinkExpiryMinutes),
                      style: Theme.of(context).textTheme.bodyMedium),
                  Text(_expiryLabel(maxLinkExpiryMinutes),
                      style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShareLinkCard extends StatelessWidget {
  const _ShareLinkCard(
      {super.key,
      required this.link,
      required this.expiryMinutes,
      required this.compact});
  final String link;
  final int expiryMinutes;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            FileSharingTheme.aqua.withValues(alpha: 0.18),
            FileSharingTheme.sky.withValues(alpha: 0.08),
            Colors.white.withValues(alpha: 0.06),
          ],
        ),
        border:
            Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Padding(
        padding: EdgeInsets.all(compact ? 16 : 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SizedBox.square(
                  dimension: 46,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color:
                          Colors.white.withValues(alpha: 0.12),
                    ),
                    child: const Icon(Icons.link_rounded,
                        color: FileSharingTheme.aqua),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Link ready',
                          style:
                              Theme.of(context).textTheme.titleMedium),
                      if (!compact) ...[
                        const SizedBox(height: 4),
                        Text(
                            'Expires in ${_expiryLabel(expiryMinutes)}.',
                            style:
                                Theme.of(context).textTheme.bodyMedium),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                IconButton.filled(
                  onPressed: () async {
                    await Clipboard.setData(ClipboardData(text: link));
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Share link copied')));
                  },
                  style: IconButton.styleFrom(
                      backgroundColor: FileSharingTheme.aqua,
                      foregroundColor: FileSharingTheme.ink),
                  icon: const Icon(Icons.copy_rounded),
                  tooltip: 'Copy link',
                ),
              ],
            ),
            SizedBox(height: compact ? 12 : 16),
            DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.black.withValues(alpha: 0.18),
                border: Border.all(
                    color: Colors.white.withValues(alpha: 0.08)),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: 16, vertical: compact ? 12 : 14),
                child: Text(
                  _compactLink(link),
                  maxLines: compact ? 1 : 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

String _compactLink(String link) =>
    link.length <= 52 ? link : '${link.substring(0, 34)}...${link.substring(link.length - 12)}';

String _expiryLabel(int minutes) =>
    minutes == maxLinkExpiryMinutes ? '1 hr' : '$minutes min';
