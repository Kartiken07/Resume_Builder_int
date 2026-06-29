import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../../routes/Daily_Utility_Tool/app_pages.dart';
import '../../theme/app_theme.dart';

class AppShell extends StatelessWidget {
  const AppShell({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final isMobile = MediaQuery.sizeOf(context).width < 720;

    return Scaffold(
      backgroundColor: AppTheme.background,
      drawer: isMobile ? _SidebarContent(currentLocation: location) : null,
      body: Row(
        children: [
          if (!isMobile) _SidebarContent(currentLocation: location),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _SidebarContent extends StatelessWidget {
  const _SidebarContent({required this.currentLocation});

  final String currentLocation;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppTheme.sidebarWidth,
      decoration: BoxDecoration(
        gradient: AppTheme.sidebarGradient,
        boxShadow: AppTheme.sidebarShadow,
        border: Border(
          right: BorderSide(color: AppTheme.borderLight, width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppTheme.spacingXXLarge),

          // Brand
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingLarge - 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("DAILY", style: AppTheme.sidebarBrandTitle),
                Text("Utility", style: AppTheme.sidebarBrandScript),
              ],
            ),
          ),

          const SizedBox(height: AppTheme.spacingSmall),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingLarge - 4),
            child: Container(height: 1, color: AppTheme.sidebarDivider),
          ),

          const SizedBox(height: AppTheme.spacingLarge - 4),

          _HomeNavItem(),
          const SizedBox(height: AppTheme.spacingSmall - 4),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingLarge - 4),
            child: Container(height: 1, color: AppTheme.sidebarDivider),
          ),

          const SizedBox(height: AppTheme.spacingSmall - 4),

          _NavItem(icon: LucideIcons.layoutDashboard, label: 'Dashboard',      route: AppRoutes.dashboard,        currentLocation: currentLocation),
          _NavItem(icon: LucideIcons.qrCode,          label: 'QR Generator',   route: AppRoutes.qrGenerator,      currentLocation: currentLocation),
          _NavItem(icon: LucideIcons.scan,             label: 'Barcode',        route: AppRoutes.barcodeGenerator, currentLocation: currentLocation),
          _NavItem(icon: LucideIcons.arrowLeftRight,   label: 'Unit Converter', route: AppRoutes.unitConverter,    currentLocation: currentLocation),
          _NavItem(icon: LucideIcons.cakeSlice,        label: 'Age Calculator', route: AppRoutes.ageCalculator,    currentLocation: currentLocation),
          _NavItem(icon: LucideIcons.calculator,       label: 'EMI Calculator', route: AppRoutes.emiCalculator,    currentLocation: currentLocation),


          const Spacer(),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingLarge - 4),
            child: Container(height: 1, color: AppTheme.sidebarDivider),
          ),
          const SizedBox(height: AppTheme.spacingMedium),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingLarge - 4),
            child: Text('v1.0.0', style: AppTheme.sidebarVersionStyle),
          ),
          const SizedBox(height: AppTheme.spacingLarge),
        ],
      ),
    );
  }
}

class _HomeNavItem extends StatefulWidget {
  @override
  State<_HomeNavItem> createState() => _HomeNavItemState();
}

class _HomeNavItemState extends State<_HomeNavItem> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => context.go('/'),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacingMedium - 4,
            vertical: 3,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacingMedium - 2,
            vertical: AppTheme.spacingMedium - 4,
          ),
          decoration: BoxDecoration(
            color: isHovered
                ? AppTheme.accent.withValues(alpha: 0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(AppTheme.sidebarNavBorderRadius),
          ),
          child: Row(
            children: [
              Icon(
                LucideIcons.arrowLeft,
                size: AppTheme.sidebarNavIconSize,
                color: isHovered ? AppTheme.accent : AppTheme.sidebarInactiveIcon,
              ),
              const SizedBox(width: AppTheme.spacingMedium - 4),
              Text(
                'Main Home',
                style: AppTheme.labelMedium.copyWith(
                  fontSize: AppTheme.sidebarNavFontSize,
                  fontWeight: FontWeight.w400,
                  color: isHovered ? AppTheme.accent : AppTheme.sidebarInactiveIcon,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatefulWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.route,
    required this.currentLocation,
  });

  final IconData icon;
  final String label;
  final String route;
  final String currentLocation;

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> {
  bool isHovered = false;

  bool get isActive => widget.currentLocation == widget.route;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => context.go(widget.route),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacingMedium - 4,
            vertical: 3,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacingMedium - 2,
            vertical: AppTheme.spacingMedium - 4,
          ),
          decoration: BoxDecoration(
            color: isActive
                ? AppTheme.accent.withValues(alpha: 0.12)
                : isHovered
                    ? AppTheme.sidebarHover
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(AppTheme.sidebarNavBorderRadius),
            border: isActive
                ? Border.all(color: AppTheme.accent.withValues(alpha: 0.3))
                : null,
          ),
          child: Row(
            children: [
              Icon(
                widget.icon,
                size: AppTheme.sidebarNavIconSize,
                color: isActive ? AppTheme.accent : AppTheme.sidebarInactiveIcon,
              ),
              const SizedBox(width: AppTheme.spacingMedium - 4),
              Text(
                widget.label,
                style: AppTheme.labelMedium.copyWith(
                  fontSize: AppTheme.sidebarNavFontSize,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                  color: isActive ? AppTheme.textPrimary : AppTheme.sidebarInactiveIcon,
                  letterSpacing: 0.3,
                ),
              ),
              if (isActive) ...[
                const Spacer(),
                Container(
                  width: 4,
                  height: 4,
                  decoration: const BoxDecoration(
                    color: AppTheme.accent,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
