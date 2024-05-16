import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

class IntroductionScreen extends StatefulWidget {
  const IntroductionScreen({super.key});

  @override
  State<IntroductionScreen> createState() => _IntroductionScreenState();
}

class _IntroductionScreenState extends State<IntroductionScreen> {
  int _currentCarouselIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: AnnotatedRegion(
      value: SystemUiOverlayStyle(
        statusBarColor: Theme.of(context).colorScheme.primaryContainer,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        body: Stack(
          children: [
            SingleChildScrollView(
              child: CarouselSlider(
                items: const [
                  SlideContent(
                    title: "Jadikan karya Anda menjadi berharga!",
                    image: "assets/slide1.png",
                  ),
                  SlideContent(
                    title: "Platform pengelolaan dan pameran karya kreatif",
                    image: "assets/slide2.png",
                  ),
                  SlideContent(
                    title: "Semangat untuk menghasilkan karya",
                    image: "assets/slide3.png",
                  ),
                ],
                options: CarouselOptions(
                  height: MediaQuery.of(context).size.height,
                  autoPlay: true,
                  viewportFraction: 1,
                  onPageChanged: (index, reason) {
                    setState(() {
                      _currentCarouselIndex = index;
                    });
                  },
                ),
              ),
            ),
            WelcomeForm(currentCarouselIndex: _currentCarouselIndex),
          ],
        ),
      ),
    ));
  }
}

class SlideContent extends StatelessWidget {
  final String title;
  final String image;

  const SlideContent({
    super.key,
    required this.title,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 50, 0, 50),
            child: Center(
              child: Text(title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 32,
                      color: Theme.of(context).colorScheme.onPrimaryContainer)),
            ),
          ),
          Image(
            image: AssetImage(image),
          ),
        ],
      ),
    );
  }
}

class WelcomeForm extends StatelessWidget {
  final int currentCarouselIndex;

  const WelcomeForm({super.key, this.currentCarouselIndex = 0});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.background,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(32),
            topRight: Radius.circular(32),
          ),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                  3,
                  (index) => index == currentCarouselIndex
                      ? const OnSlideIndicator()
                      : const OffSlideIndicator()),
            ),
            const SizedBox(height: 48),
            FilledButton(
                onPressed: () {
                  context.go('/create-account');
                },
                style: FilledButton.styleFrom(
                  fixedSize: const Size(350, 40),
                ),
                child: const Text('Ayo buat karya pertama Anda!')),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Sudah punya akun?',
                    style: Theme.of(context).textTheme.labelSmall),
                TextButton(
                  onPressed: () {
                    context.go('/login');
                  },
                  style: TextButton.styleFrom(
                    textStyle: Theme.of(context).textTheme.labelSmall,
                  ),
                  child: const Text('Masuk'),
                ),
              ],
            ),
            const SizedBox(
              height: 26,
            ),
            Center(
              child: Text(
                "Dengan melanjutkan berarti Anda setuju dengan persyaratan yang berlaku.",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: const Color.fromRGBO(147, 143, 150, 1),
                    fontSize: 10),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class OffSlideIndicator extends StatelessWidget {
  const OffSlideIndicator({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 6,
      height: 6,
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.tertiaryContainer,
        shape: BoxShape.circle,
      ),
    );
  }
}

class OnSlideIndicator extends StatelessWidget {
  const OnSlideIndicator({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 6,
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }
}
