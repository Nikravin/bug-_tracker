import 'package:flutter/material.dart';

class ModernSnackbar {
  static void show({
    required BuildContext context,
    required String message,
    SnackbarType type = SnackbarType.info,
    Duration duration = const Duration(seconds: 4),
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    final snackBar = SnackBar(
      content: _ModernSnackbarContent(
        message: message,
        type: type,
        actionLabel: actionLabel,
        onAction: onAction,
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      duration: duration,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(16),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}

enum SnackbarType {
  success,
  error,
  warning,
  info,
}

class _ModernSnackbarContent extends StatefulWidget {
  final String message;
  final SnackbarType type;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _ModernSnackbarContent({
    required this.message,
    required this.type,
    this.actionLabel,
    this.onAction,
  });

  @override
  State<_ModernSnackbarContent> createState() => _ModernSnackbarContentState();
}

class _ModernSnackbarContentState extends State<_ModernSnackbarContent>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late AnimationController _progressController;
  
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _progressController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.elasticOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    _progressAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.linear,
    ));

    // Start animations
    _slideController.forward();
    _scaleController.forward();
    _progressController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _scaleController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  Color _getBackgroundColor() {
    switch (widget.type) {
      case SnackbarType.success:
        return const Color(0xFF10B981);
      case SnackbarType.error:
        return const Color(0xFFEF4444);
      case SnackbarType.warning:
        return const Color(0xFFF59E0B);
      case SnackbarType.info:
        return const Color(0xFF3B82F6);
    }
  }

  IconData _getIcon() {
    switch (widget.type) {
      case SnackbarType.success:
        return Icons.check_circle_outline;
      case SnackbarType.error:
        return Icons.error_outline;
      case SnackbarType.warning:
        return Icons.warning_amber_outlined;
      case SnackbarType.info:
        return Icons.info_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          decoration: BoxDecoration(
            color: _getBackgroundColor(),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: _getBackgroundColor().withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Progress indicator at the bottom (inside the container)
              Positioned(
                bottom: 8,
                left: 20,
                right: 20,
                child: AnimatedBuilder(
                  animation: _progressAnimation,
                  builder: (context, child) {
                    return Container(
                      height: 4,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2),
                        color: Colors.white.withOpacity(0.2),
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: FractionallySizedBox(
                          widthFactor: _progressAnimation.value,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(2),
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              
              // Main content
              Container(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                child: Row(
                  children: [
                    // Icon with pulse animation
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.8, end: 1.0),
                      duration: const Duration(milliseconds: 800),
                      builder: (context, scale, child) {
                        return Transform.scale(
                          scale: scale,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              _getIcon(),
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        );
                      },
                    ),
                    
                    const SizedBox(width: 16),
                    
                    // Message text
                    Expanded(
                      child: Text(
                        widget.message,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          height: 1.4,
                        ),
                      ),
                    ),
                    
                    // Action button if provided
                    if (widget.actionLabel != null && widget.onAction != null) ...[
                      const SizedBox(width: 16),
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: widget.onAction,
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              widget.actionLabel!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// // Example usage widget
// class SnackbarDemo extends StatelessWidget {
//   const SnackbarDemo({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Modern Snackbar Demo'),
//         backgroundColor: Colors.deepPurple,
//         foregroundColor: Colors.white,
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             _buildDemoButton(
//               context,
//               'Success Message',
//               SnackbarType.success,
//               'Task completed successfully!',
//             ),
//             const SizedBox(height: 16),
//             _buildDemoButton(
//               context,
//               'Error Message',
//               SnackbarType.error,
//               'Something went wrong. Please try again.',
//             ),
//             const SizedBox(height: 16),
//             _buildDemoButton(
//               context,
//               'Warning Message',
//               SnackbarType.warning,
//               'Please check your internet connection.',
//             ),
//             const SizedBox(height: 16),
//             _buildDemoButton(
//               context,
//               'Info Message',
//               SnackbarType.info,
//               'New update available for download.',
//             ),
//             const SizedBox(height: 32),
//             _buildActionButton(context),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildDemoButton(
//     BuildContext context,
//     String label,
//     SnackbarType type,
//     String message,
//   ) {
//     return ElevatedButton(
//       onPressed: () {
//         ModernSnackbar.show(
//           context: context,
//           message: message,
//           type: type,
//         );
//       },
//       style: ElevatedButton.styleFrom(
//         backgroundColor: Colors.deepPurple,
//         foregroundColor: Colors.white,
//         padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(12),
//         ),
//       ),
//       child: Text(label),
//     );
//   }

//   Widget _buildActionButton(BuildContext context) {
//     return ElevatedButton(
//       onPressed: () {
//         ModernSnackbar.show(
//           context: context,
//           message: 'File uploaded successfully!',
//           type: SnackbarType.success,
//           actionLabel: 'VIEW',
//           onAction: () {
//             // Handle action tap
//             ScaffoldMessenger.of(context).hideCurrentSnackBar();
//             // Add your action logic here
//           },
//         );
//       },
//       style: ElevatedButton.styleFrom(
//         backgroundColor: Colors.orange,
//         foregroundColor: Colors.white,
//         padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(12),
//         ),
//       ),
//       child: const Text('Snackbar with Action'),
//     );
//   }
// }