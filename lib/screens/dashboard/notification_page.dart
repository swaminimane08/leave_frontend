import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../services/api_service.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() =>
      _NotificationPageState();
}

class _NotificationPageState
    extends State<NotificationPage> {

  List notifications = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadNotifications();
  }

  void loadNotifications() async {
    final data = await ApiService.getNotifications();

    setState(() {
      notifications = data;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),

      /// 🔥 Gradient AppBar
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme:
        const IconThemeData(color: Colors.white),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF0D47A1),
                Color(0xFF1976D2),
              ],
            ),
          ),
        ),
        title: const Text(
          "Notifications",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: loading
          ? const Center(
          child: CircularProgressIndicator())
          : notifications.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: notifications.length,
        itemBuilder: (context, index) {

          final item = notifications[index];

          /// 🔥 FIX: LOCAL TIME
          final date = DateFormat(
              "dd MMM yyyy, hh:mm a")
              .format(
            DateTime.parse(item['createdAt'])
                .toLocal(),
          );

          return _buildNotificationCard(
              item, date)
              .animate()
              .fade()
              .slideY(
              begin: 0.2,
              delay: (100 * index).ms);
        },
      ),
    );
  }

  /// 🔥 Notification Card UI (IMPROVED)
  Widget _buildNotificationCard(
      dynamic item, String date) {

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [

          /// 🔔 Icon Circle
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  Color(0xFF0D47A1),
                  Color(0xFF1976D2),
                ],
              ),
            ),
            child: const Icon(
              Icons.notifications,
              color: Colors.white,
              size: 22,
            ),
          ),

          const SizedBox(width: 15),

          /// 🔥 TEXT SECTION
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [

                /// TITLE
                Text(
                  item['title'],
                  style: const TextStyle(
                    fontWeight:
                    FontWeight.bold,
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 6),

                /// MESSAGE
                Text(
                  item['message'],
                  style: TextStyle(
                    color:
                    Colors.grey.shade700,
                    height: 1.5,
                    fontSize: 14,
                  ),
                ),

                const SizedBox(height: 10),

                /// DATE BADGE
                Container(
                  padding:
                  const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4),
                  decoration: BoxDecoration(
                    color:
                    Colors.grey.shade100,
                    borderRadius:
                    BorderRadius.circular(20),
                  ),
                  child: Text(
                    date,
                    style: TextStyle(
                      fontSize: 12,
                      color:
                      Colors.grey.shade600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 🔥 EMPTY STATE
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment:
        MainAxisAlignment.center,
        children: [

          Icon(
            Icons.notifications_none,
            size: 70,
            color: Colors.grey.shade400,
          ),

          const SizedBox(height: 15),

          Text(
            "No Notifications Yet",
            style: TextStyle(
              fontSize: 16,
              color:
              Colors.grey.shade600,
              fontWeight:
              FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}