import 'package:flutter/material.dart';

class DashboardActionsWidget extends StatelessWidget {
  const DashboardActionsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final secondaryColor = theme.colorScheme.secondary;
    final onPrimary = theme.colorScheme.onPrimary;
    final primaryColor = theme.colorScheme.primary;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            width: double.infinity,
            height: 30,
            decoration: BoxDecoration(
                border:
                    Border(bottom: BorderSide(color: primaryColor, width: 1))),
            child: const Text(
              'Jenis',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            ),
          ),
        ),
        const SizedBox(height: 25),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildActionButton(
                      context: context,
                      icon: Icons.pie_chart,
                      label: 'Grafik',
                      secondaryColor: secondaryColor,
                      onPrimary: onPrimary,
                      onTap: () {}),
                  _buildActionButton(
                      context: context,
                      icon: Icons.category,
                      label: 'Categories',
                      secondaryColor: secondaryColor,
                      onPrimary: onPrimary,
                      onTap: () {}),
                  _buildActionButton(
                      context: context,
                      icon: Icons.wallet,
                      label: 'e-wallet',
                      secondaryColor: secondaryColor,
                      onPrimary: onPrimary,
                      onTap: () {}),
                ],
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color secondaryColor,
    required Color onPrimary,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        height: 70,
        decoration: BoxDecoration(
            color: secondaryColor,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(color: onPrimary, blurRadius: 5, spreadRadius: 0.2)
            ]),
        child: Align(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: onPrimary),
              const SizedBox(height: 5),
              Text(
                label,
                style: TextStyle(fontSize: 10, color: onPrimary),
              )
            ],
          ),
        ),
      ),
    );
  }
}
