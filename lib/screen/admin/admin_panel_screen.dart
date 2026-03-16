import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../constant/app_colors.dart';

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
  static const int _users = 1;
  static const int _companies = 2;

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

  Widget _buildResponsiveLayout(BuildContext context) {
    if (_isWide) {
      return Row(
        children: [
          _buildSidebar(context),
          Expanded(child: _buildContent(context)),
        ],
      );
    }
    return Scaffold(
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
    return Container(
      width: width,
      decoration: BoxDecoration(
        color: _isWide ? const Color(0xFF004D4D) : null,
        boxShadow: _isWide ? [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(-2, 0))] : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_isWide)
            Container(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
              decoration: BoxDecoration(
                color: AppColors.tealColor,
                borderRadius: const BorderRadius.only(bottomRight: Radius.circular(12)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.admin_panel_settings, color: Colors.white, size: 26),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Text(
                      'Admin Dashboard',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 16),
          _navItem(Icons.dashboard_outlined, Icons.dashboard_rounded, 'Overview', _overview),
          _navItem(Icons.people_outline, Icons.people_rounded, 'User Management', _users),
          _navItem(Icons.business_outlined, Icons.business_rounded, 'All Companies', _companies),
          const Spacer(),
          if (!_isWide) const Divider(height: 1),
          Container(
            margin: const EdgeInsets.fromLTRB(16, 8, 16, 20),
            child: OutlinedButton.icon(
              onPressed: () => Get.back(),
              icon: const Icon(Icons.arrow_back_rounded, size: 20),
              label: const Text('Back to app'),
              style: OutlinedButton.styleFrom(
                foregroundColor: _isWide ? Colors.white70 : Colors.grey.shade700,
                side: BorderSide(color: _isWide ? Colors.white38 : Colors.grey.shade400),
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
      case _users:
        return _AdminUsersSection();
      case _companies:
        return _AdminCompaniesSection();
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
            ],
          ),
        );
      },
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
                      itemBuilder: (context, index) => _UserTile(documentSnapshot: filtered[index]),
                    ),
            ),
          ],
        );
      },
    );
  }
}

class _UserTile extends StatelessWidget {
  const _UserTile({required this.documentSnapshot});

  final QueryDocumentSnapshot<Map<String, dynamic>> documentSnapshot;

  @override
  Widget build(BuildContext context) {
    final data = documentSnapshot.data();
    final id = documentSnapshot.id;
    final name = _string(data, 'userName') ?? _string(data, 'username') ?? '—';
    final email = _string(data, 'userEmail') ?? _string(data, 'email') ?? '—';
    final isActive = data['isActive'] == true;
    final isAdmin = data['isAdmin'] == true;
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            CircleAvatar(
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
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          name,
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
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
                  const SizedBox(height: 4),
                  Text(
                    email,
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Switch(
              value: isActive,
              onChanged: (value) => _updateIsActive(id, value),
              activeTrackColor: AppColors.tealColor,
              activeColor: Colors.white,
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
                    final name = d['companyName']?.toString() ?? '—';
                    final code = d['companyCode']?.toString() ?? '';
                    return ListTile(
                      dense: true,
                      leading: const Icon(Icons.business_outlined, size: 20),
                      title: Text(name),
                      subtitle: code.isNotEmpty ? Text(code, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)) : null,
                    );
                  }).toList(),
          ),
        );
      },
    );
  }
}
