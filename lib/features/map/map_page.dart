import 'dart:math';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../models/app/app_page.dart';
import '../../router/app_router.gr.dart';
import '../../config/google_maps_api_key.dart';
import '../../widgets/heart_divider.dart';
import '../../widgets/page_availability_gate.dart';
import '../../widgets/wedding_action_button.dart';
import '../../models/map/map_poi.dart';
import '../../models/map/map_poi_data.dart';
import '../../utils/extension/context_extension.dart';

const _maxPageWidth = 920.0;

@RoutePage()
class MapPage extends StatelessWidget {
  const MapPage({super.key});

  static void push(BuildContext context) {
    context.router.navigate(const MapRoute());
  }

  @override
  Widget build(BuildContext context) {
    return PageAvailabilityGate(
      page: AppPage.map,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: _maxPageWidth),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _MapHeader(),
                const SizedBox(height: 22),
                const HeartDivider(),
                const SizedBox(height: 22),
                const _InteractiveMapSection(),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MapHeader extends StatelessWidget {
  const _MapHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'If you want to rest your head...',
          textAlign: TextAlign.center,
          style: context.scriptHero(fontSize: 48, height: 1.08),
        ),
        const SizedBox(height: 10),
        Text(
          'CLICK THE RED DOTS ON THE MAP TO VIEW AND BOOK NEARBY ACCOMMODATION',
          textAlign: TextAlign.center,
          style: context.capsLabel(
            color: context.sageGreen,
          ),
        ),
      ],
    );
  }
}

class _InteractiveMapSection extends HookWidget {
  const _InteractiveMapSection();

  @override
  Widget build(BuildContext context) {
    final selectedPoiId = useState<String?>(null);
    final mapController = useState<GoogleMapController?>(null);
    final boundsFitted = useRef(false);

    final selectedPoi = useMemoized(
      () {
        final id = selectedPoiId.value;
        if (id == null) {
          return null;
        }
        for (final poi in mapPois) {
          if (poi.id == id) {
            return poi;
          }
        }
        return null;
      },
      [selectedPoiId.value],
    );

    final markers = useMemoized(
      () {
        return {
          for (final poi in mapPois)
            Marker(
              markerId: MarkerId(poi.id),
              position: poi.latLng,
              consumeTapEvents: true,
              onTap: () => selectedPoiId.value = poi.id,
            ),
        };
      },
      const [],
    );

    final initialCamera = useMemoized(_initialCameraPosition, const []);

    useEffect(
      () {
        final controller = mapController.value;
        if (controller == null || boundsFitted.value) {
          return null;
        }

        boundsFitted.value = true;
        _fitBoundsToPois(controller, mapPois);

        return null;
      },
      [mapController.value],
    );

    useEffect(
      () => () {
        mapController.value?.dispose();
      },
      const [],
    );

    if (!isGoogleMapsConfigured) {
      return const _MapSetupRequiredPlaceholder();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final screenHeight = MediaQuery.sizeOf(context).height;
        final mapHeight = (screenHeight * 0.52).clamp(
          320.0,
          constraints.maxWidth >= 680 ? 560.0 : 480.0,
        );

        return SizedBox(
          height: mapHeight,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border.all(
                  color: context.goldBrass.withValues(alpha: 0.32),
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  GoogleMap(
                    initialCameraPosition: initialCamera,
                    markers: markers,
                    mapType: MapType.normal,
                    myLocationButtonEnabled: false,
                    zoomControlsEnabled: !kIsWeb,
                    compassEnabled: true,
                    onMapCreated: (controller) {
                      mapController.value = controller;
                    },
                    onTap: (_) => selectedPoiId.value = null,
                    gestureRecognizers: {
                      Factory<OneSequenceGestureRecognizer>(
                        EagerGestureRecognizer.new,
                      ),
                    },
                  ),
                  if (selectedPoi != null)
                    Positioned(
                      left: 12,
                      right: 12,
                      bottom: 12,
                      child: _MapPoiInfoCard(
                        poi: selectedPoi,
                        onClose: () => selectedPoiId.value = null,
                        onOpenInMaps: () async {
                          final opened = await context.openExternalUrl(
                            Uri.parse(selectedPoi.googleMapsUrl),
                          );
                          if (!opened && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Could not open Google Maps for this location.',
                                ),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _MapSetupRequiredPlaceholder extends StatelessWidget {
  const _MapSetupRequiredPlaceholder();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenHeight = MediaQuery.sizeOf(context).height;
        final mapHeight = (screenHeight * 0.52).clamp(
          320.0,
          constraints.maxWidth >= 680 ? 560.0 : 480.0,
        );

        return SizedBox(
          height: mapHeight,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: context.creamBackground.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: context.goldBrass.withValues(alpha: 0.32),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'MAP SETUP REQUIRED',
                    textAlign: TextAlign.center,
                    style: context.capsLabel(
                      color: context.sageGreen,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Add a Google Maps API key to run this page locally.',
                    textAlign: TextAlign.center,
                    style: context.scriptHero(fontSize: 26, height: 1.35),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '1. Enable Maps JavaScript API in Google Cloud Console.\n'
                    '2. Copy secrets.json.example to secrets.json and paste your key.\n'
                    '3. Run:\n'
                    './run.sh\n'
                    'or\n'
                    'flutter run -d chrome --dart-define-from-file=secrets.json',
                    textAlign: TextAlign.center,
                    style: context.faqAnswer(),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _MapPoiInfoCard extends StatelessWidget {
  const _MapPoiInfoCard({
    required this.poi,
    required this.onClose,
    required this.onOpenInMaps,
  });

  final MapPoi poi;
  final VoidCallback onClose;
  final VoidCallback onOpenInMaps;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: context.creamBackground.withValues(alpha: 0.96),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: context.goldBrass.withValues(alpha: 0.32),
          ),
          boxShadow: [
            BoxShadow(
              color: context.textCharcoal.withValues(alpha: 0.14),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 12, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          poi.categoryLabel,
                          style: context.capsLabel(
                            color: context.sageGreen,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          poi.title,
                          style: context.cardTitleCaps(),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: onClose,
                    tooltip: 'Close',
                    icon: Icon(
                      Icons.close_rounded,
                      color:
                          context.colorScheme.onSurface.withValues(alpha: 0.72),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                poi.address,
                style: context.cardBody(
                  fontSize: 14,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                poi.description,
                style: context.cardBody(
                  fontSize: 14,
                  height: 1.5,
                  color: context.textCharcoal.withValues(alpha: 0.88),
                ),
              ),
              const SizedBox(height: 18),
              Align(
                alignment: Alignment.centerLeft,
                child: WeddingActionButton(
                  label: 'OPEN IN GOOGLE MAPS',
                  minimumSize: const Size(0, 44),
                  onPressed: onOpenInMaps,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

CameraPosition _initialCameraPosition() {
  final latitudes = mapPois.map((poi) => poi.latitude);
  final longitudes = mapPois.map((poi) => poi.longitude);

  return CameraPosition(
    target: LatLng(
      latitudes.reduce((a, b) => a + b) / mapPois.length,
      longitudes.reduce((a, b) => a + b) / mapPois.length,
    ),
    zoom: 11,
  );
}

Future<void> _fitBoundsToPois(
  GoogleMapController controller,
  List<MapPoi> pois,
) async {
  if (pois.isEmpty) {
    return;
  }

  var minLat = pois.first.latitude;
  var maxLat = pois.first.latitude;
  var minLng = pois.first.longitude;
  var maxLng = pois.first.longitude;

  for (final poi in pois) {
    minLat = min(minLat, poi.latitude);
    maxLat = max(maxLat, poi.latitude);
    minLng = min(minLng, poi.longitude);
    maxLng = max(maxLng, poi.longitude);
  }

  final bounds = LatLngBounds(
    southwest: LatLng(minLat, minLng),
    northeast: LatLng(maxLat, maxLng),
  );

  try {
    await controller.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, 56),
    );
  } catch (_) {
    // newLatLngBounds can fail on first frame if map size is not ready yet.
    await Future<void>.delayed(const Duration(milliseconds: 300));
    try {
      await controller.animateCamera(
        CameraUpdate.newLatLngBounds(bounds, 56),
      );
    } catch (_) {
      // Fall back to the initial camera position if bounds still fail.
    }
  }
}
