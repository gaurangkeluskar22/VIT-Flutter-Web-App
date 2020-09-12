import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:vitappflutterweb/src/Screens/HomeScreen.dart';
import 'AddNotices.dart';
import 'package:vitappflutterweb/src/Widgets/SnackBar.dart';
import 'package:vitappflutterweb/src/Widgets/header.dart';
import 'package:vitappflutterweb/src/constants.dart';

enum STATE { SIGNIN, SIGNUP, RESET }

class SignInSignUpPage extends StatefulWidget {
  @override
  _SignInSignUpPageState createState() => _SignInSignUpPageState();
}

class _SignInSignUpPageState extends State<SignInSignUpPage> {
  final _formKey = new GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  STATE _formState = STATE.SIGNIN;
  bool _isLoading;
  bool emailVerified = false;

  void _clearControllers() {
    emailController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
  }

  @override
  void initState() {
    super.initState();
    _isLoading = false;
  }

  bool _validateAndSave() {
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  void _validateAndSubmit() async {
    setState(() {
      _isLoading = true;
    });
    if (_validateAndSave()) {
      if (_formState == STATE.SIGNIN) {
        await FirebaseAuth.instance
            .signInWithEmailAndPassword(
                email: emailController.text.trim(),
                password: passwordController.text.trim())
            .then((value) {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => HomeScreen(),
              ));
        }).catchError((e) {
          _scaffoldKey.currentState.showSnackBar(snackBar(context,
              isErrorSnackbar: true, errorText: 'Invalid credentials'));
        });
      } else if (_formState == STATE.SIGNUP) {
        await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
                email: emailController.text.trim(),
                password: passwordController.text.trim())
            .then((value) {})
            .catchError((e) {
          _scaffoldKey.currentState.showSnackBar(snackBar(context,
              isErrorSnackbar: true, errorText: e.toString()));
        });
      }
    }
    setState(() {
      _isLoading = false;
    });
  }

  void _changeFormToSignUp() {
    _formKey.currentState.reset();
    setState(() {
      _formState = STATE.SIGNUP;
    });
    _clearControllers();
  }

  void _changeFormToSignIn() {
    _formKey.currentState.reset();
    setState(() {
      _formState = STATE.SIGNIN;
    });
  }

  void _changeFormToReset() {
    _formKey.currentState.reset();
    setState(() {
      _formState = STATE.RESET;
    });
    _clearControllers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: header(context,
          isAppTitle: true, isCenterTitle: true, removeBack: false),
      body: Stack(
        children: <Widget>[
          showBody(),
          showCircularProgress(),
        ],
      ),
    );
  }

  Widget showCircularProgress() {
    if (_isLoading) {
      return Container(
        child: Center(
          child: SpinKitFoldingCube(
            color: kPrimaryColor,
            duration: Duration(seconds: 2),
          ),
        ),
      );
    } else {
      return Container(
        height: 0,
        width: 0,
      );
    }
  }

  Widget showBody() {
    return Container(
      height: MediaQuery.of(context).size.height,
      color: _isLoading
          ? Colors.black12.withOpacity(0.1)
          : Colors.black12.withOpacity(0),
      padding: EdgeInsets.only(left: 16.0, right: 16.0),
      child: Form(
        key: _formKey,
        child: ListView(
          shrinkWrap: true,
          children: _formState == STATE.RESET
              ? <Widget>[
                  _showEmailInput(),
                  // _showResetButton(),
                  _showGotoSignInPage(),
                ]
              : <Widget>[
                  _showText(),
                  _showEmailInput(),
                  _showPasswordInput(),
                  _showButton(),
                  // _showAsQuestion(),
                ],
        ),
      ),
    );
  }

  Widget _showGotoSignInPage() {
    return FlatButton(
      splashColor: Colors.transparent,
      onPressed: _changeFormToSignIn,
      child: Text(
        'Login instead ?',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w300),
      ),
    );
  }

  Widget _showErrorMessage(String error) {
    return snackBar(context, isErrorSnackbar: true, errorText: error);
  }

  Widget _showAsQuestion() {
    return FlatButton(
        splashColor: Colors.transparent,
        onPressed: _formState == STATE.SIGNIN
            ? _changeFormToSignUp
            : _changeFormToSignIn,
        child: _formState == STATE.SIGNIN
            ? Padding(
                padding: const EdgeInsets.all(30.0),
                child: Text(
                  'Create an account ?',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w300),
                ),
              )
            : Padding(
                padding: const EdgeInsets.all(30.0),
                child: Text(
                  'Already registered ?',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w300),
                ),
              ));
  }

  Widget _showButton() {
    return Padding(
      padding: EdgeInsets.fromLTRB(0, 45, 0, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            height: 50.0,
            width: 350.0,
            child: Material(
              borderRadius: BorderRadius.circular(5.0),
              elevation: 2.0,
              color: kPrimaryColor,
              child: InkWell(
                onTap: _validateAndSubmit,
                child: _formState == STATE.SIGNIN
                    ? Center(
                        child: Text(
                          'Sign In ',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                          ),
                        ),
                      )
                    : Center(
                        child: Text(
                          'Register ',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                          ),
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _showPasswordInput() {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(0, 15, 0, 0),
          child: TextFormField(
            maxLines: 1,
            obscureText: true,
            autofocus: false,
            controller: passwordController,
            decoration: InputDecoration(
              hintText: 'Enter Password',
              labelText: 'Password',
              border: OutlineInputBorder(),
            ),
            validator: (value) => value.trim().length < 8
                ? 'Password must be of more than 7 character'
                : null,
          ),
        ),
        _formState == STATE.SIGNUP
            ? Padding(
                padding: EdgeInsets.fromLTRB(0, 15, 0, 0),
                child: TextFormField(
                  maxLines: 1,
                  obscureText: true,
                  autofocus: false,
                  controller: confirmPasswordController,
                  decoration: InputDecoration(
                    hintText: 'Enter Confirm Password',
                    labelText: 'Confirm Password',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      passwordController.text.trim() != value.trim()
                          ? 'Passwords do not match'
                          : null,
                ),
              )
            : Padding(
                padding: EdgeInsets.fromLTRB(0, 15, 0, 0),
                child: GestureDetector(
                  onTap: _changeFormToReset,
                  child: Text('Forgot password ?'),
                ),
              ),
      ],
    );
  }

  Widget _showEmailInput() {
    return Padding(
      padding: EdgeInsets.fromLTRB(0, 40, 0, 0),
      child: TextFormField(
        maxLines: 1,
        keyboardType: TextInputType.emailAddress,
        autofocus: false,
        controller: emailController,
        decoration: InputDecoration(
          hintText: 'Enter VIT Email Id',
          labelText: 'Email Id',
          border: OutlineInputBorder(),
        ),
        validator: (value) => !value.trim().endsWith('@vit.edu.in')
            ? 'Email is badly formatted'
            : null,
      ),
    );
  }

  Widget _showText() {
    return Hero(
      tag: 'here',
      child: Padding(
        padding: EdgeInsets.fromLTRB(0, 70, 0, 0),
        child: _formState == STATE.SIGNIN
            ? Center(
                child: Text(
                'Sign In',
                style: TextStyle(
                  fontSize: 40,
                  color: kPrimaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ))
            : Center(
                child: Text(
                'Register',
                style: TextStyle(
                  fontSize: 40,
                  color: kPrimaryColor,
                  fontWeight: FontWeight.bold,
                ),
              )),
      ),
    );
  }
}
