import 'package:car_rent_flutter/utils/globals.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  late PageController pageController;
  String username = "";
  int _page = 0;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // getUsername();
    pageController = PageController();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    pageController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        physics: NeverScrollableScrollPhysics(),
        children: HomeScreenItems,
        controller: pageController,
      ),
      // ignore: prefer_const_literals_to_create_immutables
      bottomNavigationBar: CupertinoTabBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.car_rental_rounded,
              color: _page == 0 ? Colors.redAccent : Colors.grey,
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.search,
              color: _page == 1 ? Colors.redAccent : Colors.grey,
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.add_box,
              color: _page == 2 ? Colors.redAccent : Colors.grey,
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.map,
              color: _page == 3 ? Colors.redAccent : Colors.grey,
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.person,
              color: _page == 4 ? Colors.redAccent : Colors.grey,
            ),
            label: '',
          ),
        ],
        onTap: (int page) {
          setState(() {
            _page = page;
          });
          navigateTab(page);
        },
      ),
    );
  }

  void navigateTab(int page) {
    pageController.jumpToPage(page);
  }
}
