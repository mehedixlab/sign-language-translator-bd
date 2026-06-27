import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_fonts/google_fonts.dart';
import 'camera_screen.dart';

class HomeScreen extends StatelessWidget {
  final List<CameraDescription> cameras;
  const HomeScreen({super.key, required this.cameras});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // ছিমছাম লাইট ব্যাকগ্রাউন্ড
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              
              // মডার্ন হেডার সেকশন
              Text(
                "ইশারা অনুবাদক",
                style: GoogleFonts.hindSiliguri(
                  fontSize: 34,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF2D3142),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "আপনার হাতের ইশারা এখন কথায় রূপ নেবে রিয়েল-টাইমে।",
                textAlign: TextAlign.center,
                style: GoogleFonts.hindSiliguri(
                  fontSize: 18,
                  color: const Color(0xFF9094A6),
                  fontWeight: FontWeight.w500,
                ),
              ),
              
              const Spacer(),

              // মেইন অ্যাকশন বাটন (প্রিমিয়াম সার্কেল ডিজাইন)
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CameraScreen(cameras: cameras),
                    ),
                  );
                },
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.70,
                  height: MediaQuery.of(context).size.width * 0.70,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF4F46E5).withOpacity(0.15),
                        blurRadius: 40,
                        spreadRadius: 10,
                        offset: const Offset(0, 15),
                      )
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(25),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4F46E5).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.camera_rounded,
                          size: 60,
                          color: Color(0xFF4F46E5),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        "ক্যামেরা চালু করুন",
                        style: GoogleFonts.hindSiliguri(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF2D3142),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const Spacer(),

              // ফুটার
              Text(
                "Crafted by Md. Mehedi Hasan",
                style: GoogleFonts.hindSiliguri(
                  fontSize: 15,
                  color: const Color(0xFFB0B3C6),
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}