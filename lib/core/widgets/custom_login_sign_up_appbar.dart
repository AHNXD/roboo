import 'package:flutter/material.dart';

class CustomLoginSignUpAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const CustomLoginSignUpAppBar({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final double topPadding = statusBarHeight + MediaQuery.of(context).size.height * 0.01;

    return PreferredSize(
      preferredSize: Size.fromHeight(kToolbarHeight + topPadding),
      child: Container(
        padding: EdgeInsets.only(top: topPadding),
        color: Colors.white,
        child: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios,
              color: Color.fromARGB(202, 61, 59, 59),
              size: 20,
            ),
            onPressed: () {
              Navigator.pop(context); 
            },
          ),
          title: Text(
            title,
            style: const TextStyle(
              color: Color.fromARGB(202, 61, 59, 59),
              fontSize: 30,
            ),
          ),
          centerTitle: true,
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 40);
}
