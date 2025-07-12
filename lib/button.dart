import 'package:flutter/material.dart';

class MyButton extends StatefulWidget {
  final String text;
  final VoidCallback function;
  final bool isEnabled;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final double? height;

  MyButton({
    required this.text,
    required this.function,
    this.isEnabled = true,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height,
  });

  @override
  _MyButtonState createState() => _MyButtonState();
}

class _MyButtonState extends State<MyButton> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.isEnabled) {
      setState(() {
        _isPressed = true;
      });
      _animationController.forward();
    }
  }

  void _onTapUp(TapUpDetails details) {
    if (widget.isEnabled) {
      setState(() {
        _isPressed = false;
      });
      _animationController.reverse();
      widget.function();
    }
  }

  void _onTapCancel() {
    if (widget.isEnabled) {
      setState(() {
        _isPressed = false;
      });
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    Color backgroundColor = widget.backgroundColor ?? Colors.brown[600]!;
    Color textColor = widget.textColor ?? Colors.white;

    if (!widget.isEnabled) {
      backgroundColor = Colors.grey[600]!;
      textColor = Colors.grey[400]!;
    }

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: widget.width,
              height: widget.height ?? 40,
              // Add minimum width constraint and padding
              constraints: BoxConstraints(
                minWidth: widget.width ?? 80, // Increased default from 60 to 80
                minHeight: widget.height ?? 40,
              ),
              margin: EdgeInsets.symmetric(horizontal: 5),
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4), // Add padding
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _isPressed ? Colors.white : Colors.brown[800]!,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    offset: Offset(2, 2),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  widget.text,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis, // Prevent text overflow
                  maxLines: 1, // Keep text on single line
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// Specialized button for special actions
class SpecialButton extends StatelessWidget {
  final String text;
  final VoidCallback function;
  final IconData? icon;
  final bool isEnabled;
  final Color? glowColor;

  SpecialButton({
    required this.text,
    required this.function,
    this.icon,
    this.isEnabled = true,
    this.glowColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: glowColor != null ? [
          BoxShadow(
            color: glowColor!.withOpacity(0.5),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ] : null,
      ),
      child: MyButton(
        text: text,
        function: function,
        isEnabled: isEnabled,
        backgroundColor: glowColor ?? Colors.purple[600],
        width: 100, // Increased width for special buttons
        height: 45,
      ),
    );
  }
}

// Skill button with cooldown
class SkillButton extends StatefulWidget {
  final String text;
  final VoidCallback function;
  final int cooldownSeconds;
  final IconData? icon;

  SkillButton({
    required this.text,
    required this.function,
    this.cooldownSeconds = 5,
    this.icon,
  });

  @override
  _SkillButtonState createState() => _SkillButtonState();
}

class _SkillButtonState extends State<SkillButton> {
  bool _isOnCooldown = false;
  int _remainingCooldown = 0;

  void _useSkill() {
    if (_isOnCooldown) return;

    widget.function();
    setState(() {
      _isOnCooldown = true;
      _remainingCooldown = widget.cooldownSeconds;
    });

    // Start cooldown timer
    Stream.periodic(Duration(seconds: 1), (i) => i).take(widget.cooldownSeconds).listen(
          (timer) {
        setState(() {
          _remainingCooldown--;
        });
      },
      onDone: () {
        setState(() {
          _isOnCooldown = false;
          _remainingCooldown = 0;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MyButton(
      text: _isOnCooldown ? _remainingCooldown.toString() : widget.text,
      function: _useSkill,
      isEnabled: !_isOnCooldown,
      backgroundColor: _isOnCooldown ? Colors.grey[600] : Colors.orange[600],
      width: 90, // Increased width for skill buttons
    );
  }
}