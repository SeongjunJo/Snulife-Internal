import 'package:flutter/material.dart';
import 'package:snulife_internal/main.dart';

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
        title: Text('Home', style: appFonts.b1),
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
