import 'dart:async';
import 'dart:math' as math;
import 'package:sensors_plus/sensors_plus.dart';

class CompassService {
  static StreamController<double>? _compassController;
  static StreamSubscription<MagnetometerEvent>? _magnetometerSubscription;

  // Get compass heading stream
  static Stream<double> get compassStream {
    _compassController ??= StreamController<double>.broadcast();
    return _compassController!.stream;
  }

  // Start listening to magnetometer
  static void startCompass() {
    _magnetometerSubscription?.cancel();

    _magnetometerSubscription = magnetometerEventStream().listen(
      (MagnetometerEvent event) {
        // Calculate heading from magnetometer data
        double heading = _calculateHeading(event.x, event.y);
        _compassController?.add(heading);
      },
      onError: (error) {
        print('Magnetometer error: $error');
      },
    );
  }

  // Stop listening to magnetometer
  static void stopCompass() {
    _magnetometerSubscription?.cancel();
    _magnetometerSubscription = null;
  }

  // Dispose resources
  static void dispose() {
    stopCompass();
    _compassController?.close();
    _compassController = null;
  }

  // Calculate heading from magnetometer X and Y values
  static double _calculateHeading(double x, double y) {
    // Calculate angle in radians
    double heading = math.atan2(y, x);

    // Convert to degrees
    heading = heading * (180 / math.pi);

    // Normalize to 0-360 degrees
    if (heading < 0) {
      heading += 360;
    }

    // Adjust for device orientation (0 degrees should be North)
    heading = (heading + 90) % 360;

    return heading;
  }

  // Get direction name from heading
  static String getDirectionName(double heading) {
    if (heading >= 337.5 || heading < 22.5) {
      return 'N';
    } else if (heading >= 22.5 && heading < 67.5) {
      return 'NE';
    } else if (heading >= 67.5 && heading < 112.5) {
      return 'E';
    } else if (heading >= 112.5 && heading < 157.5) {
      return 'SE';
    } else if (heading >= 157.5 && heading < 202.5) {
      return 'S';
    } else if (heading >= 202.5 && heading < 247.5) {
      return 'SW';
    } else if (heading >= 247.5 && heading < 292.5) {
      return 'W';
    } else if (heading >= 292.5 && heading < 337.5) {
      return 'NW';
    }
    return 'N';
  }

  // Get full direction name
  static String getFullDirectionName(double heading) {
    if (heading >= 337.5 || heading < 22.5) {
      return 'North';
    } else if (heading >= 22.5 && heading < 67.5) {
      return 'Northeast';
    } else if (heading >= 67.5 && heading < 112.5) {
      return 'East';
    } else if (heading >= 112.5 && heading < 157.5) {
      return 'Southeast';
    } else if (heading >= 157.5 && heading < 202.5) {
      return 'South';
    } else if (heading >= 202.5 && heading < 247.5) {
      return 'Southwest';
    } else if (heading >= 247.5 && heading < 292.5) {
      return 'West';
    } else if (heading >= 292.5 && heading < 337.5) {
      return 'Northwest';
    }
    return 'North';
  }
}
