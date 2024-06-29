import 'package:car_rent_flutter/screens/login_screen.dart';
import 'package:car_rent_flutter/screens/main_layout.dart';
import 'package:car_rent_flutter/utils/firebase_manager.dart';
import 'package:car_rent_flutter/utils/utils.dart';
import 'package:car_rent_flutter/widgets/auth_button.dart';
import 'package:car_rent_flutter/widgets/text_field_input.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwdController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
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
    phoneController.dispose();
    super.dispose();
  }

  void _onSignUp(context) async {
    String res = await FirebaseManager.instance.signUpUser(
        email: emailController.text,
        password: passwdController.text,
        phoneNumber: phoneController.text);
    if (res == "success") {
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const MainLayout()));
    } else {
      print(res);
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
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(flex: 2, child: Container()),
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
              const SizedBox(height: 32),
              SlideTransition(
                position: _slideAnimation,
                child: TextFieldInput(
                  hintText: "+973 12345678",
                  icon: Icons.phone,
                  controller: phoneController,
                ),
              ),
              SlideTransition(
                position: _slideAnimation,
                child: AuthButton(
                  backgroundColor: Colors.redAccent,
                  text: "Sign Up",
                  func: () {
                    _onSignUp(context);
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
                      "Already have an account?",
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => {
                      Navigator.of(context).pushReplacement(MaterialPageRoute(
                          builder: (context) => const LoginScreen()))
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: const Text(
                        "Log in",
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
