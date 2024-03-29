import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:user_auth/screens/forget_password.dart';
import 'package:user_auth/screens/home_screen.dart';
import 'package:user_auth/screens/registration_screen.dart';
import 'package:user_auth/screens/verify.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController emailController = new TextEditingController();

  final TextEditingController passwordController = new TextEditingController();

  final _auth = FirebaseAuth.instance;

  late SharedPreferences logindata;

  late bool newuser;

  bool _hidePassword = true;

  //persistent Login
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkLoginActivity();
  }

  //persistent Login
  void checkLoginActivity() async {
    logindata = await SharedPreferences.getInstance();
    newuser = (logindata.getBool('login') ?? true);
    if (newuser == false) {
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => HomeScreen()));
    }
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final emailField = TextFormField(
      autofocus: false,
      controller: emailController,
      keyboardType: TextInputType.emailAddress,
      validator: (value) {
        if (value!.isEmpty) {
          return ("Please Enter Your Email");
        }
        // reg expression for email validation
        if (!RegExp("^[a-zA-Z0-9.a-zA-Z0-9.@[a-zA-Z0-9]+.[a-zA-Z]+")
            .hasMatch(value)) {
          return ("Please Enter a valid Email address");
        }
        return null;
      },
      onSaved: (value) {
        emailController.text = value ?? "";
      },
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.mail),
        contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
        hintText: "Email",
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    ); //email field

    final passwordField = TextFormField(
      autofocus: false,
      controller: passwordController,
      obscureText: _hidePassword,
      validator: (value) {
        RegExp regex = new RegExp(r'^.{6,}$');
        if (value!.isEmpty) {
          return ("Passoword is required for login");
        }
        if (!regex.hasMatch(value)) {
          return ("Please Enter Valid  Password(Min, 6 Characters)");
        }
        return null;
      },
      onSaved: (value) {
        passwordController.text = value ?? "";
      },
      textInputAction: TextInputAction.done,
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.vpn_key),
        suffixIcon: GestureDetector(
          onTap: () {
            setState(() {
              _hidePassword = !_hidePassword;
            });
          },
          child: Icon(_hidePassword ? Icons.visibility : Icons.visibility_off),
        ),
        contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
        hintText: "Password",
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    ); // password field

    final loginButton = Material(
      elevation: 5,
      borderRadius: BorderRadius.circular(30),
      color: Colors.green,
      child: MaterialButton(
        padding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
        minWidth: MediaQuery.of(context).size.width,
        onPressed: () async {
          signIn(emailController.text, passwordController.text);
        },
        child: const Text(
          "Login",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(36.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(
                      height: 200,
                      child: Image.asset(
                        "assets/logo.jpg",
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    emailField,
                    const SizedBox(
                      height: 25,
                    ),
                    passwordField,
                    const SizedBox(
                      height: 5,
                    ),
                    forgetPassword(context),
                    loginButton,
                    const SizedBox(
                      height: 15,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        const Text("Don't have an account? "),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const RegistrationScreen()));
                          },
                          child: const Text(
                            "Sign up!",
                            style: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.w600,
                                fontSize: 15),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void signIn(String email, String password) async {
    _formKey.currentState!.save();
    if (_formKey.currentState!.validate()) {
      try {
        final user = await _auth.signInWithEmailAndPassword(
            email: email, password: password);
        // print("hello ${user}");

        if (user.user!.emailVerified) {
          Navigator.of(context)
              .pushReplacement(
                  MaterialPageRoute(builder: (context) => HomeScreen()))
              .catchError((e) {
            Fluttertoast.showToast(msg: e!.message);
          });
          logindata.setBool('login', false);
        
        } else {
          Fluttertoast.showToast(msg: "Email is not verified");
          Navigator.pushAndRemoveUntil(
              (context),
              MaterialPageRoute(builder: (context) => const VerifyScreen()),
              (route) => false);
        }
      } catch (e) {
        Fluttertoast.showToast(msg: "Email is not registered!");
      }
    }
  }

  Widget forgetPassword(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 35,
      alignment: Alignment.bottomRight,
      child: TextButton(
        child: const Text(
          "Forget Password?",
          textAlign: TextAlign.right,
        ),
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const ForgetPassword()));
        },
      ),
    );
  }
}
