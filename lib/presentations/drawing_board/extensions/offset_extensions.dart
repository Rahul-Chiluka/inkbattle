import 'package:flutter/material.dart';

/// Extension on [Offset] to provide scaling functionalities.
///
/// Changed from fixed 800x600 standard to normalized coordinates (0.0-1.0)
/// This prevents aspect ratio distortion when drawings are rendered on devices with different screen ratios.
///
/// Normalized coordinates store positions as percentages (0.0 to 1.0) of the canvas size,
/// ensuring drawings appear correctly regardless of device aspect ratio.
extension OffsetExtensions on Offset {
  /// Scales the current [Offset] to normalized coordinates (0.0 to 1.0).
  ///
  /// This method converts device-specific pixel coordinates to normalized coordinates
  /// that represent the position as a percentage of the canvas size.
  /// 
  /// Example: On a 1920x1080 canvas, point (960, 540) becomes (0.5, 0.5)
  ///
  /// [deviceCanvasSize] is the size of the canvas on the current device.
  ///
  /// Returns a new [Offset] with normalized coordinates (dx: 0.0-1.0, dy: 0.0-1.0).
  Offset scaleToStandard(Size deviceCanvasSize) {
    // Prevent division by zero
    if (deviceCanvasSize.width <= 0 || deviceCanvasSize.height <= 0) {
      return Offset(0, 0);
    }
    
    // Normalize to 0.0-1.0 range
    return Offset(
      dx / deviceCanvasSize.width,   // 0.0 to 1.0
      dy / deviceCanvasSize.height,  // 0.0 to 1.0
    );
  }

  /// Scales the current [Offset] from normalized coordinates (0.0-1.0) to device canvas size.
  ///
  /// This method is the inverse of [scaleToStandard]. It converts normalized coordinates
  /// back to device-specific pixel coordinates.
  ///
  /// Example: Normalized (0.5, 0.5) on a 400x300 canvas becomes (200, 150)
  ///
  /// [deviceCanvasSize] is the size of the canvas on the current device.
  ///
  /// Returns a new [Offset] with device-specific pixel coordinates.
  Offset scaleFromStandard(Size deviceCanvasSize) {
    // Clamp normalized values to valid range (0.0-1.0)
    final clampedDx = dx.clamp(0.0, 1.0);
    final clampedDy = dy.clamp(0.0, 1.0);
    
    // Convert from normalized (0.0-1.0) to device pixels
    return Offset(
      clampedDx * deviceCanvasSize.width,
      clampedDy * deviceCanvasSize.height,
    );
  }
}
