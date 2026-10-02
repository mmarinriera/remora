import 'package:flutter/material.dart';
import 'package:remora/models/track_point.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'dart:math';

const num defaultCameraOffset = 50;
const double defaultCameraZoom = 17;

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
  bool _activeTracking = true;

  void _disableActiveTracking() {
    _activeTracking = false;
  }

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

  LatLng _getMapCenter(List<TrackPoint> points) {
    if (points.isEmpty) return LatLng(0.0, 0.0);

    if (widget.showFullRide) return _averageCenterPoint(widget.points);

    return LatLng(points.last.latitude, points.last.longitude);
  }

  CameraFit _getCameraFit(List<TrackPoint> points) {
    final List<LatLng> pointsLatLng = points
        .map((p) => LatLng(p.latitude, p.longitude))
        .toList();

    if (pointsLatLng.length > 1) {
      return CameraFit.coordinates(
        coordinates: pointsLatLng,
        padding: EdgeInsets.all(40),
      );
    }

    final LatLng centerPoint = pointsLatLng.isEmpty
        ? LatLng(0.0, 0.0)
        : pointsLatLng.last;

    final Distance distance = const Distance();

    return CameraFit.bounds(
      bounds: LatLngBounds(
        distance.offset(centerPoint, defaultCameraOffset, 315),
        distance.offset(centerPoint, defaultCameraOffset, 135),
      ),
      padding: EdgeInsets.all(40),
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

    final TrackPoint? currentPosition = widget.currentPosition;

    if (_mapReady && currentPosition != null && _activeTracking) {
      _mapController.move(
        LatLng(currentPosition.latitude, currentPosition.longitude),
        defaultCameraZoom,
      );
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

    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: _getMapCenter(widget.points),
            initialZoom: defaultCameraZoom,
            initialCameraFit: widget.showFullRide
                ? _getCameraFit(widget.points)
                : null,
            onMapReady: () {
              _mapReady = true;
            },
            onPositionChanged: (camera, hasGesture) {
              if (hasGesture) {
                _disableActiveTracking();
              }
            },
          ),
          children: layers,
        ),
        Positioned(
          right: 16,
          bottom: 16,
          child: FloatingActionButton(
            child: Icon(Icons.add),
            onPressed: () {
              if (!_mapReady) return;

              final LatLng mapCenter = _getMapCenter(widget.points);

              if (currentPosition != null) {
                _mapController.move(mapCenter, defaultCameraZoom);
                _activeTracking = true;
              }
              if (widget.showFullRide) {
                _mapController.fitCamera(_getCameraFit(widget.points));
              }
            },
          ),
        ),
      ],
    );
  }
}
