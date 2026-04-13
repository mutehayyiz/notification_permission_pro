import 'package:flutter/material.dart';
import 'package:notification_permission_pro/notification_permission_pro.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationPermissionPro.initialize();
  runApp(const NotificationPermissionProApp());
}

class NotificationPermissionProApp extends StatelessWidget {
  const NotificationPermissionProApp({super.key});

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      title: 'Notification Permission Pro',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const NotificationPermissionDemoPage(),
    );
  }
}

class NotificationPermissionDemoPage extends StatefulWidget {
  const NotificationPermissionDemoPage({super.key});

  @override
  State<NotificationPermissionDemoPage> createState() =>
      _NotificationPermissionDemoPageState();
}

class _NotificationPermissionDemoPageState
    extends State<NotificationPermissionDemoPage> {
  late NotificationPermissionPro _permissionPro;
  PermissionState _permissionState = PermissionState.unknown;
  bool _isLoading = false;
  String _statusMessage = '';
  int _requestCount = 0;

  @override
  void initState() {
    super.initState();
    _permissionPro = NotificationPermissionPro();
    _loadPermissionStatus();
  }

  Future<void> _loadPermissionStatus() async {
    if (mounted) {
      setState(() => _isLoading = true);
    }

    try {
      final status = await _permissionPro.status;
      final count = _permissionPro.getRequestCount(); // Fetch request count

      if (mounted) {
        setState(() {
          _permissionState = status;
          _requestCount = count;
          _statusMessage = 'Status loaded: ${status.description}';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _statusMessage = 'Error: $e';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _requestPermission() async {
    if (mounted) {
      setState(() => _isLoading = true);
    }

    try {
      final granted = await _permissionPro.requestPermission();

      if (mounted) {
        setState(() {
          _statusMessage = granted
              ? 'Permission granted! 🎉'
              : 'Permission not granted - please enable in settings';
          _isLoading = false;
        });
      }

      // Reload to get updated status and request count
      await _loadPermissionStatus();
    } catch (e) {
      if (mounted) {
        setState(() {
          _statusMessage = 'Request failed: $e';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _refreshStatus() async {
    if (mounted) {
      setState(() => _isLoading = true);
    }

    try {
      await _permissionPro.refresh();
      await _loadPermissionStatus();

      if (mounted) {
        setState(() => _statusMessage = 'Status refreshed!');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _statusMessage = 'Refresh failed: $e';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _openSettings() async {
    try {
      await _permissionPro.openAppSettings();
      if (mounted) {
        setState(() => _statusMessage = 'Opened app settings');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _statusMessage = 'Failed to open settings: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Permission Pro'),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Feature 1: Current Permission Status Display
                    _buildStatusCard(),
                    const SizedBox(height: 16),

                    // Feature 2: Request Permission Button
                    _buildActionButton(
                      label: 'Request Permission',
                      onPressed: _requestPermission,
                      color: Colors.blue,
                    ),
                    const SizedBox(height: 12),

                    // Feature 3: Refresh Status Button
                    _buildActionButton(
                      label: 'Refresh Status',
                      onPressed: _refreshStatus,
                      color: Colors.green,
                    ),
                    const SizedBox(height: 12),

                    // Feature 4: Open Settings Button
                    _buildActionButton(
                      label: 'Open App Settings',
                      onPressed: _openSettings,
                      color: Colors.orange,
                    ),
                    const SizedBox(height: 20),

                    // Feature 5: Request History
                    _buildRequestHistoryCard(),
                    const SizedBox(height: 16),

                    // Feature 6: Permission States Documentation
                    _buildPermissionStatesCard(),
                    const SizedBox(height: 16),

                    // Feature 7: Status Message
                    _buildStatusMessageCard(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildStatusCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Current Permission Status',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _getColorForState(_permissionState),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  _getIconForState(_permissionState),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _permissionState.toString().split('.').last.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          _permissionState.description,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required VoidCallback onPressed,
    required Color color,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(
        label,
        style: const TextStyle(color: Colors.white, fontSize: 14),
      ),
    );
  }

  Widget _buildRequestHistoryCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Request History',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              'Total Requests: $_requestCount',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            Text(
              'The package tracks how many times permission has been requested.',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionStatesCard() {
    final states = [
      ('granted', 'User granted permission - can send notifications'),
      ('denied', 'User denied permission - cannot send notifications'),
      ('notRequested', 'Permission not yet requested from user'),
      ('permanentlyDenied', 'User denied and disabled - requires settings'),
      ('restricted', 'System restricted - user cannot change (iOS only)'),
      ('unknown', 'Permission state could not be determined'),
    ];

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Permission States',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...states.map((state) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '• ',
                      style: TextStyle(fontSize: 14, color: Colors.blue[600]),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            state.$1,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            state.$2,
                            style: const TextStyle(fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusMessageCard() {
    return Card(
      elevation: 2,
      color: _statusMessage.contains('Error') || _statusMessage.contains('failed')
          ? Colors.red[50]
          : Colors.green[50],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(
              _statusMessage.contains('Error') || _statusMessage.contains('failed')
                  ? Icons.error
                  : Icons.info,
              color: _statusMessage.contains('Error') || _statusMessage.contains('failed')
                  ? Colors.red
                  : Colors.green,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _statusMessage.isEmpty ? 'Ready' : _statusMessage,
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getColorForState(PermissionState state) {
    switch (state) {
      case PermissionState.granted:
        return Colors.green;
      case PermissionState.denied:
        return Colors.red;
      case PermissionState.notRequested:
        return Colors.blue;
      case PermissionState.permanentlyDenied:
        return Colors.red.shade700;
      case PermissionState.restricted:
        return Colors.orange;
      case PermissionState.unknown:
        return Colors.grey;
    }
  }

  Widget _getIconForState(PermissionState state) {
    switch (state) {
      case PermissionState.granted:
        return const Icon(Icons.check_circle, color: Colors.white, size: 24);
      case PermissionState.denied:
        return const Icon(Icons.cancel, color: Colors.white, size: 24);
      case PermissionState.notRequested:
        return const Icon(Icons.help, color: Colors.white, size: 24);
      case PermissionState.permanentlyDenied:
        return const Icon(Icons.block, color: Colors.white, size: 24);
      case PermissionState.restricted:
        return const Icon(Icons.lock, color: Colors.white, size: 24);
      case PermissionState.unknown:
        return const Icon(Icons.help_outline, color: Colors.white, size: 24);
    }
  }
}
