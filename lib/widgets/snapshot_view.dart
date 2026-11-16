import 'package:flutter/material.dart';

import '../models/water_snapshot.dart';

class SnapshotView extends StatelessWidget {
  const SnapshotView({
    super.key,
    required this.snapshotFuture,
    required this.onRefresh,
    required this.builder,
  });

  final Future<WaterSnapshot> snapshotFuture;
  final VoidCallback onRefresh;
  final Widget Function(WaterSnapshot snapshot) builder;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<WaterSnapshot>(
      future: snapshotFuture,
      builder: (context, result) {
        if (result.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.cloud_off_outlined, size: 44),
                  const SizedBox(height: 12),
                  const Text(
                    'Não foi possível carregar os dados.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Text(result.error.toString(), textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: onRefresh,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Tentar novamente'),
                  ),
                ],
              ),
            ),
          );
        }

        if (!result.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        return builder(result.data!);
      },
    );
  }
}
