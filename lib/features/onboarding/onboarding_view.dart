import 'dart:async';
import 'package:flutter/material.dart';
import '../auth/login_view.dart';

class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  final PageController _pageController = PageController();
  int currentIndex = 0;
  Timer? _timer;

  final List<Map<String, String>> onboardingData = [
    {
      "image": "assets/images/onboard1.png",
      "title": "Rekam Aktivitas Harian",
      "desc": "Catat setiap aktivitas harian dengan mudah.",
    },
    {
      "image": "assets/images/onboard2.png",
      "title": "Pantau Perkembangan",
      "desc": "Nikmati prosesnya, dan lihat perkembangannya.",
    },
    {
      "image": "assets/images/onboard3.png",
      "title": "Riwayat Otomatis",
      "desc":
          "Lupa? Bukan masalah, riwayat aktivitas tersimpan secara otomatis.",
    },
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 3), (Timer timer) {
      if (_pageController.hasClients) {
        if (currentIndex < onboardingData.length - 1) {
          currentIndex++;
        } else {
          currentIndex = 0;
        }

        _pageController.animateToPage(
          currentIndex,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/background.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Overlay
          Container(color: const Color(0xFF103A57).withValues(alpha: 0.65)),
          
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 40),

                const Text(
                  "LogBook App - 086",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFECE69D),
                  ),
                ),

                const SizedBox(height: 30),

                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: onboardingData.length,
                    onPageChanged: (index) {
                      setState(() {
                        currentIndex = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              onboardingData[index]["image"]!,
                              height: 220,
                            ),
                            const SizedBox(height: 30),
                            Text(
                              onboardingData[index]["title"]!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFECE69D),
                              ),
                            ),
                            const SizedBox(height: 15),
                            Text(
                              onboardingData[index]["desc"]!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                // Dots 
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    onboardingData.length,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 5),
                      width: currentIndex == index ? 18 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: currentIndex == index
                            ? const Color(0xFF7A9445)
                            : Colors.white54,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // Mulai
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7A9445),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginView(),
                      ),
                    );
                  },
                  child: const Text(
                    "Mulai",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
