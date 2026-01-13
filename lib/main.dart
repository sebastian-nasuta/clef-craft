import 'dart:math';
import 'dart:ui'; // For ImageFilter
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ClefCraft Quiz',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.tealAccent, // Brighter seed
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        textTheme: TextTheme(
          displayLarge: GoogleFonts.montserrat(
            fontSize: 36,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: 1.2,
          ),
          bodyLarge: GoogleFonts.lato(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
          displaySmall: GoogleFonts.montserrat(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      home: const ClefCraftQuiz(),
    );
  }
}

class Note {
  final String name;
  final double offset;

  const Note(this.name, this.offset);
}

class ClefCraftQuiz extends StatefulWidget {
  const ClefCraftQuiz({super.key});

  @override
  State<ClefCraftQuiz> createState() => _ClefCraftQuizState();
}

class _ClefCraftQuizState extends State<ClefCraftQuiz> with TickerProviderStateMixin {
  final List<Note> allNotes = const [
    Note('C', 3.0),
    Note('D', 2.5),
    Note('E', 2.0),
    Note('F', 1.5),
    Note('G', 1.0),
    Note('A', 0.5),
    Note('H', 0.0),
    Note('C', -0.5),
  ];

  late Note currentNote;
  int score = 0;
  int attempts = 0;
  String feedbackMessage = 'Wybierz nutę!';
  Color feedbackColor = Colors.white;
  final AudioPlayer _audioPlayer = AudioPlayer();

  // Animation Controllers
  late AnimationController _burstController;
  late AnimationController _shakeController;
  
  // Map to track burning state of each button
  final Map<String, bool> _burningButtons = {};
  
  String _currentBurstText = "POW!";

  @override
  void initState() {
    super.initState();
    _burstController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _generateRandomNote();
  }

  @override
  void dispose() {
    _burstController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  void _generateRandomNote() {
    setState(() {
      currentNote = allNotes[Random().nextInt(allNotes.length)];
      _burningButtons.clear();
    });
  }

  String _getRandomComicWord() {
    const words = ["BAM!", "POW!", "EPIC!", "WOW!", "ZING!", "BOOM!"];
    return words[Random().nextInt(words.length)];
  }

  void _checkAnswer(String selectedName) {
    setState(() {
      attempts++;
      if (selectedName == currentNote.name) {
        score++;
        feedbackMessage = 'Super! To jest $selectedName.';
        feedbackColor = const Color(0xFF69F0AE); // Bright Green
        
        // Audio Feedback
        _audioPlayer.play(AssetSource('audio/success.wav'));

        // Trigger WIN Effects
        _currentBurstText = _getRandomComicWord();
        _burstController.forward(from: 0).then((_) {
          // Auto-reverse after short hold
           Future.delayed(const Duration(milliseconds: 500), () {
             if (mounted) _burstController.reverse();
           });
        });
        _shakeController.forward(from: 0); // Impact Shake!

        Future.delayed(const Duration(milliseconds: 1500), () {
          if (mounted) {
            _generateRandomNote();
            setState(() {
              feedbackMessage = 'Wybierz nutę!';
              feedbackColor = Colors.white;
            });
          }
        });
      } else {
        feedbackMessage = 'To nie $selectedName. Próbuj dalej!';
        feedbackColor = const Color(0xFFFF5252); // Bright Red
        
        // Play Fire Sound
        _audioPlayer.play(AssetSource('audio/fire.wav'));

        // Ignite the specific button (Comic Fire)
        _burningButtons[selectedName] = true;
        
        // Extinguish after a delay
         Future.delayed(const Duration(milliseconds: 1000), () {
          if (mounted) {
            setState(() {
               _burningButtons[selectedName] = false;
            });
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Shaker(
        controller: _shakeController,
        child: Stack(
          children: [
            // Background Image
            Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/background.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            // Gradient Overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.3),
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
            ),
            // Content
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Header Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('WYNIK', style: GoogleFonts.bangers(fontSize: 20, color: Colors.yellowAccent)),
                            Text('$score / $attempts', style: GoogleFonts.bangers(fontSize: 40, color: Colors.white)),
                          ],
                        ),
                        IconButton(
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.white.withOpacity(0.1),
                            hoverColor: Colors.white.withOpacity(0.2),
                          ),
                          icon: const Icon(Icons.refresh, color: Colors.white),
                          onPressed: () {
                            setState(() {
                              score = 0;
                              attempts = 0;
                              feedbackMessage = 'Start!';
                              _generateRandomNote();
                              _burstController.reset();
                            });
                          },
                        )
                      ],
                    ),
                    const SizedBox(height: 40),

                    // Glassmorphism Staff Container
                    ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          width: double.infinity,
                          height: 240,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: CustomPaint(
                            painter: StaffPainter(currentNote),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Feedback Message
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Text(
                        feedbackMessage,
                        key: ValueKey(feedbackMessage),
                        style: GoogleFonts.bangers(
                          fontSize: 32,
                          color: feedbackColor,
                          shadows: [
                            const Shadow(
                                blurRadius: 10.0,
                                color: Colors.black,
                                offset: Offset(2.0, 2.0),
                              ),
                          ]
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    const SizedBox(height: 50),

                    // Control Buttons Grid
                    Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      alignment: WrapAlignment.center,
                      children: ['C', 'D', 'E', 'F', 'G', 'A', 'H'].map((noteName) {
                        final bool isBurning = _burningButtons[noteName] ?? false;
                        
                        return RadialFireButton(
                          isBurning: isBurning,
                          child: SizedBox(
                            width: 70,
                            height: 70,
                            child: ElevatedButton(
                              onPressed: () => _checkAnswer(noteName),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isBurning ? Colors.red : Colors.white,
                                foregroundColor: Colors.black,
                                elevation: 10,
                                shadowColor: Colors.black,
                                padding: EdgeInsets.zero,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  side: const BorderSide(color: Colors.black, width: 3), // Comic Outline
                                ),
                              ),
                              child: Text(
                                noteName,
                                style: GoogleFonts.bangers(
                                  fontSize: 36,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            
            // Comic Burst Overlay
            IgnorePointer(
              child: ComicBurst(controller: _burstController, text: _currentBurstText),
            ),
          ],
        ),
      ),
    );
  }
}

class StaffPainter extends CustomPainter {
  final Note note;

  StaffPainter(this.note);

  @override
  void paint(Canvas canvas, Size size) {
    final Color inkColor = Colors.white;
    final Paint linePaint = Paint()
      ..color = inkColor.withOpacity(0.8)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final double lineSpacing = 24.0;
    final double midY = size.height / 2;
    final double startX = 0;
    final double endX = size.width;

    for (int i = -2; i <= 2; i++) {
      double y = midY + (i * lineSpacing);
      canvas.drawLine(Offset(startX, y), Offset(endX, y), linePaint);
    }

    const textStyle = TextStyle(
      color: Colors.white,
      fontSize: 110,
      fontFamily: 'Noto Music',
    );
    const textSpan = TextSpan(text: '𝄞', style: textStyle);
    final textPainter = TextPainter(text: textSpan, textDirection: TextDirection.ltr);
    textPainter.layout();
    textPainter.paint(canvas, Offset(20, midY - 120 + lineSpacing));

    final double noteX = size.width / 2 + 30; 
    final double noteY = midY + (note.offset * lineSpacing);

    if (note.offset == 3.0 || note.offset == -3.0) {
       canvas.drawLine(Offset(noteX - 24, noteY), Offset(noteX + 24, noteY), linePaint);
    }

    final notePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    
    canvas.save();
    canvas.translate(noteX, noteY);
    canvas.rotate(-0.1); 
    
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: 28, height: 18),
      notePaint,
    );
    canvas.drawOval(
       Rect.fromCenter(center: Offset.zero, width: 28, height: 18),
       Paint()
         ..color = Colors.white.withOpacity(0.3)
         ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8)
         ..style = PaintingStyle.stroke
         ..strokeWidth = 4
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant StaffPainter oldDelegate) {
    return oldDelegate.note != note;
  }
}

// ---------------------------------------------------------------------------
// VISUAL EFFECTS CLASSES
// ---------------------------------------------------------------------------

class MusicalFireworks extends StatefulWidget {
  final AnimationController controller;

  const MusicalFireworks({super.key, required this.controller});

  @override
  State<MusicalFireworks> createState() => _MusicalFireworksState();
}

class _MusicalFireworksState extends State<MusicalFireworks> {
  final List<FireworkParticle> particles = [];
  final Random random = Random();

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_updateParticles);
    widget.controller.addStatusListener((status) {
      if (status == AnimationStatus.forward) {
        _explode();
      }
    });
  }

  void _explode() {
    particles.clear();
    // Create multiple explosion centers
    for (int i = 0; i < 5; i++) { // 5 explosions
      double centerX = random.nextDouble() * 400; // approximate width range, centered later
      double centerY = random.nextDouble() * 600;
      
      for (int j = 0; j < 20; j++) { // 20 particles per explosion
        particles.add(FireworkParticle(
          x: centerX,
          y: centerY,
          vx: (random.nextDouble() - 0.5) * 10,
          vy: (random.nextDouble() - 0.5) * 10,
          color: HSLColor.fromAHSL(1, random.nextDouble() * 360, 1, 0.7).toColor(),
          symbol: _getRandomMusicalSymbol(),
        ));
      }
    }
  }

  String _getRandomMusicalSymbol() {
    const symbols = ['♩', '♪', '♫', '♬', '♭', '♯'];
    return symbols[random.nextInt(symbols.length)];
  }

  void _updateParticles() {
    for (var p in particles) {
      p.x += p.vx;
      p.y += p.vy;
      p.vy += 0.1; // Gravity
      p.opacity -= 0.01;
      if (p.opacity < 0) p.opacity = 0;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.infinite,
      painter: FireworkPainter(particles: particles),
    );
  }
}

class FireworkParticle {
  double x, y, vx, vy, opacity;
  Color color;
  String symbol;

  FireworkParticle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.color,
    required this.symbol,
    this.opacity = 1.0,
  });
}

class FireworkPainter extends CustomPainter {
  final List<FireworkParticle> particles;

  FireworkPainter({required this.particles});

  @override
  void paint(Canvas canvas, Size size) {
    for (var p in particles) {
      if (p.opacity <= 0) continue;
      
      final textSpan = TextSpan(
        text: p.symbol,
        style: TextStyle(
          color: p.color.withOpacity(p.opacity),
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      );
      final tp = TextPainter(text: textSpan, textDirection: TextDirection.ltr);
      tp.layout();
      
      // Center roughly on screen if needed, but random pos is absolute.
      // Let's assume passed coordinates are relative to widget size or absolute.
      // For simplicity, we mapped 0-400 above, let's scale to size.
      // But simpler: spawn relative to size center.
      
      // Quick fix for better positioning:
      // In _explode, use random numbers. Here, map them. 
      // Actually, let's just use raw coordinates and center the "explosion volume"
      
      double drawX = (size.width / 2 - 200) + p.x; 
      double drawY = (size.height / 2 - 300) + p.y;

      tp.paint(canvas, Offset(drawX, drawY));
    }
  }

  @override
  bool shouldRepaint(covariant FireworkPainter oldDelegate) => true;
}


// ---------------------------------------------------------------------------
// COMIC BOOK / SUPERHERO EFFECTS
// ---------------------------------------------------------------------------

class ComicBurst extends StatefulWidget {
  final AnimationController controller;
  final String text;

  const ComicBurst({super.key, required this.controller, required this.text});

  @override
  State<ComicBurst> createState() => _ComicBurstState();
}

class _ComicBurstState extends State<ComicBurst> {
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotateAnimation;
  
  final List<ComicNoteParticle> _particles = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.2).animate(
      CurvedAnimation(parent: widget.controller, curve: Curves.elasticOut),
    );
     _rotateAnimation = Tween<double>(begin: -0.1, end: 0.1).animate(
      CurvedAnimation(parent: widget.controller, curve: Curves.elasticOut),
    );

    widget.controller.addStatusListener((status) {
      if (status == AnimationStatus.forward) {
         _spawnParticles();
      }
    });
  }
  
  void _spawnParticles() {
    _particles.clear();
    for (int i = 0; i < 30; i++) {
        _particles.add(ComicNoteParticle(
          angle: _random.nextDouble() * 2 * pi,
          distance: 100 + _random.nextDouble() * 200, // Explode outwards
          rotation: (_random.nextDouble() - 0.5) * 1.0,
          color: [Colors.cyanAccent, Colors.yellowAccent, Colors.orangeAccent, Colors.greenAccent][_random.nextInt(4)],
          symbol: ['♩', '♪', '♫', '♬', '♭', '♯'][_random.nextInt(6)],
          size: 30 + _random.nextDouble() * 30, 
        ));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.controller.isDismissed) return const SizedBox.shrink();

    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Transform.rotate(
            angle: _rotateAnimation.value,
            child: CustomPaint(
              painter: ComicBurstPainter(
                particles: _particles,
                progress: widget.controller.value,
              ),
              child: Container(), // No Text, just particles
            ),
          ),
        );
      },
    );
  }
}

class ComicNoteParticle {
  final double angle;
  final double distance;
  final double rotation;
  final Color color;
  final String symbol;
  final double size;

  ComicNoteParticle({required this.angle, required this.distance, required this.rotation, required this.color, required this.symbol, required this.size});
}

// Removed ComicActionText widget

class ComicBurstPainter extends CustomPainter {
  final List<ComicNoteParticle> particles;
  final double progress;

  ComicBurstPainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    
    // NO Burst Background
    // NO Action Lines
    
    // Layer 4: Musical Note Particles ONLY
    for (var p in particles) {
      double r = p.distance * Curves.easeOutBack.transform(progress);
      double x = center.dx + cos(p.angle) * r;
      double y = center.dy + sin(p.angle) * r;
      
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(p.rotation + (progress * 2)); // Rotate as they fly
      
      // Draw Text
      final textSpan = TextSpan(
        text: p.symbol,
        style: GoogleFonts.bangers(
           fontSize: p.size,
           color: p.color,
        ),
      );
      final textPainter = TextPainter(text: textSpan, textDirection: TextDirection.ltr);
      textPainter.layout();
      
      // Paint Stroke first
       final strokePainter = TextPainter(
         text: TextSpan(
           text: p.symbol,
            style: GoogleFonts.bangers(
             fontSize: p.size,
             foreground: Paint()..style=PaintingStyle.stroke ..strokeWidth=4 ..color=Colors.black
          ),
         ), 
         textDirection: TextDirection.ltr
       );
       strokePainter.layout();
       strokePainter.paint(canvas, Offset(-strokePainter.width/2, -strokePainter.height/2));
       
       // Paint Fill
       textPainter.paint(canvas, Offset(-textPainter.width/2, -textPainter.height/2));

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant ComicBurstPainter oldDelegate) => true; 
}

class RadialFireButton extends StatefulWidget {
  final Widget child;
  final bool isBurning;

  const RadialFireButton({super.key, required this.child, required this.isBurning});

  @override
  State<RadialFireButton> createState() => _RadialFireButtonState();
}

class _RadialFireButtonState extends State<RadialFireButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<FireParticle> _particles = [];
  final Random _random = Random();
  Offset _lastTapPos = const Offset(50, 50); // Default to center

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this,
        duration: const Duration(seconds: 1),
    )..repeat();
    _controller.addListener(_updateFire);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  void _updateFire() {
    if (widget.isBurning) {
      // Spawn batch
      for(int i=0; i<12; i++) {
        if (_particles.length < 300) {
           double angle = _random.nextDouble() * 2 * pi;
           double speed = _random.nextDouble() * 4 + 1;
           
          _particles.add(FireParticle(
            x: _lastTapPos.dx, 
            y: _lastTapPos.dy, 
            vx: cos(angle) * speed * 0.5, // Less explosive radial
            vy: sin(angle) * speed - 2.0, // Initial upward burst
            size: _random.nextDouble() * 15 + 10,
            life: 1.0,
          ));
        }
      }
    }

    for (int i = _particles.length - 1; i >= 0; i--) {
      var p = _particles[i];
      p.x += p.vx;
      p.y += p.vy;
      p.vy -= 0.15; // Heat rising (gravity in reverse)
      p.vx += (sin(_controller.value * 10 + i) * 0.2); // Flickering wiggle
      p.size *= 0.94; // Shrink
      p.life -= 0.025; // Fade
      
      if (p.life <= 0 || p.size < 0.5) {
        _particles.removeAt(i);
      }
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (event) {
        setState(() {
          _lastTapPos = event.localPosition;
        });
      },
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          widget.child,
          if (_particles.isNotEmpty)
            Positioned.fill(
               child: IgnorePointer(
                 child: CustomPaint(
                   painter: RadialFirePainter(_particles),
                 ),
               ),
            ),
        ],
      ),
    );
  }
}

class FireParticle {
  double x, y, vx, vy, size, life;
  FireParticle({required this.x, required this.y, required this.vx, required this.vy, required this.size, required this.life});
}

class RadialFirePainter extends CustomPainter {
  final List<FireParticle> particles;
  RadialFirePainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    final strokePaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    for (var p in particles) {
      Color color;
      if (p.life > 0.6) {
        color = const Color(0xFFFFEB3B); // Yellow
      } else if (p.life > 0.3) {
        color = const Color(0xFFFF9800); // Orange
      } else {
        color = const Color(0xFFF44336); // Red
      }

      final fillPaint = Paint()
        ..color = color.withOpacity(p.life)
        ..style = PaintingStyle.fill;

      // Draw a "Flame" shape - teardrop-like flicker
      final path = Path();
      double w = p.size;
      double h = p.size * 1.8; // Tall flames

      // Bottom curves
      path.moveTo(p.x - w/2, p.y);
      path.quadraticBezierTo(p.x - w/2, p.y + w/2, p.x, p.y + w/2);
      path.quadraticBezierTo(p.x + w/2, p.y + w/2, p.x + w/2, p.y);
      
      // Top flickering tip
      path.quadraticBezierTo(p.x + w/4, p.y - h/2, p.x, p.y - h);
      path.quadraticBezierTo(p.x - w/4, p.y - h/2, p.x - w/2, p.y);
      
      path.close();

      canvas.drawPath(path, fillPaint);
      canvas.drawPath(path, strokePaint..color = Colors.black.withOpacity(p.life));
    }
  }

  @override
  bool shouldRepaint(covariant RadialFirePainter oldDelegate) => true;
}

class Shaker extends StatelessWidget {
  final Widget child;
  final AnimationController controller;

  const Shaker({super.key, required this.child, required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final double offset = 10 * sin(controller.value * pi * 10);
        return Transform.translate(
           offset: controller.isAnimating ? Offset(offset, 0) : Offset.zero,
           child: child!,
        );
      },
      child: child,
    );
  }
}
