// ============================================================================
// PHASE 1 MANUAL TEST GUIDE
// ============================================================================
// Add this temporary button/action to any existing screen (e.g. splash screen
// or receptionist dashboard) to test Phase 1 before moving to Phase 2.
// Remove after testing.
// ============================================================================

import 'package:flutter/material.dart';

import '../core/di/service_locator.dart';

class Phase1TestWidget extends StatefulWidget {
  const Phase1TestWidget({super.key});

  @override
  State<Phase1TestWidget> createState() => _Phase1TestWidgetState();
}

class _Phase1TestWidgetState extends State<Phase1TestWidget> {
  String _status = 'Press button to test Phase 1';
  bool _loading = false;

  Future<void> _runTest() async {
    setState(() {
      _loading = true;
      _status = 'Running...';
    });

    try {
      // 1. Force sync
      final result = await ServiceLocator.staffSync.forceSync();
      if (!result.success) {
        setState(() {
          _status = '❌ Sync failed: ${result.error}';
          _loading = false;
        });
        return;
      }

      // 2. Check count
      final count = await ServiceLocator.staffSync.getLocalStaffCount();

      // 3. Test phone lookup — use a real phone from the API response
      //    Replace with any valid phone from your staff list for testing
      const testPhone = '9841301123'; // Safi Joshi, CORPORATE OFFICE
      final found = await ServiceLocator.staffSync.findByPhone(testPhone);

      setState(() {
        _status =
            '''
✅ Sync successful!
Staff synced: $count
Test phone ($testPhone): ${found != null ? '✅ Found: ${found.fullName} (${found.branchName})' : '❌ Not found'}
isHQStaff: ${found?.isHQStaff}
Email: ${found?.email}
''';
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _status = '❌ Error: $e';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Phase 1 Test', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _status,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: _loading ? null : _runTest,
            child: _loading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Run Phase 1 Test'),
          ),
        ],
      ),
    );
  }
}
