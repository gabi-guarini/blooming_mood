import 'package:blooming_mood/models/plant_state.dart';
import 'package:blooming_mood/services/mood_tracker_service.dart';
import 'package:flutter/material.dart';

class MoodInputScreen extends StatefulWidget {
  @override
  _MoodInputScreenState createState() => _MoodInputScreenState();
}

class _MoodInputScreenState extends State<MoodInputScreen> {
  final MoodTrackerService _moodService = MoodTrackerService();
  String? _selectedMood;
  final TextEditingController _noteController = TextEditingController();
  bool _isLoading = false;
  PlantState? _currentPlantState;

  // Mood options with emojis and colors
  final List<MoodOption> _moodOptions = [
    MoodOption('happy', '😊', 'Happy', Color(0xFF4CAF50)),
    MoodOption('excited', '🤗', 'Excited', Color(0xFFFFC107)),
    MoodOption('neutral', '😐', 'Neutral', Color(0xFF9E9E9E)),
    MoodOption('anxious', '😰', 'Anxious', Color(0xFFFF9800)),
    MoodOption('sad', '😢', 'Sad', Color(0xFF2196F3)),
  ];

  @override
  void initState() {
    super.initState();
    _loadCurrentPlantState();
  }

  Future<void> _loadCurrentPlantState() async {
    final state = await _moodService.getCurrentPlantState();
    setState(() {
      _currentPlantState = state;
    });
  }

  Future<void> _submitMood() async {
    if (_selectedMood == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select how you\'re feeling')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Track the mood and get updated plant state
      final newPlantState = await _moodService.trackMood(
        mood: _selectedMood!,
        note: _noteController.text.isNotEmpty ? _noteController.text : null,
      );

      // Navigate to plant response screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PlantResponseScreen(
            plantState: newPlantState,
            selectedMood: _selectedMood!,
          ),
        ),
      );

      // Reset for next entry
      setState(() {
        _selectedMood = null;
        _noteController.clear();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving mood: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text('How are you feeling?'),
        backgroundColor: Color(0xFF4CAF50),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Current streak indicator
            if (_currentPlantState != null)
              Container(
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 5,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(Icons.local_fire_department,
                        color: Colors.orange, size: 30),
                    SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${_currentPlantState!.currentStreak} Day Streak!',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Keep it going! Your plant is counting on you',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

            SizedBox(height: 30),

            // Mood selection
            Text(
              'Select your mood:',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 20),

            // Mood buttons grid
            GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                childAspectRatio: 1,
              ),
              itemCount: _moodOptions.length,
              itemBuilder: (context, index) {
                final mood = _moodOptions[index];
                final isSelected = _selectedMood == mood.value;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedMood = mood.value;
                    });
                  },
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? mood.color.withOpacity(0.2)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? mood.color : Colors.grey[300]!,
                        width: isSelected ? 3 : 1,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: mood.color.withOpacity(0.3),
                                blurRadius: 10,
                                offset: Offset(0, 5),
                              ),
                            ]
                          : [],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          mood.emoji,
                          style: TextStyle(fontSize: 40),
                        ),
                        SizedBox(height: 5),
                        Text(
                          mood.label,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: isSelected ? mood.color : Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            SizedBox(height: 30),

            // Note input
            Text(
              'Add a note (optional):',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 10),

            TextField(
              controller: _noteController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'What\'s on your mind?',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(color: Color(0xFF4CAF50), width: 2),
                ),
              ),
            ),

            SizedBox(height: 30),

            // Submit button
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitMood,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF4CAF50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 5,
                ),
                child: _isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text(
                        'Water My Plant 🌱',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Plant Response Screen
class PlantResponseScreen extends StatefulWidget {
  final PlantState plantState;
  final String selectedMood;

  PlantResponseScreen({
    required this.plantState,
    required this.selectedMood,
  });

  @override
  _PlantResponseScreenState createState() => _PlantResponseScreenState();
}

class _PlantResponseScreenState extends State<PlantResponseScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(0.3, 1.0, curve: Curves.easeIn),
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text('Your Plant Response'),
        backgroundColor: Color(0xFF4CAF50),
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated plant image
              AnimatedBuilder(
                animation: _scaleAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Container(
                      width: 250,
                      height: 250,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green.withOpacity(0.3),
                            blurRadius: 20,
                            offset: Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Image.asset(
                          widget.plantState.plantImage,
                          width: 200,
                          height: 200,
                          errorBuilder: (context, error, stackTrace) {
                            // Fallback if image not found
                            return Icon(
                              Icons.local_florist,
                              size: 100,
                              color: Colors.green,
                            );
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),

              SizedBox(height: 40),

              // Encouragement phrase
              FadeTransition(
                opacity: _fadeAnimation,
                child: Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        widget.plantState.encouragementPhrase,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 20),

                      // Stats row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildStatItem(
                            Icons.trending_up,
                            'Level ${widget.plantState.growthLevel}',
                            Colors.green,
                          ),
                          _buildStatItem(
                            Icons.calendar_today,
                            '${widget.plantState.daysTracked} Days',
                            Colors.blue,
                          ),
                          _buildStatItem(
                            Icons.star,
                            '${widget.plantState.totalMoodPoints} Points',
                            Colors.orange,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 40),

              // Continue button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF4CAF50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: Text(
                    'Continue',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String label, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 30),
        SizedBox(height: 5),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }
}

// Mood option model
class MoodOption {
  final String value;
  final String emoji;
  final String label;
  final Color color;

  MoodOption(this.value, this.emoji, this.label, this.color);
}
