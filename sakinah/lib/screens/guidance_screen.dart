import 'package:flutter/material.dart';
// import 'home_main.dart'; // To navigate back home

class GuidanceScreen extends StatelessWidget {
  final String mood;

  const GuidanceScreen({super.key, required this.mood});

  // Mock Database of Guidance
  static const Map<String, Map<String, String>> _guidanceData = {
    'Anxious': {
      'title': 'The Cave of Thawr',
      'story': 'When the Prophet (PBUH) and Abu Bakr (RA) were hiding in the cave, surrounded by enemies, Abu Bakr was terrified. The Prophet simply said: "Do not grieve; indeed Allah is with us."',
      'lesson': 'Anxiety is natural, but trust (Tawakkul) acts as the anchor. You are never truly alone.',
      'action': 'Recite "Hasbunallahu wa ni\'mal wakil" 33 times.',
    },
    'Sad': {
      'title': 'The Year of Sorrow',
      'story': 'After losing his beloved wife Khadija and uncle Abu Talib, the Prophet (PBUH) faced immense grief. He poured his heart out to Allah in Ta\'if, complaining only of his weakness.',
      'lesson': 'It is okay to grieve. Even the best of creation felt deep sorrow. Turn that pain into a conversation with your Creator.',
      'action': 'Make a sincere Dua in Sujood (prostration) about your pain.',
    },
    'Angry': {
      'title': 'The Bedouin in the Masjid',
      'story': 'A man urinated in the Masjid. The companions were furious, but the Prophet (PBUH) calmed them down and gently educated the man instead of reacting with rage.',
      'lesson': 'Anger shuts down wisdom. Patience opens the door to teaching and understanding.',
      'action': 'Perform Wudu (ablution) to cool the fire of anger.',
    },
    // Default fallback
    'Neutral': {
      'title': 'The Smile of the Prophet',
      'story': 'The Prophet (PBUH) was known to be the one who smiled the most, even amidst great responsibilities.',
      'lesson': 'A smile is charity. It lightens your heart and the hearts of others.',
      'action': 'Smile at the next person you see.',
    }
  };

  @override
  Widget build(BuildContext context) {
    // Fetch data based on mood or fallback
    final data = _guidanceData[mood] ?? _guidanceData['Neutral']!;

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // Header with Title
          SliverAppBar(
            expandedHeight: 200.0,
            floating: false,
            pinned: true,
            backgroundColor: const Color(0xFF15803D),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(data['title']!, style: const TextStyle(fontSize: 16)),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF15803D), Color(0xFF14532D)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Center(
                  child: Icon(Icons.mosque_rounded, size: 80, color: Colors.white.withOpacity(0.2)),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Mood Tag
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDCFCE7),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          "For when you feel $mood",
                          style: const TextStyle(
                            color: Color(0xFF15803D),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Story Section
                  const Text(
                    "The Seerah Connection",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    data['story']!,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF4B5563),
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Lesson Box
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.lightbulb_outline, color: Color(0xFF15803D), size: 20),
                            SizedBox(width: 8),
                            Text("Wisdom", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF15803D))),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          data['lesson']!,
                          style: const TextStyle(color: Color(0xFF374151), fontStyle: FontStyle.italic),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Action Habit Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFF15803D).withOpacity(0.3)),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF15803D).withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Text(
                          "Recommended Habit",
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF6B7280),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          data['action']!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              // Save to habits (Logic for later)
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Habit saved to your tracker!")),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF15803D),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text("Add to My Habits"),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),
                  Center(
                    child: TextButton(
                      onPressed: () {
                        // Pop until we hit the first route (Home)
                        Navigator.of(context).popUntil((route) => route.isFirst);
                      },
                      child: const Text("Return Home", style: TextStyle(color: Colors.grey)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}