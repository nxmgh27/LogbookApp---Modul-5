import 'package:flutter/material.dart';
import 'counter_controller.dart';
import '../auth/login_view.dart';

class CounterView extends StatefulWidget {
  final String username;

  const CounterView({super.key, required this.username});

  @override
  State<CounterView> createState() => _CounterViewState();
}

class _CounterViewState extends State<CounterView> {
  late CounterController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = CounterController(username: widget.username);
    _initializeController();
  }

  Future<void> _initializeController() async {
    await _controller.init();
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return PopScope(
      canPop: false, // Menahan fungsi back bawaan sistem
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return; // Jika sudah pop, jangan jalankan lagi

        // Logika navigasi Nike tetap sama, hanya pindah tempat ke sini
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const LoginView(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              var tween = Tween(
                begin: const Offset(-1, 0),
                end: Offset.zero,
              ).chain(CurveTween(curve: Curves.easeInOut));
              return SlideTransition(
                position: animation.drive(tween),
                child: child,
              );
            },
            transitionDuration: const Duration(milliseconds: 500),
          ),
        );
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text(
            "${_controller.getgreeting()}, ${widget.username}👋!",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          backgroundColor: const Color(0xFF243C2C),
          foregroundColor: const Color(0xFFECE69D),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () => _showLogoutDialogToLogin(),
            ),
          ],
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF59789F), Color(0xFFA9B6C4)],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  // Card Hitungan
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    decoration: BoxDecoration(
                      color: const Color(0xFFA9B6C4), // Powder Blue
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          "TOTAL HITUNGAN",
                          style: TextStyle(
                            letterSpacing: 2,
                            color: Color(0xFF243C2C),
                          ),
                        ),
                        const SizedBox(height: 10),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          transitionBuilder: (child, animation) =>
                              FadeTransition(opacity: animation, child: child),
                          child: Text(
                            '${_controller.value}',
                            key: ValueKey<int>(_controller.value),
                            style: const TextStyle(
                              fontSize: 60,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF243C2C),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Step Slider
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFA9B6C4),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        Text(
                          "Step: ${_controller.step}",
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF243C2C),
                          ),
                        ),
                        Slider(
                          value: _controller.step.toDouble(),
                          min: 1,
                          max: 10,
                          divisions: 9,
                          activeColor: const Color(0xFF7A9445), // Moss Green
                          inactiveColor: Colors.white70,
                          onChanged: (value) {
                            setState(() {
                              _controller.setStep(value.toInt());
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildButton(
                        icon: Icons.remove,
                        bgColor: const Color(0xFF243C2C),
                        iconColor: const Color(0xFFECE69D),
                        onPressed: () {
                          setState(() {
                            _controller.decrement();
                          });
                        },
                      ),
                      _buildButton(
                        icon: Icons.refresh,
                        bgColor: const Color(0xFF59789F),
                        iconColor: const Color(0xFFECE69D),
                        onPressed: () => _showResetDialog(),
                      ),
                      _buildButton(
                        icon: Icons.add,
                        bgColor: const Color(0xFF7A9445),
                        iconColor: const Color(0xFFECE69D),
                        onPressed: () {
                          setState(() {
                            _controller.increment();
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),

                  // HISTORY
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFA9B6C4),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: _controller.history.isEmpty
                          ? const Center(
                              child: Text(
                                "Belum ada aktivitas",
                                style: TextStyle(color: Color(0xFF243C2C)),
                              ),
                            )
                          : ListView.separated(
                              itemCount: _controller.history.length,
                              separatorBuilder: (_, _) =>
                                  const Divider(height: 20),
                              itemBuilder: (context, index) {
                                final item = _controller.history[index];

                                IconData icon;
                                Color iconColor;

                                if (item.contains("menambah")) {
                                  icon = Icons.add;
                                  iconColor = const Color(0xFF7A9445);
                                } else if (item.contains("mengurangi")) {
                                  icon = Icons.remove;
                                  iconColor = const Color(0xFF243C2C);
                                } else {
                                  icon = Icons.refresh;
                                  iconColor = const Color(0xFF59789F);
                                }

                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8,
                                    horizontal: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: iconColor.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(icon, color: iconColor, size: 20),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          item,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: iconColor,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildButton({
    required IconData icon,
    required Color bgColor,
    required Color iconColor,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        shape: const CircleBorder(),
        padding: const EdgeInsets.all(20),
        backgroundColor: bgColor,
        elevation: 2,
      ),
      onPressed: onPressed,
      child: Icon(icon, size: 28, color: iconColor),
    );
  }

  void _showResetDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFA9B6C4),
        title: const Text("Konfirmasi Reset"),
        content: const Text(
          "Apakah kamu yakin ingin mereset?\nData riwayat tidak bisa dikembalikan.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF243C2C),
            ),
            onPressed: () {
              setState(() {
                _controller.reset();
              });
              Navigator.pop(context);
            },
            child: const Text("Reset"),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialogToLogin() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFA9B6C4),
        title: const Text("Konfirmasi Logout"),
        content: const Text("Apakah kamu yakin ingin logout?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF243C2C),
            ),
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushAndRemoveUntil(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      const LoginView(),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                        var tween = Tween(
                          begin: const Offset(-1, 0),
                          end: Offset.zero,
                        ).chain(CurveTween(curve: Curves.easeInOut));
                        return SlideTransition(
                          position: animation.drive(tween),
                          child: child,
                        );
                      },
                  transitionDuration: const Duration(milliseconds: 500),
                ),
                (route) => false,
              );
            },
            child: const Text("Logout"),
          ),
        ],
      ),
    );
  }
}
