import 'package:flutter/material.dart';
import 'package:frontend/common/app_info.dart';
import 'package:frontend/data/services/auth_service.dart';
import 'package:frontend/data/services/secure_storage_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontend/common/app_route.dart';
import 'package:frontend/common/app_color.dart';
import 'package:frontend/common/screen_utils.dart';
import 'package:google_sign_in/google_sign_in.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controller disesuaikan untuk Login
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  // State untuk UI
  bool _isLoginButtonActive = false;
  bool _isGoogleButtonActive = false;
  bool _isLoading = false;

  // Inisialisasi service
  final _authService = AuthService();
  final _storage = SecureStorageService();
  final _googleSignIn = GoogleSignIn();

  @override
  void initState() {
    super.initState();
    _emailFocusNode.addListener(_onFocusChange);
    _passwordFocusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    setState(() {});
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  // Implementasi logika untuk Login biasa
  Future<void> _handleLogin() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);
      try {
        final response = await _authService.login(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

        await _storage.saveTokens(
          accessToken: response.tokens.accessToken,
          refreshToken: response.tokens.refreshToken,
        );

        if (mounted) {
          AppInfo.success(context, response.message);
          Navigator.pushReplacementNamed(context, AppRoute.dashboard);
        }
      } catch (e) {
        if (mounted) AppInfo.error(context, "Login Gagal: ${e.toString()}");
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

    // Implementasi logika untuk Google Sign-In
  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        setState(() => _isLoading = false);
        return;
      }
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final String? idToken = googleAuth.idToken;

      if (idToken == null) {
        throw Exception('Gagal mendapatkan ID Token dari Google.');
      }

      final response = await _authService.googleSignIn(idToken: idToken);
      await _storage.saveTokens(
        accessToken: response.tokens.accessToken,
        refreshToken: response.tokens.refreshToken,
      );

      if (mounted) {
        AppInfo.success(context, response.message);
        Navigator.pushReplacementNamed(context, AppRoute.dashboard);
      }
    } catch (e) {
      if (mounted) AppInfo.error(context, "Login dengan Google gagal: ${e.toString()}");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }


  @override
  Widget build(BuildContext context) {
    final double screenWidth = context.screenWidth;
    final double screenHeight = context.screenHeight;

    return Scaffold(
      backgroundColor: AppColor.hijauTosca,
      body: SafeArea(
        child: SizedBox(
          width: screenWidth,
          height: screenHeight,
          child: Stack(
            children: [
              _buildMainContent(context, screenWidth, screenHeight),
              if (_isLoading)
                Container(
                  color: Colors.black.withOpacity(0.5),
                  child: const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white))),
                ),
            ],
          ),        ),
      ),
    );
  }

  Widget _buildMainContent(BuildContext context, double screenWidth, double screenHeight) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColor.putihNormal,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Image.asset(
              'assets/images/wave_top.png',
              width: screenWidth,
              height: context.scaleHeight(165),
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Image.asset(
              'assets/images/wave_shark_signin.png',
              width: screenWidth,
              height: context.scaleHeight(165),
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: context.scaleHeight(134),
            left: (screenWidth - context.scaleWidth(360)) / 2,
            child: _buildSignInForm(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSignInForm(BuildContext context) {
    final double formAreaWidth = context.scaleWidth(360);
    final double formAreaHeight = context.scaleHeight(665);

    final double inputFieldWidth = context.scaleWidth(230 * 1.30);
    final double inputFieldHeight = context.scaleHeight(33 * 1.30);

    final double blueBackgroundWidth = context.scaleWidth(265 * 1.30);
    final double blueBackgroundHeight = context.scaleHeight(215 * 1.30);

    final double loginButtonWidth = context.scaleWidth(126 * 1.30);
    final double loginButtonHeight = context.scaleHeight(46 * 1.30);

    final double googleIconWidth = context.scaleWidth(100 * 1.30);
    final double googleIconHeight = context.scaleHeight(33 * 1.30);

    return SizedBox(
      width: formAreaWidth,
      height: formAreaHeight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: context.scaleWidth(273),
            height: context.scaleHeight(144),
            child: Center(
              child: Text(
                'SIGN IN',
                style: GoogleFonts.fredoka(
                  color: AppColor.hijauTosca,
                  fontSize: context.scaleWidth(64),
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
            ),
          ),
          SizedBox(height: context.scaleHeight(22)),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: blueBackgroundWidth,
                height: blueBackgroundHeight,
                child: Image.asset(
                  'assets/images/blue_background.png',
                  fit: BoxFit.contain,
                ),
              ),
              Positioned(
                child: Form(
                  key: _formKey, // Attach GlobalKey to Form
                  child: Column(
                    children: [
                      _buildInputField(
                        context: context,
                        controller: _emailController,
                        focusNode: _emailFocusNode,
                        hintText: 'email',
                        width: inputFieldWidth,
                        height: inputFieldHeight,
                        obscureText: false,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Email tidak boleh kosong';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: context.scaleHeight(45)),
                      _buildInputField(
                        context: context,
                        controller: _passwordController,
                        focusNode: _passwordFocusNode,
                        hintText: 'password',
                        width: inputFieldWidth,
                        height: inputFieldHeight,
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Password tidak boleh kosong';
                          }
                          if (value.length < 6) {
                            return 'Password minimal 6 karakter';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: context.scaleHeight(15)),
                      SizedBox(height: context.scaleHeight(18)),
                      SizedBox(
                        width: inputFieldWidth,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            GestureDetector(
                              onTapDown: (_) => setState(() => _isGoogleButtonActive = true),
                              onTapUp: (_) => setState(() => _isGoogleButtonActive = false),
                              onTapCancel: () => setState(() => _isGoogleButtonActive = false),
                              onTap: () {
                                Navigator.pushReplacementNamed(context, AppRoute.dashboard);
                              },
                              child: AnimatedScale(
                                scale: _isGoogleButtonActive ? 0.95 : 1.0,
                                duration: const Duration(milliseconds: 100),
                                child: SizedBox(
                                  width: googleIconWidth,
                                  height: googleIconHeight,
                                  child: Image.asset(
                                    'assets/images/google_icon.png',
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTapDown: (_) => setState(() => _isLoginButtonActive = true),
                  onTapUp: (_) => setState(() => _isLoginButtonActive = false),
                  onTapCancel: () => setState(() => _isLoginButtonActive = false),
                  onTap: _handleLogin, // Call the validation method
                  child: AnimatedScale(
                    scale: _isLoginButtonActive ? 0.95 : 1.0,
                    duration: const Duration(milliseconds: 100),
                    child: SizedBox(
                      width: loginButtonWidth,
                      height: loginButtonHeight,
                      child: Image.asset(
                        'assets/images/login_button.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: context.scaleHeight(70)),
          SizedBox(
            width: context.scaleWidth(350),
            height: context.scaleHeight(50),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'you don\'t have account? ',
                  style: GoogleFonts.roboto( // Use GoogleFonts consistently
                    color: Colors.black,
                    fontSize: context.scaleWidth(20),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, AppRoute.signUp); // Push to SignUpScreen
                  },
                  child: Text(
                    'Sign up',
                    style: GoogleFonts.roboto( // Use GoogleFonts consistently
                      color: AppColor.biruNormal,
                      fontSize: context.scaleWidth(20),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required BuildContext context,
    required TextEditingController controller,
    required FocusNode focusNode,
    required String hintText,
    required double width,
    required double height,
    bool obscureText = false,
    String? Function(String?)? validator, // Add validator
  }) {
    Color boxColor = AppColor.hijauTosca;
    Color borderColor = focusNode.hasFocus ? AppColor.biruNormal : AppColor.hijauTosca;
    double borderWidth = focusNode.hasFocus ? 2 : 1;
    double blurRadius = focusNode.hasFocus ? 8 : 0;
    Offset offset = focusNode.hasFocus ? const Offset(0, 4) : const Offset(0, 0);

    final double textFontSize = GoogleFonts.roboto().fontSize ?? 16.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: boxColor,
        borderRadius: BorderRadius.circular(context.scaleWidth(25)),
        border: Border.all(color: borderColor, width: borderWidth),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: blurRadius,
            offset: offset,
          ),
        ],
      ),
      child: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: context.scaleWidth(20),
            vertical: (height - textFontSize - 2) / 2,
          ).clamp(
            EdgeInsets.zero,
            EdgeInsets.all(context.scaleWidth(10)),
          ),
          child: TextSelectionTheme(
            data: const TextSelectionThemeData(
              cursorColor: Colors.black,
            ),
            child: TextFormField(
              controller: controller,
              focusNode: focusNode,
              obscureText: obscureText,
              textAlign: TextAlign.center,
              textAlignVertical: TextAlignVertical.center,
              style: GoogleFonts.roboto(
                color: AppColor.whiteText,
                fontSize: context.scaleWidth(16),
                fontWeight: FontWeight.normal,
              ),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: GoogleFonts.roboto(
                  color: AppColor.whiteText,
                  fontSize: context.scaleWidth(16),
                  fontWeight: FontWeight.bold,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                isDense: true,
              ),
              validator: validator, // Assign the validator
            ),
          ),
        ),
      ),
    );
  }
}