import 'package:flutter/material.dart';
import 'package:lildairy/screens/bottom_bar_screen/add_new_note.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutUsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('About Us'),
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Image
              Center(
                child: Image.asset(
                  'assets/logos/Logo_png.png', // Add your header image
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(height: 20),
              // Welcome Text
              Text(
                'Welcome to LillDiary!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF81D4FA),
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Your ultimate family memory keeper! LillDiary helps parents create a secure and beautifully organized online diary to capture precious moments of their little ones—from birth and beyond.',
                style: TextStyle(fontSize: 16, color: Colors.grey[800]),
              ),
              SizedBox(height: 20),
              // Features Section
              Text(
                'Why Choose LillDiary?',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF81D4FA),
                ),
              ),
              SizedBox(height: 10),
              ListView(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                children: [
                  _buildFeatureTile(
                      Icons.camera_alt, 'Save photos, videos, and memories.'),
                  _buildFeatureTile(
                      Icons.timeline, 'Log milestones automatically.'),
                  _buildFeatureTile(
                      Icons.cloud_upload, 'Unlimited secure storage.'),
                  _buildFeatureTile(Icons.people,
                      'Collaborate with family and friends privately.'),
                  _buildFeatureTile(
                      Icons.print, 'Download and print beautiful keepsakes.'),
                ],
              ),
              SizedBox(height: 20),
              // Our Story Section
              Text(
                'Our Story',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF81D4FA),
                ),
              ),
              SizedBox(height: 10),
              Text(
                'LillDiary began as a passion project by parents who wanted to preserve their daughter’s milestones. Combining technology and creativity, we’ve built a seamless platform for families to cherish their memories.',
                style: TextStyle(fontSize: 16, color: Colors.grey[800]),
              ),
              SizedBox(height: 20),
              // Footer
              Center(
                child: ElevatedButton(
                  style: ButtonStyle(
                    shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          side: const BorderSide(color: Color(0xFF4FC3F7)),

                        )
                    ),
                  ),
                  onPressed: (){
                    launch("https://lildiary.com/about/");

                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [

                      const SizedBox(width: 10),
                      const Text(
                        "Building Memories With",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Colors.black45,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Image.asset(
                          "assets/logos/Logo_png.png",
                          height: 35,
                        ),
                      ),
                    ],
                  ),


                ),


              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper function to create feature tiles
  Widget _buildFeatureTile(IconData icon, String text) {
    return ListTile(
      leading: Icon(icon, color: Color(0xFFF48FB1)),
      title: Text(
        text,
        style: TextStyle(fontSize: 16, color: Colors.grey[800]),
      ),
    );
  }
}
