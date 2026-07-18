import 'package:flutter/material.dart';

/// Botón personalizado con animación de escala al presionar y estado de carga.
class CustomButton extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;
  final bool loading;

  const CustomButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
  });

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> {
  double _scale = 1.0;

  void _setScale(double s) => setState(() => _scale = s);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _setScale(0.97),
      onTapUp: (_) => _setScale(1.0),
      onTapCancel: () => _setScale(1.0),
      onTap: widget.loading ? null : widget.onPressed,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 100),
        child: Container(
          height: 52,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(12),
          ),
          child: widget.loading
              ? const SizedBox(
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : Text(
                  widget.label,
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                ),
        ),
      ),
    );
  }
}