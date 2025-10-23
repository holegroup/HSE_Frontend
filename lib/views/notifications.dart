import 'package:flutter/material.dart';
import 'package:hole_hse_inspection/widgets/admin_scaffold.dart';

class Notifications extends StatelessWidget {
  const Notifications({super.key});

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      title: 'Notifications',
      actions: [TextButton(onPressed: () {}, child: const Text("Read All"))],
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Container(
              width: double.maxFinite,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
              padding: const EdgeInsets.all(8),
              // margin: EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        const TextSpan(
                            text: "Fire estinguisher 238b",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            )),
                        const TextSpan(
                            text: " has marked as",
                            style: TextStyle(color: Colors.black)),
                        TextSpan(
                            text: " Over Due",
                            style: TextStyle(
                              color: Colors.red.shade700,
                              fontWeight: FontWeight.bold,
                            )),
                      ],
                    ),
                  ),
                  const Text('2 hours ago'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        style: const ButtonStyle(
                          // foregroundColor: WidgetStatePropertyAll(Colors.black),
                          backgroundColor:
                              WidgetStatePropertyAll(Colors.white30),
                        ),
                        onPressed: () {},
                        child: const Text("Survey"),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () {},
                        child: const Text("Mark as Read"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
