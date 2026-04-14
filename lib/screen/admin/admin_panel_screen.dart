import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../constant/app_colors.dart';
import '../../constant/app_constant.dart';

/// Full Admin Dashboard: responsive (web + mobile), controls users and app-wide data.
/// Only accessible when current user's Firestore document has [isAdmin] == true.
class AdminPanelScreen extends StatefulWidget {
  static const String pageId = '/AdminPanel';

  const AdminPanelScreen({super.key});

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> {
  int _selectedIndex = 0;
  static const int _overview = 0;
  static const int _usersAndCompanies = 1;

  static const double _sidebarWidth = 280;
  static const double _breakpoint = 900;

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Admin Dashboard'),
          backgroundColor: AppColors.tealColor,
          foregroundColor: Colors.white,
        ),
        body: const Center(child: Text('Not signed in')),
      );
    }

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .snapshots(),
      builder: (context, adminSnap) {
        if (adminSnap.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Admin Dashboard'),
              backgroundColor: AppColors.tealColor,
              foregroundColor: Colors.white,
            ),
            body: const Center(child: CircularProgressIndicator()),
          );
        }
        if (adminSnap.hasError) {
          return Scaffold(
            appBar: AppBar(title: const Text('Admin Dashboard')),
            body: Center(child: Text('Error: ${adminSnap.error}')),
          );
        }
        final adminData = adminSnap.data?.data();
        final isAdmin = adminData?['isAdmin'] == true;
        if (!isAdmin) {
          return _buildAccessDenied(context);
        }
        return _buildResponsiveLayout(context);
      },
    );
  }

  Widget _buildAccessDenied(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: AppColors.tealColor,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.block, size: 64, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              Text(
                'Access Denied',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'You do not have permission to view this page.',
                style: TextStyle(color: Colors.grey.shade600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => Get.back(),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Go back'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.tealColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool get _isWide => MediaQuery.of(context).size.width >= _breakpoint;

  String get _sectionTitle {
    switch (_selectedIndex) {
      case _overview:
        return 'Overview';
      case _usersAndCompanies:
        return 'Users & Companies';
      default:
        return 'Admin Dashboard';
    }
  }

  Widget _buildResponsiveLayout(BuildContext context) {
    if (_isWide) {
      return Scaffold(
        backgroundColor: const Color(0xFFF6F8FA),
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          foregroundColor: Colors.grey.shade900,
          titleSpacing: 20,
          title: Text(
            _sectionTitle,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: TextButton.icon(
                onPressed: () => Get.back(),
                icon: const Icon(Icons.arrow_back_rounded, size: 18),
                label: const Text('Back to app'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.grey.shade800,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
              ),
            ),
          ],
        ),
        body: Row(
          children: [
            _buildSidebar(context),
            Expanded(
              child: Container(
                color: const Color(0xFFF6F8FA),
                child: _buildContent(context),
              ),
            ),
          ],
        ),
      );
    }
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FA),
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: AppColors.tealColor,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
      ),
      drawer: Drawer(
        child: SafeArea(child: _buildSidebar(context)),
      ),
      body: _buildContent(context),
    );
  }

  Widget _buildSidebar(BuildContext context) {
    final width = _isWide ? _sidebarWidth : MediaQuery.of(context).size.width * 0.78;
    final currentUser = FirebaseAuth.instance.currentUser;
    return Container(
      width: width,
      decoration: BoxDecoration(
        color: _isWide ? const Color(0xFF003D3D) : Colors.white,
        boxShadow: _isWide ? [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(-2, 0))] : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: EdgeInsets.fromLTRB(_isWide ? 24 : 18, _isWide ? 28 : 18, _isWide ? 24 : 18, _isWide ? 20 : 14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.tealColor,
                  AppColors.tealColor.withOpacity(0.85),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: _isWide ? const BorderRadius.only(bottomRight: Radius.circular(16)) : null,
            ),
            child: currentUser == null
                ? const SizedBox.shrink()
                : StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                    stream: FirebaseFirestore.instance.collection('users').doc(currentUser.uid).snapshots(),
                    builder: (context, snap) {
                      final d = snap.data?.data();
                      final name = (d?['userName']?.toString().trim().isNotEmpty == true)
                          ? d!['userName'].toString().trim()
                          : (d?['username']?.toString().trim().isNotEmpty == true)
                              ? d!['username'].toString().trim()
                              : (currentUser.displayName?.trim().isNotEmpty == true ? currentUser.displayName!.trim() : '—');
                      final email = (d?['userEmail']?.toString().trim().isNotEmpty == true)
                          ? d!['userEmail'].toString().trim()
                          : (d?['email']?.toString().trim().isNotEmpty == true)
                              ? d!['email'].toString().trim()
                              : (currentUser.email?.trim().isNotEmpty == true ? currentUser.email!.trim() : '');
                      final companyName = AppConstants.companyName.trim().isNotEmpty ? AppConstants.companyName.trim() : 'Select company';
                      final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';

                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.22),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: Colors.white.withOpacity(0.25)),
                            ),
                            child: Center(
                              child: Text(
                                initial,
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800),
                                ),
                                if (email.isNotEmpty) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    email,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(color: Colors.white.withOpacity(0.92), fontSize: 12.5, fontWeight: FontWeight.w500),
                                  ),
                                ],
                                const SizedBox(height: 10),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.18),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.white.withOpacity(0.22)),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.business, size: 16, color: Colors.white),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          companyName,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.w700),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
          ),
          const SizedBox(height: 16),
          _navItem(Icons.dashboard_outlined, Icons.dashboard_rounded, 'Overview', _overview),
          _navItem(Icons.groups_2_outlined, Icons.groups_2_rounded, 'Users & Companies', _usersAndCompanies),
          const Spacer(),
          if (!_isWide) const Divider(height: 1),
          Container(
            margin: const EdgeInsets.fromLTRB(16, 8, 16, 20),
            child: OutlinedButton.icon(
              onPressed: () => Get.back(),
              icon: const Icon(Icons.arrow_back_rounded, size: 20),
              label: const Text('Back to app'),
              style: OutlinedButton.styleFrom(
                foregroundColor: _isWide ? Colors.white70 : Colors.grey.shade800,
                side: BorderSide(color: _isWide ? Colors.white24 : Colors.grey.shade300),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _navItem(IconData iconOut, IconData iconSel, String label, int index) {
    final selected = _selectedIndex == index;
    final isWide = _isWide;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Material(
        color: selected
            ? (isWide ? Colors.white.withOpacity(0.12) : AppColors.tealColor.withOpacity(0.12))
            : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: ListTile(
          leading: Icon(
            selected ? iconSel : iconOut,
            color: selected ? (isWide ? Colors.white : AppColors.tealColor) : (isWide ? Colors.white70 : Colors.grey.shade700),
            size: 22,
          ),
          title: Text(
            label,
            style: TextStyle(
              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              color: selected ? (isWide ? Colors.white : AppColors.tealColor) : (isWide ? Colors.white70 : Colors.grey.shade800),
              fontSize: 15,
            ),
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          onTap: () {
            setState(() => _selectedIndex = index);
            if (!_isWide) Navigator.of(context).pop();
          },
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    switch (_selectedIndex) {
      case _overview:
        return _AdminOverviewSection();
      case _usersAndCompanies:
        // Merged view: user rows with expandable companies + feature toggles.
        return _AdminUsersSection();
      default:
        return _AdminOverviewSection();
    }
  }
}

// --- Overview: app-wide stats ---
class _AdminOverviewSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('users').snapshots(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError) {
          return Center(child: Text('Error: ${snap.error}'));
        }
        final docs = snap.data?.docs ?? [];
        final totalUsers = docs.length;
        final activeUsers = docs.where((d) => d.data()['isActive'] == true).length;
        final adminCount = docs.where((d) => d.data()['isAdmin'] == true).length;
        final inactiveUsers = totalUsers - activeUsers;

        return SingleChildScrollView(
          padding: EdgeInsets.all(_isWide(context) ? 28 : 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Overview',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: Colors.grey.shade800,
                      letterSpacing: -0.5,
                    ),
              ),
              const SizedBox(height: 6),
              Text(
                'App-wide stats and quick actions',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
              ),
              const SizedBox(height: 28),
              LayoutBuilder(
                builder: (context, constraints) {
                  final minCardWidth = 180.0;
                  final crossAxisCount = (constraints.maxWidth / minCardWidth).floor().clamp(1, 4);
                  final isNarrow = constraints.maxWidth < 400;
                  final childAspectRatio = isNarrow ? 0.88 : 1.45;
                  return GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: crossAxisCount,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: childAspectRatio,
                    children: [
                      _StatCard(
                        icon: Icons.people_rounded,
                        label: 'Total Users',
                        value: '$totalUsers',
                        color: AppColors.tealColor,
                      ),
                      _StatCard(
                        icon: Icons.check_circle_rounded,
                        label: 'Active Users',
                        value: '$activeUsers',
                        color: Colors.green.shade600,
                      ),
                      _StatCard(
                        icon: Icons.admin_panel_settings_rounded,
                        label: 'Admins',
                        value: '$adminCount',
                        color: Colors.amber.shade700,
                      ),
                      _StatCard(
                        icon: Icons.person_off_rounded,
                        label: 'Inactive',
                        value: '$inactiveUsers',
                        color: Colors.orange.shade700,
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 28),
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: BorderSide(color: Colors.grey.shade200)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.tealColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.info_outline_rounded, color: AppColors.tealColor, size: 26),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'App-wide control',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600, color: Colors.grey.shade800),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Use User Management to toggle user active status and search or filter users. Use All Companies to browse and search companies across all users.',
                              style: TextStyle(color: Colors.grey.shade600, fontSize: 14, height: 1.4),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _buildCustomerOrderFeatureAdminCard(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCustomerOrderFeatureAdminCard() {
    final user = FirebaseAuth.instance.currentUser;
    final companyId = AppConstants.companyId;

    if (user == null || companyId.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: BorderSide(color: Colors.grey.shade200)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .collection('companies')
              .doc(companyId)
              .snapshots(),
          builder: (context, companySnap) {
            final data = companySnap.data?.data();
            final enabled = data?['enableCustomerOrderFeature'] == true;

            if (companySnap.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.all(12),
                child: Center(child: CircularProgressIndicator()),
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Customer Order Feature',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: Colors.grey.shade800,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Admin can show/hide Customer Orders + Share Order Link.',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13, height: 1.4),
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  value: enabled,
                  onChanged: (val) async {
                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(user.uid)
                        .collection('companies')
                        .doc(companyId)
                        .update({'enableCustomerOrderFeature': val});
                    await AppConstants.setEnableCustomerOrderFeature(val);
                  },
                  title: Text(
                    enabled ? 'Enabled' : 'Disabled',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  activeColor: AppColors.tealColor,
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

bool _isWide(BuildContext context) => MediaQuery.of(context).size.width >= 900;

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final isNarrow = MediaQuery.of(context).size.width < 400;

    // Responsive spacing
    final padding = isNarrow ? 10.0 : 16.0;
    final iconPadding = isNarrow ? 6.0 : 10.0;
    final iconSize = isNarrow ? 22.0 : 26.0;
    final spacing = isNarrow ? 8.0 : 12.0;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: color.withOpacity(0.2)),
      ),
      child: Padding(
        padding: EdgeInsets.all(padding),
        // Overflow થી બચવા માટે Flexible અથવા SingleChildScrollView વાપરી શકાય
        // પણ Column નું alignment સુધારવું એ બેસ્ટ છે.
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start, // Change here
          mainAxisSize: MainAxisSize.min, // Keeping it min
          children: [
            Container(
              padding: EdgeInsets.all(iconPadding),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: iconSize),
            ),
            SizedBox(height: spacing),
            // Wrap text in Flexible or use FittedBox to avoid overflow
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Colors.grey.shade800,
                  fontSize: isNarrow ? 18 : 22, // Adjusted font size
                ),
              ),
            ),
            SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: isNarrow ? 11 : 13,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// --- User Management: search, filter, sort + list ---
enum _UserFilter { all, active, inactive }

enum _UserSort { nameAz, nameZa, emailAz, status }

class _AdminUsersSection extends StatefulWidget {
  @override
  State<_AdminUsersSection> createState() => _AdminUsersSectionState();
}

class _AdminUsersSectionState extends State<_AdminUsersSection> {
  final TextEditingController _searchController = TextEditingController();
  _UserFilter _filter = _UserFilter.all;
  _UserSort _sort = _UserSort.nameAz;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<QueryDocumentSnapshot<Map<String, dynamic>>> _applyFilterAndSort(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    String query = _searchController.text.trim().toLowerCase();
    var list = docs.where((d) {
      final data = d.data();
      final name = (_string(data, 'userName') ?? _string(data, 'username') ?? '').toLowerCase();
      final email = (_string(data, 'userEmail') ?? _string(data, 'email') ?? '').toLowerCase();
      final match = query.isEmpty || name.contains(query) || email.contains(query);
      if (!match) return false;
      switch (_filter) {
        case _UserFilter.active:
          return data['isActive'] == true;
        case _UserFilter.inactive:
          return data['isActive'] != true;
        case _UserFilter.all:
          return true;
      }
    }).toList();

    list.sort((a, b) {
      final ad = a.data();
      final bd = b.data();
      final aname = (_string(ad, 'userName') ?? _string(ad, 'username') ?? '').toLowerCase();
      final bname = (_string(bd, 'userName') ?? _string(bd, 'username') ?? '').toLowerCase();
      final aemail = (_string(ad, 'userEmail') ?? _string(ad, 'email') ?? '').toLowerCase();
      final bemail = (_string(bd, 'userEmail') ?? _string(bd, 'email') ?? '').toLowerCase();
      final aActive = ad['isActive'] == true;
      final bActive = bd['isActive'] == true;
      switch (_sort) {
        case _UserSort.nameAz:
          return aname.compareTo(bname);
        case _UserSort.nameZa:
          return bname.compareTo(aname);
        case _UserSort.emailAz:
          return aemail.compareTo(bemail);
        case _UserSort.status:
          if (aActive == bActive) return aname.compareTo(bname);
          return aActive ? -1 : 1;
      }
    });
    return list;
  }

  String? _string(Map<String, dynamic>? data, String key) {
    if (data == null) return null;
    final v = data[key];
    if (v == null) return null;
    final s = v.toString().trim();
    return s.isEmpty ? null : s;
  }

  Widget _filterDropdown(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButton<_UserFilter>(
        value: _filter,
        underline: const SizedBox(),
        isExpanded: true,
        items: const [
          DropdownMenuItem(value: _UserFilter.all, child: Text('All users')),
          DropdownMenuItem(value: _UserFilter.active, child: Text('Active only')),
          DropdownMenuItem(value: _UserFilter.inactive, child: Text('Inactive only')),
        ],
        onChanged: (v) => setState(() => _filter = v ?? _UserFilter.all),
      ),
    );
  }

  Widget _sortDropdown(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButton<_UserSort>(
        value: _sort,
        underline: const SizedBox(),
        isExpanded: true,
        items: const [
          DropdownMenuItem(value: _UserSort.nameAz, child: Text('Name A-Z')),
          DropdownMenuItem(value: _UserSort.nameZa, child: Text('Name Z-A')),
          DropdownMenuItem(value: _UserSort.emailAz, child: Text('Email A-Z')),
          DropdownMenuItem(value: _UserSort.status, child: Text('Status')),
        ],
        onChanged: (v) => setState(() => _sort = v ?? _UserSort.nameAz),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('users').snapshots(),
      builder: (context, usersSnap) {
        if (usersSnap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (usersSnap.hasError) {
          return Center(child: Text('Error: ${usersSnap.error}'));
        }
        final docs = usersSnap.data?.docs ?? [];
        final filtered = _applyFilterAndSort(docs);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(_isWide(context) ? 28 : 18, 24, _isWide(context) ? 28 : 18, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'User Management',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: Colors.grey.shade800,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Search, filter, and manage user active status',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                  ),
                  const SizedBox(height: 20),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isNarrow = constraints.maxWidth < 700;
                      return isNarrow
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                TextField(
                                  controller: _searchController,
                                  onChanged: (_) => setState(() {}),
                                  decoration: InputDecoration(
                                    hintText: 'Search by name or email...',
                                    prefixIcon: const Icon(Icons.search_rounded),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                    filled: true,
                                    fillColor: Colors.grey.shade50,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _filterDropdown(context),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: _sortDropdown(context),
                                    ),
                                  ],
                                ),
                              ],
                            )
                          : Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: TextField(
                                    controller: _searchController,
                                    onChanged: (_) => setState(() {}),
                                    decoration: InputDecoration(
                                      hintText: 'Search by name or email...',
                                      prefixIcon: const Icon(Icons.search_rounded),
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                      filled: true,
                                      fillColor: Colors.grey.shade50,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                SizedBox(width: 160, child: _filterDropdown(context)),
                                const SizedBox(width: 12),
                                SizedBox(width: 140, child: _sortDropdown(context)),
                              ],
                            );
                    },
                  ),
                  if (filtered.length != docs.length || _searchController.text.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Showing ${filtered.length} of ${docs.length} users',
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                    ),
                  ],
                ],
              ),
            ),
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.person_search_rounded, size: 56, color: Colors.grey.shade400),
                          const SizedBox(height: 12),
                          Text(
                            docs.isEmpty ? 'No users yet' : 'No users match your search or filter',
                            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.fromLTRB(_isWide(context) ? 28 : 18, 0, _isWide(context) ? 28 : 18, 24),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) => _UserWithCompaniesTile(
                        documentSnapshot: filtered[index],
                        searchQuery: _searchController.text.trim().toLowerCase(),
                      ),
                    ),
            ),
          ],
        );
      },
    );
  }
}

class _UserWithCompaniesTile extends StatelessWidget {
  const _UserWithCompaniesTile({
    required this.documentSnapshot,
    required this.searchQuery,
  });

  final QueryDocumentSnapshot<Map<String, dynamic>> documentSnapshot;
  final String searchQuery;

  @override
  Widget build(BuildContext context) {
    final data = documentSnapshot.data();
    final id = documentSnapshot.id;
    final name = _string(data, 'userName') ?? _string(data, 'username') ?? '—';
    final email = _string(data, 'userEmail') ?? _string(data, 'email') ?? '—';
    final isActive = data['isActive'] == true;
    final isAdmin = data['isAdmin'] == true;
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';

    final q = searchQuery.trim().toLowerCase();
    final userMatches = q.isEmpty || name.toLowerCase().contains(q) || email.toLowerCase().contains(q);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          leading: CircleAvatar(
            radius: 24,
            backgroundColor: isActive ? AppColors.tealColor.withOpacity(0.2) : Colors.grey.shade300,
            child: Text(
              initial,
              style: TextStyle(
                color: isActive ? AppColors.tealColor : Colors.grey.shade700,
                fontWeight: FontWeight.w600,
                fontSize: 18,
              ),
            ),
          ),
          title: Row(
            children: [
              Flexible(
                child: Text(
                  name,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (isAdmin) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.tealColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.tealColor.withOpacity(0.5)),
                  ),
                  child: Text('Admin', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.tealColor)),
                ),
              ],
              if (!isActive) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text('Inactive', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Colors.orange.shade800)),
                ),
              ],
            ],
          ),
          subtitle: Text(
            email,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Switch(
            value: isActive,
            onChanged: (value) => _updateIsActive(id, value),
            activeTrackColor: AppColors.tealColor,
            activeColor: Colors.white,
          ),
          children: [
            _UserCompaniesInlineList(
              uid: id,
              searchQuery: q,
              userMatches: userMatches,
            ),
          ],
        ),
      ),
    );
  }

  String? _string(Map<String, dynamic>? data, String key) {
    if (data == null) return null;
    final v = data[key];
    if (v == null) return null;
    final s = v.toString().trim();
    return s.isEmpty ? null : s;
  }

  Future<void> _updateIsActive(String userId, bool value) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'isActive': value,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      if (value) {
        Get.snackbar('Updated', 'User is now active', backgroundColor: Colors.green.shade100);
      } else {
        Get.snackbar('Updated', 'User is now inactive', backgroundColor: Colors.orange.shade100);
      }
    } catch (e) {
      Get.snackbar('Error', e.toString(), backgroundColor: Colors.red.shade100);
    }
  }
}

class _UserCompaniesInlineList extends StatelessWidget {
  const _UserCompaniesInlineList({
    required this.uid,
    required this.searchQuery,
    required this.userMatches,
  });

  final String uid;
  final String searchQuery;
  final bool userMatches;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('users').doc(uid).collection('companies').snapshots(),
      builder: (context, companiesSnap) {
        if (companiesSnap.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(12),
            child: Center(child: SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2))),
          );
        }
        if (companiesSnap.hasError) {
          return Padding(
            padding: const EdgeInsets.all(12),
            child: Text('Error loading companies', style: TextStyle(color: Colors.red.shade600)),
          );
        }

        final allCompanies = companiesSnap.data?.docs ?? [];
        final displayList = (searchQuery.isEmpty || userMatches)
            ? allCompanies
            : allCompanies.where((doc) {
                final d = doc.data();
                final name = (d['companyName']?.toString() ?? '').toLowerCase();
                final code = (d['companyCode']?.toString() ?? '').toLowerCase();
                return name.contains(searchQuery) || code.contains(searchQuery);
              }).toList();

        if (displayList.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(12),
            child: Text('No companies found', style: TextStyle(color: Colors.grey.shade600)),
          );
        }

        return Column(
          children: displayList.map((doc) {
            final d = doc.data();
            final companyId = doc.id;
            final name = d['companyName']?.toString() ?? '—';
            final code = d['companyCode']?.toString() ?? '';
            final customerOrderEnabled = d['enableCustomerOrderFeature'] == true;
            final paymentEnabled = d['enablePaymentReceiptFeature'] != false;
            final purchaseEnabled = d['enablePurchaseFeature'] != false;

            return Card(
              margin: const EdgeInsets.fromLTRB(0, 6, 0, 6),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey.shade200),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: AppColors.tealColor.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(Icons.business_outlined, size: 18, color: AppColors.tealColor),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: Colors.grey.shade900),
                              ),
                              if (code.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 2),
                                  child: Text(code, style: TextStyle(fontSize: 11.5, color: Colors.grey.shade600)),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Features', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.grey.shade800)),
                          const SizedBox(height: 8),
                          _AdminCompanyFeatureToggle(
                            label: 'Customer Orders',
                            icon: Icons.shopping_cart_outlined,
                            enabled: customerOrderEnabled,
                            onChanged: (val) async {
                              await FirebaseFirestore.instance.collection('users').doc(uid).collection('companies').doc(companyId).update({
                                'enableCustomerOrderFeature': val,
                              });
                            },
                          ),
                          const SizedBox(height: 6),
                          _AdminCompanyFeatureToggle(
                            label: 'Payment / Receipt',
                            icon: Icons.payment,
                            enabled: paymentEnabled,
                            onChanged: (val) async {
                              await FirebaseFirestore.instance.collection('users').doc(uid).collection('companies').doc(companyId).update({
                                'enablePaymentReceiptFeature': val,
                              });
                            },
                          ),
                          const SizedBox(height: 6),
                          _AdminCompanyFeatureToggle(
                            label: 'Purchase',
                            icon: Icons.shopping_cart,
                            enabled: purchaseEnabled,
                            onChanged: (val) async {
                              await FirebaseFirestore.instance.collection('users').doc(uid).collection('companies').doc(companyId).update({
                                'enablePurchaseFeature': val,
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

// --- All Companies (across users) with search ---
class _AdminCompaniesSection extends StatefulWidget {
  @override
  State<_AdminCompaniesSection> createState() => _AdminCompaniesSectionState();
}

class _AdminCompaniesSectionState extends State<_AdminCompaniesSection> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  static String? _userString(Map<String, dynamic>? d, String k) {
    if (d == null) return null;
    final v = d[k];
    return v?.toString().trim().isEmpty == true ? null : v?.toString().trim();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('users').snapshots(),
      builder: (context, usersSnap) {
        if (usersSnap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (usersSnap.hasError) {
          return Center(child: Text('Error: ${usersSnap.error}'));
        }
        final userDocs = usersSnap.data?.docs ?? [];
        if (userDocs.isEmpty) {
          return Center(child: Text('No users', style: TextStyle(color: Colors.grey.shade600)));
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(_isWide(context) ? 28 : 18, 24, _isWide(context) ? 28 : 18, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'All Companies',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: Colors.grey.shade800,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Browse companies across all users',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _searchController,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: 'Search by user name, email, or company name...',
                      prefixIcon: const Icon(Icons.search_rounded),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.fromLTRB(_isWide(context) ? 28 : 18, 0, _isWide(context) ? 28 : 18, 24),
                children: userDocs.map((userDoc) {
                  final uid = userDoc.id;
                  final userData = userDoc.data();
                  final userName = _userString(userData, 'userName') ?? _userString(userData, 'username') ?? 'Unknown';
                  final userEmail = _userString(userData, 'userEmail') ?? _userString(userData, 'email') ?? '';
                  return _UserCompaniesTile(
                    uid: uid,
                    userName: userName,
                    userEmail: userEmail,
                    searchQuery: _searchController.text.trim().toLowerCase(),
                  );
                }).toList(),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _UserCompaniesTile extends StatelessWidget {
  const _UserCompaniesTile({
    required this.uid,
    required this.userName,
    required this.userEmail,
    this.searchQuery = '',
  });

  final String uid;
  final String userName;
  final String userEmail;
  final String searchQuery;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('companies')
          .snapshots(),
      builder: (context, companiesSnap) {
        if (companiesSnap.connectionState == ConnectionState.waiting) {
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              title: Text(userName),
              subtitle: Text(userEmail, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
              trailing: const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
            ),
          );
        }
        if (companiesSnap.hasError) {
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              title: Text(userName),
              subtitle: Text('Error loading companies', style: TextStyle(color: Colors.red.shade600)),
            ),
          );
        }
        final allCompanies = companiesSnap.data?.docs ?? [];
        final query = searchQuery.toLowerCase();
        final userMatches = query.isEmpty ||
            userName.toLowerCase().contains(query) ||
            userEmail.toLowerCase().contains(query);
        final filteredCompanies = query.isEmpty
            ? allCompanies
            : allCompanies.where((doc) {
                final d = doc.data();
                final name = (d['companyName']?.toString() ?? '').toLowerCase();
                final code = (d['companyCode']?.toString() ?? '').toLowerCase();
                return name.contains(query) || code.contains(query);
              }).toList();
        final showTile = query.isEmpty || userMatches || filteredCompanies.isNotEmpty;

        if (!showTile) return const SizedBox.shrink();

        if (allCompanies.isEmpty) {
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)),
            child: ListTile(
              leading: CircleAvatar(backgroundColor: Colors.grey.shade300, child: Icon(Icons.person, color: Colors.grey.shade600)),
              title: Text(userName, style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text(userEmail.isNotEmpty ? userEmail : 'No companies', style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
              trailing: Chip(label: Text('0')),
            ),
          );
        }
        final displayList = query.isEmpty ? allCompanies : filteredCompanies;
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)),
          child: ExpansionTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.tealColor.withOpacity(0.2),
              child: Icon(Icons.person, color: AppColors.tealColor),
            ),
            title: Text(userName, style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Text(
              userEmail.isNotEmpty ? userEmail : '${displayList.length} companies',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
            trailing: Chip(
              label: Text('${displayList.length}'),
              backgroundColor: AppColors.tealColor.withOpacity(0.15),
            ),
            children: displayList.isEmpty
                ? [ListTile(title: Text('No companies match "$searchQuery"', style: TextStyle(color: Colors.grey.shade600)))]
                : displayList.map((doc) {
              final d = doc.data();
              final companyId = doc.id;
              final name = d['companyName']?.toString() ?? '—';
              final code = d['companyCode']?.toString() ?? '';
              final customerOrderEnabled = d['enableCustomerOrderFeature'] == true;
              final paymentEnabled = d['enablePaymentReceiptFeature'] != false;
              final purchaseEnabled = d['enablePurchaseFeature'] != false;

              return Card(
                margin: const EdgeInsets.fromLTRB(12, 6, 12, 6),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.grey.shade200),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: AppColors.tealColor.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.business_outlined, size: 18, color: Color(0xFF00897B)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                    color: Colors.grey.shade900,
                                  ),
                                ),
                                if (code.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 2),
                                    child: Text(
                                      code,
                                      style: TextStyle(fontSize: 11.5, color: Colors.grey.shade600),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Features',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Colors.grey.shade800,
                              ),
                            ),
                            const SizedBox(height: 8),
                            _AdminCompanyFeatureToggle(
                              label: 'Customer Orders',
                              icon: Icons.shopping_cart_outlined,
                              enabled: customerOrderEnabled,
                              onChanged: (val) async {
                                try {
                                  await FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(uid)
                                      .collection('companies')
                                      .doc(companyId)
                                      .update({'enableCustomerOrderFeature': val});
                                  Get.snackbar(
                                    val ? 'Feature Enabled ✅' : 'Feature Disabled',
                                    '$name: Customer Orders ${val ? "ON" : "OFF"}',
                                    snackPosition: SnackPosition.BOTTOM,
                                    backgroundColor: val ? Colors.green.shade100 : Colors.orange.shade100,
                                    colorText: Colors.black87,
                                    duration: const Duration(seconds: 2),
                                  );
                                } catch (e) {
                                  Get.snackbar('Error', e.toString(), backgroundColor: Colors.red.shade100);
                                }
                              },
                            ),
                            const SizedBox(height: 6),
                            _AdminCompanyFeatureToggle(
                              label: 'Payment / Receipt',
                              icon: Icons.payment,
                              enabled: paymentEnabled,
                              onChanged: (val) async {
                                try {
                                  await FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(uid)
                                      .collection('companies')
                                      .doc(companyId)
                                      .update({'enablePaymentReceiptFeature': val});
                                  Get.snackbar(
                                    val ? 'Feature Enabled ✅' : 'Feature Disabled',
                                    '$name: Payment / Receipt ${val ? "ON" : "OFF"}',
                                    snackPosition: SnackPosition.BOTTOM,
                                    backgroundColor: val ? Colors.green.shade100 : Colors.orange.shade100,
                                    colorText: Colors.black87,
                                    duration: const Duration(seconds: 2),
                                  );
                                } catch (e) {
                                  Get.snackbar('Error', e.toString(), backgroundColor: Colors.red.shade100);
                                }
                              },
                            ),
                            const SizedBox(height: 6),
                            _AdminCompanyFeatureToggle(
                              label: 'Purchase',
                              icon: Icons.shopping_cart,
                              enabled: purchaseEnabled,
                              onChanged: (val) async {
                                try {
                                  await FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(uid)
                                      .collection('companies')
                                      .doc(companyId)
                                      .update({'enablePurchaseFeature': val});
                                  Get.snackbar(
                                    val ? 'Feature Enabled ✅' : 'Feature Disabled',
                                    '$name: Purchase ${val ? "ON" : "OFF"}',
                                    snackPosition: SnackPosition.BOTTOM,
                                    backgroundColor: val ? Colors.green.shade100 : Colors.orange.shade100,
                                    colorText: Colors.black87,
                                    duration: const Duration(seconds: 2),
                                  );
                                } catch (e) {
                                  Get.snackbar('Error', e.toString(), backgroundColor: Colors.red.shade100);
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),

          ),
        );
      },
    );
  }
}

class _AdminCompanyFeatureToggle extends StatelessWidget {
  const _AdminCompanyFeatureToggle({
    required this.label,
    required this.icon,
    required this.enabled,
    required this.onChanged,
  });

  final String label;
  final IconData icon;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final titleColor = enabled ? Colors.grey.shade900 : Colors.grey.shade700;
    final subColor = enabled ? Colors.green.shade700 : Colors.grey.shade600;
    final iconBg = enabled ? Colors.green.shade50 : Colors.grey.shade100;
    final iconFg = enabled ? Colors.green.shade700 : Colors.grey.shade600;

    return Container(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, size: 16, color: iconFg),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: titleColor),
                ),
                const SizedBox(height: 1),
                Text(
                  enabled ? 'Enabled' : 'Disabled',
                  style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: subColor),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: enabled,
            onChanged: onChanged,
            activeColor: const Color(0xFF00897B),
          ),
        ],
      ),
    );
  }
}
