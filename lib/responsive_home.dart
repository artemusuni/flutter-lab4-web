import 'package:flutter/material.dart';

/// This widget decides HOW to lay out your content based on width.
/// You will plug your existing Lab 1 content into the `_buildMobileLayout()`.
class ResponsiveHome extends StatelessWidget {
  const ResponsiveHome({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        if (width < 600) {
          // Phone layout – basically your original Lab 1 layout
          return _buildMobileLayout();
        } else if (width < 1100) {
          // Tablet / small desktop
          return _buildTabletLayout();
        } else {
          // Large desktop
          return _buildDesktopLayout();
        }
      },
    );
  }

  Widget _buildMobileLayout() {
    return Scaffold(
      appBar: AppBar(title: const Text('Lab 1 App')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Mobile layout placeholder',
            style: TextStyle(fontSize: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildTabletLayout() {
    return Scaffold(
      appBar: AppBar(title: const Text('Lab 1 App')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: _buildGridLayout(columns: 2),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Scaffold(
      appBar: AppBar(title: const Text('Lab 1 App')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: _buildGridLayout(columns: 3),
        ),
      ),
    );
  }

  Widget _buildGridLayout({required int columns}) {
    final items = List.generate(8, (i) => 'Item $i');

    return GridView.count(
      crossAxisCount: columns,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      padding: const EdgeInsets.all(16),
      children: items.map((title) {
        return Card(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(title, textAlign: TextAlign.center),
            ),
          ),
        );
      }).toList(),
    );
  }
}

