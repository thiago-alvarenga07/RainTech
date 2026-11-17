import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/water_data_state.dart';
import 'demand_dashboard.dart';
import 'rain_dashboard.dart';
import 'reservoir_dashboard.dart';

/// Agrupa os 3 dashboards territoriais em abas.
class DashboardsPage extends StatelessWidget {
  const DashboardsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Painéis'),
          actions: [
            IconButton(
              tooltip: 'Atualizar dados',
              onPressed: context.read<WaterDataState>().load,
              icon: const Icon(Icons.refresh),
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.water), text: 'Reservatórios'),
              Tab(icon: Icon(Icons.grain), text: 'Chuva'),
              Tab(icon: Icon(Icons.groups_outlined), text: 'Demanda'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [ReservoirDashboard(), RainDashboard(), DemandDashboard()],
        ),
      ),
    );
  }
}