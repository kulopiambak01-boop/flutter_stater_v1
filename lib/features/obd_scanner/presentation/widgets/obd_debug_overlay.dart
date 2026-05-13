import 'package:flutter/material.dart';

import 'obd_debug_panel.dart';

class ObdDebugOverlay extends StatefulWidget {
  final Widget child;

  const ObdDebugOverlay({super.key, required this.child});

  @override
  State<ObdDebugOverlay> createState() => _ObdDebugOverlayState();
}

class _ObdDebugOverlayState extends State<ObdDebugOverlay> {
  bool _isDebugPanelVisible = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,

        // Debug button
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton.small(
            onPressed: () {
              setState(() {
                _isDebugPanelVisible = !_isDebugPanelVisible;
              });
            },
            backgroundColor: Colors.black87,
            child: Icon(
              _isDebugPanelVisible ? Icons.close : Icons.bug_report,
              color: Colors.white,
            ),
          ),
        ),

        // Debug panel
        if (_isDebugPanelVisible)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom: 80,
            child: Container(
              margin: const EdgeInsets.all(16),
              child: const ObdDebugPanel(),
            ),
          ),
      ],
    );
  }
}
