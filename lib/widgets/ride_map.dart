import 'package:flutter/material.dart';
import 'package:remora/models/track_point.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'dart:math';

const num defaultCameraOffset = 50;

class RideMap extends StatefulWidget {
  final List<TrackPoint> points;
  final TrackPoint? currentPosition;
  final bool showFullRide;

  const RideMap({
    super.key,
    required this.points,
    this.currentPosition,
    this.showFullRide = false,
  });

  @override
  State<RideMap> createState() => _RideMapState();
}

class _RideMapState extends State<RideMap> {
  final _mapController = MapController();
  bool _mapReady = false;

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

  LatLngBounds _fullTrackBounds(List<TrackPoint> points) {
    final List<double> lats = points.map((p) => p.latitude).toList();
    final List<double> longs = points.map((p) => p.longitude).toList();

    if (points.isEmpty) {
      final Distance distance = const Distance();
      return LatLngBounds(
        distance.offset(LatLng(0.0, 0.0), defaultCameraOffset, 315),
        distance.offset(LatLng(0.0, 0.0), defaultCameraOffset, 135),
      );
    }

    if (points.length == 1) {
      final Distance distance = const Distance();
      return LatLngBounds(
        distance.offset(LatLng(lats[0], longs[0]), defaultCameraOffset, 315),
        distance.offset(LatLng(lats[0], longs[0]), defaultCameraOffset, 135),
      );
    }
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

    final LatLng initialMapCenter;

    if (widget.points.isEmpty) {
      initialMapCenter = LatLng(0.0, 0.0);
    } else if (widget.points.length == 1) {
      initialMapCenter = LatLng(
        widget.points[0].latitude,
        widget.points[0].longitude,
      );
    } else {
      initialMapCenter = _averageCenterPoint(widget.points);
    }

    if (widget.points.length > 1) {
      layers.add(
        PolylineLayer(
          polylines: [
            Polyline(
              points: widget.points
                  .map((p) => LatLng(p.latitude, p.longitude))
                  .toList(),
              strokeWidth: 4,
            ),
          ],
        ),
      );
    }

    final Distance distance = const Distance();
    final LatLngBounds cameraBounds = widget.points.length > 1
        ? _fullTrackBounds(widget.points)
        : LatLngBounds(
            distance.offset(initialMapCenter, defaultCameraOffset, 315),
            distance.offset(initialMapCenter, defaultCameraOffset, 135),
          );

    print('map center $initialMapCenter /\n bounds $cameraBounds');

    final TrackPoint? currentPosition = widget.currentPosition;

    if (_mapReady && currentPosition != null) {
      _mapController.move(
        LatLng(currentPosition.latitude, currentPosition.longitude),
        _mapController.camera.zoom,
      );
    }

    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: initialMapCenter,
        initialZoom: 13,
        initialCameraFit: CameraFit.bounds(
          bounds: cameraBounds,
          padding: EdgeInsets.all(40),
        ),
        onMapReady: () {
          _mapReady = true;
        },
      ),
      children: layers,
    );
  }
}
