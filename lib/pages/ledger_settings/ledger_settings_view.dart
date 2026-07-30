import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../ledger_tab/ledger_tab_view.dart';
import 'ledger_settings_logic.dart';
class LedgerSettingsView extends GetView<LedgerSettingsLogic> {
  const LedgerSettingsView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: MediaQuery.of(context).padding.top),
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 16.h),
            child: Text('Settings',
                style: TextStyle(
                    fontSize: 28.sp,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1A1A1A),
                    letterSpacing: -0.5)),
          ),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Data Management'),
                  _buildSettingsCard([
                    _buildSettingsRow(
                      iconBg: const Color(0xFFFEF2F2),
                      icon: Icons.delete_rounded,
                      iconColor: const Color(0xFFD94F4F),
                      title: 'Clear All Journals',
                      subtitle: 'Delete all journals, photos, and drafts',
                      titleColor: const Color(0xFFD94F4F),
                      onTap: controller.onClearAllTap,
                      showDivider: false,
                    ),
                  ]),
                  _buildSectionTitle('Storage'),
                  Obx(() => _buildSettingsCard([
                    _buildSettingsRow(
                      iconBg: const Color(0xFFF2F5F3),
                      icon: Icons.storage_rounded,
                      iconColor: const Color(0xFF1A3C34),
                      title: 'Journals Stored',
                      subtitle:
                          '${controller.journalCount.value} journal${controller.journalCount.value != 1 ? 's' : ''} · ${controller.photoCount.value} photo${controller.photoCount.value != 1 ? 's' : ''}',
                      trailing: Text(
                          controller.storageMB.value < 0.1
                              ? '< 0.1 MB'
                              : '${controller.storageMB.value.toStringAsFixed(1)} MB',
                          style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF6B7280))),
                      showDivider: false,
                    ),
                  ])),
                  _buildSectionTitle('About'),
                  _buildAboutCard(),
                  SizedBox(height: LedgerTabView.tabOverlayInset(context)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 8.h),
      child: Text(title.toUpperCase(),
          style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF6B7280),
              letterSpacing: 0.8)),
    );
  }
  Widget _buildSettingsCard(List<Widget> rows) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(children: rows),
    );
  }
  Widget _buildSettingsRow({
    required Color iconBg,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    Color? titleColor,
    Widget? trailing,
    VoidCallback? onTap,
    required bool showDivider,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 15.h),
            child: Row(
              children: [
                Container(
                  width: 34.w, height: 34.w,
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(icon, size: 16.sp, color: iconColor),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w500,
                              color: titleColor ?? const Color(0xFF1A1A1A))),
                      SizedBox(height: 1.h),
                      Text(subtitle,
                          style: TextStyle(
                              fontSize: 12.sp,
                              color: const Color(0xFF9CA3AF))),
                    ],
                  ),
                ),
                if (trailing != null) trailing
                else if (onTap != null)
                  Icon(Icons.chevron_right_rounded,
                      size: 16.sp, color: const Color(0xFFD1D5DB)),
              ],
            ),
          ),
          if (showDivider)
            Container(
              height: 1,
              color: const Color(0xFFE8EBE9),
              margin: EdgeInsets.only(left: 62.w),
            ),
        ],
      ),
    );
  }
  Widget _buildAboutCard() {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 24.h, 16.w, 24.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 72.w, height: 72.w,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF1A3C34), Color(0xFF2D5A4E)],
                    ),
                    borderRadius: BorderRadius.circular(18.r),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF1A3C34).withOpacity(0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(Icons.map_rounded,
                      color: const Color(0xFFC9A84C), size: 32.sp),
                ),
                SizedBox(height: 12.h),
                Text('Go See',
                    style: TextStyle(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF1A1A1A))),
                SizedBox(height: 4.h),
                Text('"The world is vast, worth seeing"',
                    style: TextStyle(
                        fontSize: 14.sp,
                        color: const Color(0xFF6B7280),
                        fontStyle: FontStyle.italic)),
                SizedBox(height: 8.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2F5F3),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(LedgerSettingsLogic.appVersionLabel,
                      style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF6B7280))),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
