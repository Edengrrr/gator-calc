import 'package:flutter/material.dart';

class GatorScreen extends StatelessWidget {
  const GatorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('GATOR')),
      body: const Center(child: (Text('GATOR Calculator'))),
    );
  }
}
