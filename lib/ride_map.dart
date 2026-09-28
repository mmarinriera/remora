import 'package:flutter/material.dart';
import 'package:remora/models/track_point.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'dart:math';

class RideMap extends StatelessWidget {
  final List<TrackPoint> points;

  const RideMap({super.key, required this.points});

  LatLng _centerPoint(List<TrackPoint> points) {
    if (points.isEmpty) {
      return LatLng(0.0, 0.0);
    }
    double sumLat = 0.0;
    double sumLong = 0.0;
    for (TrackPoint point in points) {
      sumLat += point.latitude;
      sumLong += point.longitude;
    }
    return LatLng(sumLat / points.length, sumLong / points.length);
  }

  LatLngBounds _trackBounds(List<TrackPoint> points) {
    final List<double> lats = points.map((p) => p.latitude).toList();
    final List<double> longs = points.map((p) => p.longitude).toList();
    return LatLngBounds(
      LatLng(lats.reduce(min), longs.reduce(min)),
      LatLng(lats.reduce(max), longs.reduce(max)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> layers = [
      TileLayer(
        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
        userAgentPackageName: 'com.example.remora',
      ),
    ];

    if (points.length > 1) {
      layers.add(
        PolylineLayer(
          polylines: [
            Polyline(
              points: points
                  .map((p) => LatLng(p.latitude, p.longitude))
                  .toList(),
              strokeWidth: 4,
            ),
          ],
        ),
      );
    }

    return FlutterMap(
      options: MapOptions(
        initialCenter: points.length > 1
            ? _centerPoint(points)
            : LatLng(48.137, 11.575),
        initialZoom: 13,
        initialCameraFit: points.length > 1
            ? CameraFit.bounds(
                bounds: _trackBounds(points),
                padding: EdgeInsets.all(40),
              )
            : null,
      ),
      children: layers,
    );
  }
}
