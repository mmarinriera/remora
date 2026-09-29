import 'package:flutter/material.dart';
import 'package:remora/models/track_point.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'dart:math';

class RideMap extends StatelessWidget {
  final List<TrackPoint> _points;
  final TrackPoint? _centerPoint;

  const RideMap({super.key, required this._points, this._centerPoint});

  LatLng _averageCenterPoint(List<TrackPoint> points) {
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

    if (_points.length > 1) {
      layers.add(
        PolylineLayer(
          polylines: [
            Polyline(
              points: _points
                  .map((p) => LatLng(p.latitude, p.longitude))
                  .toList(),
              strokeWidth: 4,
            ),
          ],
        ),
      );
    }

    final LatLng mapCenter = _centerPoint == null
        ? _averageCenterPoint(_points)
        : LatLng(_centerPoint.latitude, _centerPoint.longitude);

    return FlutterMap(
      options: MapOptions(
        initialCenter: mapCenter,
        initialZoom: 13,
        initialCameraFit: _points.length > 1
            ? CameraFit.bounds(
                bounds: _trackBounds(_points),
                padding: EdgeInsets.all(40),
              )
            : null,
      ),
      children: layers,
    );
  }
}
