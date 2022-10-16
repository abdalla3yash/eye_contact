// ignore_for_file: constant_identifier_names, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'dart:async';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EYE',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomeScreen(),
    );
  }
}

enum ArmAnim {
  NORMAL,
  HI,
  HIDE,
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  Offset hoverPos = Offset.zero;
  String eyesPath = 'assets/images/eye.png';
  double mouthLocation = -0.05;

  ArmAnim _leftArmAnim = ArmAnim.NORMAL;
  ArmAnim _rightArmAnim = ArmAnim.NORMAL;

  double animateHandHi = 0.15;
  late AnimationController _hiController;
  late Animation<double> _hiAnimation;

  double animateHandHide = 0.25;
  late AnimationController _hideController;
  late Animation<double> _hideAnimation;

  bool _armsOpen = true;

  MaterialColor white = const MaterialColor(
    0xFFFFFFFF,
    <int, Color>{
      50: Color(0xFFFFFFFF),
      100: Color(0xFFFFFFFF),
      200: Color(0xFFFFFFFF),
      300: Color(0xFFFFFFFF),
      400: Color(0xFFFFFFFF),
      500: Color(0xFFFFFFFF),
      600: Color(0xFFFFFFFF),
      700: Color(0xFFFFFFFF),
      800: Color(0xFFFFFFFF),
      900: Color(0xFFFFFFFF),
    },
  );

  void _changeImage() {
    setState(() {
      eyesPath = 'assets/images/eye_happy.png';
      mouthLocation = -0.08;
      _armsOpen = false;
    });

    Future.delayed(const Duration(milliseconds: 1000), () {
      setState(() {
        eyesPath = 'assets/images/eye.png';
        mouthLocation = -0.05;
        _armsOpen = true;
      });
    });
  }

  void _animateHi() {
    setState(() => _leftArmAnim = ArmAnim.HI);
    _hiAnimation = Tween<double>(begin: 0.15, end: 0.45).animate(_hiController);
    _hiController.forward();
    _hiAnimation.addListener(() {
      setState(() => animateHandHi = _hiAnimation.value);
    });

    Stream.periodic(const Duration(milliseconds: 500), (value) => value)
        .take(5)
        .listen((event) {
      event % 2 == 0 ? _hiController.reverse() : _hiController.forward();
    }).onDone(() => setState(() => _leftArmAnim = ArmAnim.NORMAL));
  }

  void _animateHide() {
    setState(() {
      _leftArmAnim = ArmAnim.HIDE;
      _rightArmAnim = ArmAnim.HIDE;
    });
    _hideAnimation =
        Tween<double>(begin: 0.25, end: -0.15).animate(_hideController);
    _hideAnimation.addListener(() {
      setState(() => animateHandHide = _hideAnimation.value);
    });

    Future.delayed(const Duration(milliseconds: 1000), () {
      _hideController.forward();
      Future.delayed(const Duration(milliseconds: 1500), () {
        setState(() {
          _leftArmAnim = ArmAnim.NORMAL;
          _rightArmAnim = ArmAnim.NORMAL;
        });
        _hideController.value = 0.0;
      });
    });
  }

  Widget hiAnimation() {
    return Align(
      alignment: const Alignment(-0.5, 0.7),
      child: Transform(
        transform: Matrix4.identity()..setRotationX(135),
        child: Transform(
          transform: Matrix4.rotationZ(animateHandHi),
          alignment: Alignment.topLeft,
          child: Image.asset('assets/images/left_arm.png', width: 180),
        ),
      ),
    );
  }

  Widget hideLeftAnimation() {
    return Align(
      alignment: const Alignment(-0.5, 0.7),
      child: Transform(
        transform: Matrix4.identity()..setRotationX(135),
        child: Transform(
          transform: Matrix4.rotationZ(-0.25),
          alignment: Alignment.topLeft,
          child: Image.asset('assets/images/left_arm.png', width: 180),
        ),
      ),
    );
  }

  Widget hideRightAnimation() {
    return Align(
      alignment: const Alignment(0.5, 0.7),
      child: Transform(
        transform: Matrix4.identity()..setRotationX(135),
        child: Transform(
          transform: Matrix4.rotationZ(animateHandHide),
          alignment: Alignment.topRight,
          child: Image.asset('assets/images/right_arm.png', width: 180),
        ),
      ),
    );
  }

  Widget hideAnimation(bool leftArm) {
    return when(leftArm, {
      true: hideLeftAnimation(),
      false: hideRightAnimation(),
    });
  }

  Widget leftArm() {
    return GestureDetector(
      onTap: () => _animateHi(),
      child: Align(
        alignment: const Alignment(-0.5, 0.5),
        child: TweenAnimationBuilder<Matrix4>(
          duration: const Duration(milliseconds: 500),
          tween: _armsOpen
              ? Matrix4Tween(
                  begin: Matrix4.rotationZ(-0.3),
                  end: Matrix4.rotationZ(0.0),
                )
              : Matrix4Tween(
                  begin: Matrix4.rotationZ(0.0),
                  end: Matrix4.rotationZ(-0.3),
                ),
          builder: (BuildContext context, Matrix4 value, Widget? child) {
            return Transform(
              transform: value,
              alignment: Alignment.topRight,
              child: child,
            );
          },
          child: Image.asset('assets/images/left_arm.png', width: 180),
        ),
      ),
    );
  }

  Widget rightArm() {
    return Align(
      alignment: const Alignment(0.5, 0.5),
      child: TweenAnimationBuilder<Matrix4>(
        duration: const Duration(milliseconds: 500),
        tween: _armsOpen
            ? Matrix4Tween(
                begin: Matrix4.rotationZ(0.3), end: Matrix4.rotationZ(0.0))
            : Matrix4Tween(
                begin: Matrix4.rotationZ(0.0), end: Matrix4.rotationZ(0.3)),
        builder: (BuildContext context, Matrix4 value, Widget? child) {
          return Transform(
            transform: value,
            child: child,
          );
        },
        child: Image.asset('assets/images/right_arm.png', width: 180),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _hiController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _hideController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
  }

  @override
  void dispose() {
    _hiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/images/forest.jpg', fit: BoxFit.cover),
          Opacity(
            opacity: 0.6,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF512DA8), Color(0xFFF57C00)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          MouseRegion(
            onHover: (details) {
              setState(() {
                final size = context.size;
                final center = size!.center(Offset.zero);
                hoverPos = Offset(
                  (details.position.dx - center.dx) / size.width,
                  (details.position.dy - center.dy) / size.height,
                );
              });
            },
            child: GestureDetector(
              onPanUpdate: (details) {
                setState(() {
                  final size = context.size;
                  final center = size!.center(Offset.zero);
                  hoverPos = Offset(
                    (details.localPosition.dx - center.dx) / size.width,
                    (details.localPosition.dy - center.dy) / size.height,
                  );
                });
              },
              onPanEnd: (_) => setState(() => hoverPos = Offset.zero),
              onPanCancel: () => setState(() => hoverPos = Offset.zero),
              child: Transform.scale(
                scale: 0.8,
                child: FittedBox(
                  child: SizedBox(
                    height: 800,
                    width: 800,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => _changeImage(),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.asset('assets/images/body.png'),
                          Align(
                            alignment: Alignment(
                                hoverPos.dx * 0.1, hoverPos.dy * 0.1 - 0.22),
                            child: GestureDetector(
                              onTap: () => _animateHide(),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Image.asset(eyesPath, width: 40),
                                  const SizedBox(width: 120),
                                  Image.asset(eyesPath, width: 40),
                                ],
                              ),
                            ),
                          ),
                          AnimatedAlign(
                            duration: const Duration(milliseconds: 500),
                            alignment: Alignment(0.0, mouthLocation),
                            child: Image.asset('assets/images/mouth.png',
                                width: 60),
                          ),
                          when(_leftArmAnim, {
                            ArmAnim.NORMAL: leftArm(),
                            ArmAnim.HI: hiAnimation(),
                            ArmAnim.HIDE: hideAnimation(true),
                          }),
                          when(_rightArmAnim, {
                            ArmAnim.NORMAL: rightArm(),
                            ArmAnim.HIDE: hideAnimation(false),
                          }),
                        ],
                      ),
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
}

Type when<Input, Type>(Input selectedOption, Map<Input, Type> branches,
    [Type? defaultValue]) {
  if (!branches.containsKey(selectedOption)) {
    return defaultValue!;
  }
  return branches[selectedOption] as Type;
}
