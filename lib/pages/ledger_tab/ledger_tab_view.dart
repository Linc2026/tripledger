import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'ledger_tab_logic.dart';
import '../ledger_home/ledger_home_view.dart';
import '../ledger_settings/ledger_settings_view.dart';
class LedgerTabView extends GetView<LedgerTabLogic> {
  const LedgerTabView({super.key});
  static double tabOverlayInset(BuildContext context) =>
      64.h + 24.h + MediaQuery.of(context).viewPadding.bottom;
  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        backgroundColor: const Color(0xFFFAFAFA),
        extendBody: true,
        body: IndexedStack(
          index: controller.currentIndex.value,
          children: const [LedgerHomeView(), LedgerSettingsView()],
        ),
        bottomNavigationBar: _buildTabBar(context),
      ),
    );
  }
  Widget _buildTabBar(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 0),
        child: Container(
          height: 64.h,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32.r),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1A3C34).withOpacity(0.08),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Obx(
            () => Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildTabItem(
                  icon: Icons.home_rounded,
                  label: 'Home',
                  index: 0,
                  tabIndex: 0,
                ),
                _buildCenterAddButton(),
                _buildTabItem(
                  icon: Icons.settings_rounded,
                  label: 'Settings',
                  index: 2,
                  tabIndex: 1,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  Widget _buildTabItem({
    required IconData icon,
    required String label,
    required int index,
    required int tabIndex,
  }) {
    final isActive = controller.currentIndex.value == tabIndex;
    final color = isActive ? const Color(0xFF1A3C34) : const Color(0xFF9CA3AF);
    return GestureDetector(
      onTap: () => controller.onTabTap(index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 64.w,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              padding: EdgeInsets.all(isActive ? 6.w : 0),
              decoration: BoxDecoration(
                color: isActive
                    ? const Color(0xFF1A3C34).withOpacity(0.08)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: Icon(icon, size: 24.sp, color: color),
            ),
            SizedBox(height: 2.h),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                color: color,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildCenterAddButton() {
    return GestureDetector(
      onTap: () => controller.onTabTap(1),
      child: Container(
        width: 48.w,
        height: 48.w,
        decoration: BoxDecoration(
          color: const Color(0xFF1A3C34),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1A3C34).withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(Icons.add_rounded, color: Colors.white, size: 28.sp),
      ),
    );
  }
}
