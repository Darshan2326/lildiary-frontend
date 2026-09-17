import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:lildairy/screens/HomeScreen.dart';

class AppIntroductionScreen extends StatefulWidget {
  const AppIntroductionScreen({Key? key}) : super(key: key);

  @override
  State<AppIntroductionScreen> createState() => _AppIntroductionScreenState();
}

class _AppIntroductionScreenState extends State<AppIntroductionScreen> {
  @override
  Widget build(BuildContext context) {
    return IntroductionScreen(
      pages: [
        PageViewModel(
          title: "Capture Every Moment",
          body:
              "From your baby's first smile to their first steps, easily document and preserve all those special milestones. Our app helps you create a personalized baby book, filled with memories you'l cherish forever. :",
          decoration: PageDecoration(
            titleTextStyle:
                TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            imagePadding: EdgeInsets.only(top: 50),
            pageColor: Colors.white,
            bodyPadding: EdgeInsets.only(top: 20, left: 20, right: 20),
            titlePadding: EdgeInsets.only(top: 20),
            bodyTextStyle: TextStyle(color: Colors.black54, fontSize: 20),
          ),
          image: Image.asset("assets/images/first.png"),
        ),
        PageViewModel(
            title: "Capture Every Moment",
            body:
                "From your baby's first smile to their first steps, easily document and preserve all those special milestones. Our app helps you create a personalized baby book, filled with memories you'l cherish forever. :",
            decoration: PageDecoration(
              titleTextStyle:
                  TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              imagePadding: EdgeInsets.only(top: 50),
              pageColor: Colors.white,
              bodyPadding: EdgeInsets.only(top: 20, left: 20, right: 20),
              titlePadding: EdgeInsets.only(top: 20),
              bodyTextStyle: TextStyle(color: Colors.black54, fontSize: 20),
            ),
            image: Image.asset("assets/images/second.png")),
        PageViewModel(
          title: "Capture Every Moment",
          body:
              "From your baby's first smile to their first steps, easily document and preserve all those special milestones. Our app helps you create a personalized baby book, filled with memories you'l cherish forever. :",
          decoration: PageDecoration(
            titleTextStyle:
                TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            imagePadding: EdgeInsets.only(top: 50),
            pageColor: Colors.white,
            bodyPadding: EdgeInsets.only(top: 20, left: 20, right: 20),
            titlePadding: EdgeInsets.only(top: 20),
            bodyTextStyle: TextStyle(color: Colors.black54, fontSize: 20),
          ),
          image: Image.asset("assets/images/third.png"),
        ),
      ],
      onDone: () {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => NotesHomeScreen()),
        );
      },
      dotsDecorator: DotsDecorator(
        size: const Size.square(10.0),
        activeSize: const Size(20.0, 10.0),
        activeColor: Color(0xFF4FC3F7),
        // activeColor: Theme.of(context).colorScheme.secondary,
        color: Colors.black26,
        spacing: const EdgeInsets.symmetric(horizontal: 3.0),
        activeShape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0)),
      ),
      showSkipButton: true,
      skip: const Text(
        "Skip",
        style: TextStyle(color: Color(0xFF4FC3F7), fontWeight: FontWeight.bold),
      ),
      next: const Icon(
        Icons.arrow_forward,
        color: Color(0xFF4FC3F7),
      ),
      done: const Text(
        "Done",
        style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF4FC3F7)),
      ),
    );
  }
}
