import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:sfa/core/localization/app_localizations.dart';
import 'package:sfa/core/network/realtime_events.dart';
import 'package:sfa/core/providers/realtime_providers.dart';
import 'package:sfa/core/theme/app_palette.dart';
import 'package:sfa/utils/app_style.dart';
import 'package:sfa/utils/color_constants.dart';

/// Live courier position for one delivery, fed by the socket gateway's
/// `delivery:location` pings.
///
/// Mounting the widget joins the delivery's tracking room and leaving the
/// screen leaves it — see [driverLocationProvider]. Until the first ping
/// lands there is nothing to draw, so the card shows a waiting line rather
/// than an empty map centred on nowhere.
class DriverLiveMap extends ConsumerStatefulWidget {
  final String deliveryId;

  const DriverLiveMap({super.key, required this.deliveryId});

  @override
  ConsumerState<DriverLiveMap> createState() => _DriverLiveMapState();
}

class _DriverLiveMapState extends ConsumerState<DriverLiveMap>
    with SingleTickerProviderStateMixin {
  final _mapController = MapController();

  /// Pings arrive every few seconds and metres apart, so the marker is
  /// interpolated between the last two rather than teleported.
  late final AnimationController _animation = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..addListener(_onAnimationTick);

  LatLng? _from;
  LatLng? _to;

  /// The camera can only be driven once [FlutterMap] has attached the
  /// controller; the first fix is placed with `initialCenter` instead.
  bool _mapReady = false;

  @override
  void dispose() {
    _animation.dispose();
    _mapController.dispose();
    super.dispose();
  }

  void _onAnimationTick() {
    setState(() {});
    final position = _position;
    if (_mapReady && position != null) {
      _mapController.move(position, _mapController.camera.zoom);
    }
  }

  /// Where the marker is right now: the eased point between the previous
  /// fix and the newest one.
  LatLng? get _position {
    final to = _to;
    if (to == null) return null;
    final from = _from;
    if (from == null) return to;
    final t = Curves.easeOut.transform(_animation.value);
    return LatLng(
      from.latitude + (to.latitude - from.latitude) * t,
      from.longitude + (to.longitude - from.longitude) * t,
    );
  }

  void _onLocation(DriverLocation location) {
    final next = LatLng(location.lat, location.lng);
    // Start the next leg from wherever the marker currently sits, so a ping
    // arriving mid-animation doesn't make it jump back.
    _from = _position;
    _to = next;
    _animation.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    ref.listen(driverLocationProvider(widget.deliveryId), (_, next) {
      final location = next.valueOrNull;
      if (location != null) _onLocation(location);
    });

    final position = _position;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: loc.isArabic ? Alignment.centerRight : Alignment.centerLeft,
          child: Text(
            loc.translate('driverLiveLocation'),
            style: AppStyle.sectionHeader,
          ),
        ),
        const SizedBox(height: 6),
        Divider(color: context.palette.divider, thickness: 0.8),
        const SizedBox(height: 16),
        if (position == null)
          Text(
            loc.translate('driverLocationWaiting'),
            style: AppStyle.bodyText.copyWith(color: context.palette.textMuted),
          )
        else
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              height: 180,
              child: FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: position,
                  initialZoom: 15,
                  onMapReady: () => _mapReady = true,
                  interactionOptions: const InteractionOptions(
                    flags: InteractiveFlag.pinchZoom | InteractiveFlag.drag,
                  ),
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.sfa.app',
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: position,
                        width: 40,
                        height: 40,
                        child: Icon(
                          Icons.local_shipping,
                          color: AppColors.primary,
                          size: 32,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
