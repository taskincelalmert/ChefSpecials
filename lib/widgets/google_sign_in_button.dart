import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// "Continue with Google" button following Google's branding guidelines:
/// a white (or dark-surface) button with a neutral border and the Google "G".
class GoogleSignInButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final double height;
  final double borderRadius;

  const GoogleSignInButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.height = 54,
    this.borderRadius = 14,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? const Color(0xFF1F2937) : Colors.white;
    final borderColor =
        isDark ? const Color(0xFF374151) : const Color(0xFFDADCE0);
    final textColor = isDark ? Colors.white : const Color(0xFF1F1F1F);
    final enabled = onPressed != null && !isLoading;

    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: borderColor),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled ? onPressed : null,
          borderRadius: BorderRadius.circular(borderRadius),
          child: Center(
            child: isLoading
                ? SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(textColor),
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        'assets/google_logo.png',
                        width: 22,
                        height: 22,
                        errorBuilder: (context, error, stackTrace) => SizedBox(
                          width: 22,
                          height: 22,
                          child: Icon(Icons.login, size: 22, color: textColor),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Flexible(
                        child: Text(
                          text,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: textColor,
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
