import 'package:car_rent_flutter/screens/login_screen.dart';
import 'package:car_rent_flutter/screens/main_layout.dart';
import 'package:car_rent_flutter/screens/signup_screen.dart';
import 'package:car_rent_flutter/utils/firebase_manager.dart';
import 'package:car_rent_flutter/utils/utils.dart';
import 'package:car_rent_flutter/widgets/auth_button.dart';
import 'package:car_rent_flutter/widgets/text_field_input.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwdController = TextEditingController();
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(-1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    emailController.dispose();
    passwdController.dispose();
    super.dispose();
  }

  void _onLogin(context) async {
    String res = await FirebaseManager.instance.loginUser(
        email: emailController.text, password: passwdController.text);
    if (res == "success") {
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const MainLayout()));
    } else {
      showSnackBar(res, context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/audi-background.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(child: Container(), flex: 2),
              Text(
                "Rent & Roam Bahrain",
                style: TextStyle(
                  fontFamily: 'Racing',
                  fontSize: 50,
                  foreground: Paint()
                    ..shader = const LinearGradient(
                      colors: [
                        Colors.white,
                        Colors.redAccent,
                        Colors.red,
                      ],
                    ).createShader(
                        const Rect.fromLTWH(100.0, 0.0, 200.0, 70.0)),
                ),
              ),
              const SizedBox(height: 32),
              SlideTransition(
                position: _slideAnimation,
                child: TextFieldInput(
                  hintText: "example@gmail.com",
                  icon: Icons.email,
                  controller: emailController,
                ),
              ),
              const SizedBox(height: 32),
              SlideTransition(
                position: _slideAnimation,
                child: TextFieldInput(
                  hintText: "password",
                  icon: Icons.lock,
                  controller: passwdController,
                  obscureText: true,
                ),
              ),
              SlideTransition(
                position: _slideAnimation,
                child: AuthButton(
                  backgroundColor: Colors.redAccent,
                  text: "Log in",
                  func: () {
                    _onLogin(context);
                  },
                  borderColor: Colors.white,
                  textColor: Colors.white,
                ),
              ),
              Flexible(flex: 2, child: Container()),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: const Text(
                      "Don't have an account?",
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => {
                      Navigator.of(context).pushReplacement(MaterialPageRoute(
                          builder: (context) => const SignUpScreen()))
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: const Text(
                        "Sign Up",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.redAccent),
                      ),
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
