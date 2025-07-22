import 'package:flutter/material.dart';
import '../utils/theme.dart';

class TutorialOverlay extends StatefulWidget {
  final Widget child;
  final List<TutorialStep> steps;
  final VoidCallback? onComplete;
  final bool showTutorial;

  const TutorialOverlay({
    super.key,
    required this.child,
    required this.steps,
    this.onComplete,
    this.showTutorial = false,
  });

  @override
  State<TutorialOverlay> createState() => _TutorialOverlayState();
}

class _TutorialOverlayState extends State<TutorialOverlay>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  
  int _currentStep = 0;
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    if (widget.showTutorial) {
      _startTutorial();
    }
  }

  @override
  void didUpdateWidget(TutorialOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.showTutorial && !oldWidget.showTutorial) {
      _startTutorial();
    } else if (!widget.showTutorial && oldWidget.showTutorial) {
      _hideTutorial();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _startTutorial() {
    setState(() {
      _isVisible = true;
      _currentStep = 0;
    });
    _animationController.forward();
  }

  void _hideTutorial() {
    _animationController.reverse().then((_) {
      if (mounted) {
        setState(() {
          _isVisible = false;
        });
      }
    });
  }

  void _nextStep() {
    if (_currentStep < widget.steps.length - 1) {
      setState(() {
        _currentStep++;
      });
      _animationController.reset();
      _animationController.forward();
    } else {
      _completeTutorial();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _animationController.reset();
      _animationController.forward();
    }
  }

  void _completeTutorial() {
    _hideTutorial();
    widget.onComplete?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_isVisible && widget.steps.isNotEmpty)
          _buildTutorialOverlay(),
      ],
    );
  }

  Widget _buildTutorialOverlay() {
    final step = widget.steps[_currentStep];
    
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        color: Colors.black.withOpacity(0.7),
        child: Stack(
          children: [
            // Highlight area
            if (step.targetKey != null)
              _buildHighlight(step),
            
            // Tutorial content
            Positioned(
              left: 20,
              right: 20,
              bottom: 100,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: _buildTutorialCard(step),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHighlight(TutorialStep step) {
    return CustomPaint(
      painter: HighlightPainter(
        targetKey: step.targetKey!,
        highlightRadius: step.highlightRadius,
      ),
      size: Size.infinite,
    );
  }

  Widget _buildTutorialCard(TutorialStep step) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  step.icon,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      step.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      'Step ${_currentStep + 1} of ${widget.steps.length}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            step.description,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
              height: 1.5,
            ),
          ),
          if (step.tips.isNotEmpty) ...[
            const SizedBox(height: 16),
            ...step.tips.map((tip) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    margin: const EdgeInsets.only(top: 6, right: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryGreen,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      tip,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ],
              ),
            )),
          ],
          const SizedBox(height: 24),
          Row(
            children: [
              if (_currentStep > 0)
                Expanded(
                  child: OutlinedButton(
                    onPressed: _previousStep,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      side: BorderSide(color: AppTheme.primaryGreen),
                    ),
                    child: Text(
                      'Previous',
                      style: TextStyle(
                        color: AppTheme.primaryGreen,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              if (_currentStep > 0) const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _nextStep,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    _currentStep == widget.steps.length - 1 ? 'Got it!' : 'Next',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              TextButton(
                onPressed: _completeTutorial,
                child: Text(
                  'Skip',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class TutorialStep {
  final String title;
  final String description;
  final IconData icon;
  final GlobalKey? targetKey;
  final double highlightRadius;
  final List<String> tips;

  const TutorialStep({
    required this.title,
    required this.description,
    required this.icon,
    this.targetKey,
    this.highlightRadius = 60.0,
    this.tips = const [],
  });
}

class HighlightPainter extends CustomPainter {
  final GlobalKey targetKey;
  final double highlightRadius;

  HighlightPainter({
    required this.targetKey,
    this.highlightRadius = 60.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final RenderBox? renderBox = targetKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final position = renderBox.localToGlobal(Offset.zero);
    final targetSize = renderBox.size;
    final center = Offset(
      position.dx + targetSize.width / 2,
      position.dy + targetSize.height / 2,
    );

    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // Draw highlight circle
    canvas.drawCircle(center, highlightRadius, paint);
    canvas.drawCircle(center, highlightRadius, borderPaint);

    // Draw pulsing effect
    final pulsePaint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    canvas.drawCircle(center, highlightRadius + 10, pulsePaint);
    canvas.drawCircle(center, highlightRadius + 20, pulsePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}