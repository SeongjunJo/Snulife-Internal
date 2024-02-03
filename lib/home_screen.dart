import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        centerTitle: true,
        backgroundColor: Colors.lightBlue,
        automaticallyImplyLeading: false,
        title: const Text(
          'Home',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 48,
          ),
        ),
      ),
      body: GridView.count(
        crossAxisCount: 2,
        children: List.generate(
          16,
          (index) => Center(
            child: Text('Item $index'),
          ),
        ),
      ),
    );
  }
}
