import 'package:flutter/material.dart';
import 'package:notification_permission_pro/notification_permission_pro.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize the notification permission package
  await NotificationPermissionPro.initialize();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Notification Permission Pro Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const PermissionPage(),
    );
  }
}

class PermissionPage extends StatefulWidget {
  const PermissionPage({Key? key}) : super(key: key);

  @override
  State<PermissionPage> createState() => _PermissionPageState();
}

class _PermissionPageState extends State<PermissionPage> {
  final _permissionPro = NotificationPermissionPro();
  late Future<PermissionState> _statusFuture;

  @override
  void initState() {
    super.initState();
    _statusFuture = _permissionPro.status;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Permissions'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Permission Status',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            FutureBuilder<PermissionState>(
              future: _statusFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }

                final state = snapshot.data ?? PermissionState.unknown;
                return _StatusCard(state: state);
              },
            ),
            const SizedBox(height: 32),
            const Text(
              'Actions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _ActionButton(
              label: 'Check Status',
              onPressed: () {
                setState(() {
                  _statusFuture = _permissionPro.refresh();
                });
              },
            ),
            const SizedBox(height: 12),
            _ActionButton(
              label: 'Request Permission',
              onPressed: () async {
                final granted = await _permissionPro.requestPermission();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        granted
                            ? 'Permission granted!'
                            : 'Permission denied or current state prevents request',
                      ),
                    ),
                  );
                  setState(() {
                    _statusFuture = _permissionPro.status;
                  });
                }
              },
            ),
            const SizedBox(height: 12),
            _ActionButton(
              label: 'Open App Settings',
              onPressed: () async {
                await _permissionPro.openAppSettings();
              },
            ),
            const SizedBox(height: 32),
            const Text(
              'Debug Info',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _DebugInfo(permissionPro: _permissionPro),
          ],
        ),
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  final PermissionState state;

  const _StatusCard({required this.state});

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    String statusTitle;

    switch (state) {
      case PermissionState.granted:
        statusColor = Colors.green;
        statusTitle = '✓ Notifications Enabled';
        break;
      case PermissionState.denied:
        statusColor = Colors.red;
        statusTitle = '✗ Denied';
        break;
      case PermissionState.notRequested:
        statusColor = Colors.orange;
        statusTitle = '? Not Requested';
        break;
      case PermissionState.permanentlyDenied:
        statusColor = Colors.darkRed;
        statusTitle = '✗ Permanently Denied';
        break;
      case PermissionState.restricted:
        statusColor = Colors.purple;
        statusTitle = '🔒 Restricted (System)';
        break;
      case PermissionState.unknown:
        statusColor = Colors.grey;
        statusTitle = '⚠ Unknown';
        break;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        border: Border.all(color: statusColor, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            statusTitle,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: statusColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Current State: ${state.description}',
            style: TextStyle(color: statusColor),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        child: Text(label),
      ),
    );
  }
}

class _DebugInfo extends StatelessWidget {
  final NotificationPermissionPro permissionPro;

  const _DebugInfo({required this.permissionPro});

  @override
  Widget build(BuildContext context) {
    final requestCount = permissionPro.getRequestCount();
    final wasRequested = permissionPro.wasPermissionRequested();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Permission Requested: ${wasRequested ? "Yes" : "No"}',
            style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
          ),
          const SizedBox(height: 8),
          Text(
            'Request Count: $requestCount',
            style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
          ),
        ],
      ),
    );
  }
}
