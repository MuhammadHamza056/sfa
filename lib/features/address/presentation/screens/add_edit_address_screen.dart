import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:sfa/core/localization/app_localizations.dart';
import 'package:sfa/core/theme/app_palette.dart';
import 'package:sfa/core/widgets/gulf_country_code_picker.dart';
import 'package:sfa/utils/color_constants.dart';
import 'package:sfa/utils/loader.dart';
import 'package:sfa/utils/phone_number_formatter.dart';
import '../../models/address.dart';
import '../../providers/address_provider.dart';

/// Add/Edit screen for an entry of the address list shown on
/// [AddressScreen]. Pass an existing [Address] to pre-fill the form in edit
/// mode; omit it to add a new address.
///
/// On save, writes through [addressProvider] (M40 create / inferred update)
/// and pops once the API confirms — [AddressScreen] picks up the change
/// automatically via `ref.watch`.
class AddEditAddressScreen extends ConsumerStatefulWidget {
  final Address? address;

  const AddEditAddressScreen({super.key, this.address});

  bool get isEditMode => address != null;

  @override
  ConsumerState<AddEditAddressScreen> createState() =>
      _AddEditAddressScreenState();
}

/// Signed decimal input for the latitude/longitude fields — the range check
/// still happens on save.
final _coordinateFormatters = [
  FilteringTextInputFormatter.allow(RegExp(r'[0-9.\-]')),
];

class _AddEditAddressScreenState extends ConsumerState<AddEditAddressScreen> {
  /// Dial codes recognized when splitting an existing address's saved
  /// [Address.contactNumber] back into code + local number. Falls back to
  /// [_defaultDialCode] for numbers saved before the picker existed.
  static final _knownDialCodes = gulfPhoneLengths.keys.toList();
  static const _defaultDialCode = '+965';

  late final TextEditingController _labelController;
  late final TextEditingController _contactNumberController;
  String _dialCode = _defaultDialCode;
  late final TextEditingController _governorateController;
  late final TextEditingController _areaController;
  late final TextEditingController _blockController;
  late final TextEditingController _streetController;
  late final TextEditingController _houseNumberController;
  late final TextEditingController _latitudeController;
  late final TextEditingController _longitudeController;

  /// The numeric keyboard has no submit key on iOS, so a hand-typed
  /// coordinate is committed when the pair loses focus rather than on
  /// `onSubmitted` alone.
  final FocusNode _latitudeFocus = FocusNode();
  final FocusNode _longitudeFocus = FocusNode();
  bool _saving = false;

  // ─── Map pin ────────────────────────────────────────────────────────
  final MapController _mapController = MapController();

  /// Where the courier is sent. `null` until the customer drops a pin —
  /// the map starts on a generic city view, which must never be mistaken
  /// for a real choice, so [_onSave] refuses to submit without one.
  LatLng? _pin;

  /// The camera can only be driven once [FlutterMap] has attached the
  /// controller; the first position is placed with `initialCenter`.
  bool _mapReady = false;
  bool _locating = false;

  /// Reverse geocoding runs on the pin the customer settles on, not on
  /// every frame of a drag.
  Timer? _geocodeDebounce;

  /// Riyadh — only ever the starting view for a brand-new address, and the
  /// same fallback the checkout map uses.
  static const LatLng _fallbackCenter = LatLng(24.7136, 46.6753);

  @override
  void initState() {
    super.initState();
    final address = widget.address;
    _labelController = TextEditingController(text: address?.name ?? '');
    final savedNumber = address?.contactNumber ?? '';
    final knownCode = _knownDialCodes.firstWhere(
      savedNumber.startsWith,
      orElse: () => _defaultDialCode,
    );
    _dialCode = knownCode;
    _contactNumberController = TextEditingController(
      text: savedNumber.startsWith(knownCode)
          ? savedNumber.substring(knownCode.length)
          : savedNumber,
    );
    _governorateController = TextEditingController(
      text: address?.governorate ?? '',
    );
    _areaController = TextEditingController(text: address?.area ?? '');
    _blockController = TextEditingController(text: address?.block ?? '');
    _streetController = TextEditingController(text: address?.street ?? '');
    _houseNumberController = TextEditingController(
      text: address?.houseNumber ?? '',
    );
    if (address != null && address.hasLocation) {
      _pin = LatLng(address.latitude, address.longitude);
    }
    // Left blank rather than showing "0" when the backend has no real pin —
    // see Address.hasLocation.
    _latitudeController = TextEditingController(
      text: _pin == null ? '' : _formatCoordinate(_pin!.latitude),
    );
    _longitudeController = TextEditingController(
      text: _pin == null ? '' : _formatCoordinate(_pin!.longitude),
    );
    _latitudeFocus.addListener(_onCoordinateFocusChange);
    _longitudeFocus.addListener(_onCoordinateFocusChange);
  }

  @override
  void dispose() {
    _geocodeDebounce?.cancel();
    _mapController.dispose();
    _labelController.dispose();
    _contactNumberController.dispose();
    _governorateController.dispose();
    _areaController.dispose();
    _blockController.dispose();
    _streetController.dispose();
    _houseNumberController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _latitudeFocus.dispose();
    _longitudeFocus.dispose();
    super.dispose();
  }

  /// ~11 cm of precision; enough for a doorstep and short enough to read
  /// back in the latitude/longitude fields.
  static String _formatCoordinate(double value) => value.toStringAsFixed(6);

  /// Records the pin the order will be dispatched to. [moveCamera] is false
  /// when the move *came from* the camera (a drag), so the controller isn't
  /// driven back onto a position it already holds.
  void _setPin(LatLng point, {bool moveCamera = true, double? zoom}) {
    setState(() => _pin = point);
    _latitudeController.text = _formatCoordinate(point.latitude);
    _longitudeController.text = _formatCoordinate(point.longitude);
    if (moveCamera && _mapReady) {
      _mapController.move(point, zoom ?? _mapController.camera.zoom);
    }
    _scheduleGeocode(point);
  }

  /// Only gestures change the pin: a programmatic [MapController.move] also
  /// fires this callback, and honouring it would fight the camera.
  void _onPositionChanged(MapCamera camera, bool hasGesture) {
    if (!hasGesture) return;
    _setPin(camera.center, moveCamera: false);
  }

  void _scheduleGeocode(LatLng point) {
    _geocodeDebounce?.cancel();
    _geocodeDebounce = Timer(
      const Duration(milliseconds: 800),
      () => _geocode(point),
    );
  }

  /// M43 — fills in whatever the customer hasn't typed yet. Fields they
  /// already filled are never overwritten, and a failed lookup is silent:
  /// the pin is what the backend actually dispatches on.
  Future<void> _geocode(LatLng point) async {
    final result = await ref
        .read(addressRepositoryProvider)
        .geocode(lat: point.latitude, lng: point.longitude);
    if (!mounted) return;
    final geocoded = result.dataOrNull;
    if (geocoded == null) return;
    if (_governorateController.text.trim().isEmpty && geocoded.city.isNotEmpty) {
      _governorateController.text = geocoded.city;
    }
    if (_areaController.text.trim().isEmpty && geocoded.district.isNotEmpty) {
      _areaController.text = geocoded.district;
    }
  }

  /// Moves the pin onto the device's GPS fix. Every failure path is
  /// reported — the customer can still drag the map instead.
  Future<void> _useCurrentLocation(AppLocalizations loc) async {
    if (_locating) return;
    setState(() => _locating = true);
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        Loader.showError(loc.translate('locationServiceDisabled'));
        return;
      }
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        Loader.showError(loc.translate('locationPermissionDenied'));
        return;
      }
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 20),
        ),
      );
      if (!mounted) return;
      _setPin(LatLng(position.latitude, position.longitude), zoom: 17);
    } catch (_) {
      if (mounted) Loader.showError(loc.translate('locationUnavailable'));
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  /// Commits the typed pair once the customer has left both fields.
  void _onCoordinateFocusChange() {
    if (_latitudeFocus.hasFocus || _longitudeFocus.hasFocus) return;
    // Moving between the two fields unfocuses one before focusing the
    // other, so the decision waits a frame — tabbing across shouldn't
    // commit (and re-centre on) a half-typed pair.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (_latitudeFocus.hasFocus || _longitudeFocus.hasFocus) return;
      _onCoordinateSubmitted();
    });
  }

  /// Typed coordinates drive the camera too, so the map keeps showing the
  /// point that will actually be saved.
  void _onCoordinateSubmitted() {
    final latitude = double.tryParse(_latitudeController.text.trim());
    final longitude = double.tryParse(_longitudeController.text.trim());
    if (latitude == null ||
        longitude == null ||
        !_isValidCoordinate(latitude, longitude)) {
      return;
    }
    final point = LatLng(latitude, longitude);
    // Re-pinning an unchanged point would fire a pointless geocode lookup.
    if (point == _pin) return;
    _setPin(point, zoom: 17);
  }

  static bool _isValidCoordinate(double latitude, double longitude) =>
      latitude >= -90 &&
      latitude <= 90 &&
      longitude >= -180 &&
      longitude <= 180;

  Future<void> _onSave(AppLocalizations loc) async {
    final label = _labelController.text.trim();
    final contactNumber = _contactNumberController.text.trim();
    final governorate = _governorateController.text.trim();
    final area = _areaController.text.trim();
    final block = _blockController.text.trim();
    final street = _streetController.text.trim();
    final houseNumber = _houseNumberController.text.trim();

    if (label.isEmpty ||
        contactNumber.isEmpty ||
        governorate.isEmpty ||
        area.isEmpty ||
        block.isEmpty ||
        street.isEmpty ||
        houseNumber.isEmpty) {
      Loader.showError(loc.translate('fieldRequired'));
      return;
    }

    final phoneError = PhoneInputValidator.validatePhoneNumber(
      contactNumber,
      _dialCode,
    );
    if (phoneError != null) {
      Loader.showError(phoneError);
      return;
    }

    // The pin is not optional: dispatch, driver assignment, distance
    // pricing and route optimisation all run off these coordinates, and a
    // 0/0 address silently breaks every one of them.
    final latitude = double.tryParse(_latitudeController.text.trim());
    final longitude = double.tryParse(_longitudeController.text.trim());
    if (latitude == null || longitude == null || (latitude == 0 && longitude == 0)) {
      Loader.showError(loc.translate('pickOnMap'));
      return;
    }
    if (!_isValidCoordinate(latitude, longitude)) {
      Loader.showError(
        loc.isArabic
            ? 'إحداثيات غير صالحة'
            : 'Enter valid latitude and longitude',
      );
      return;
    }

    setState(() => _saving = true);

    final existing = widget.address;
    final address = Address(
      id: existing?.id ?? '',
      name: label,
      contactNumber: '$_dialCode$contactNumber',
      governorate: governorate,
      area: area,
      block: block,
      street: street,
      houseNumber: houseNumber,
      latitude: latitude,
      longitude: longitude,
      isDefault: existing?.isDefault ?? false,
    );

    final ok = widget.isEditMode
        ? await ref.read(addressProvider.notifier).updateAddress(address)
        : await ref.read(addressProvider.notifier).addAddress(address);

    if (!mounted) return;
    setState(() => _saving = false);

    if (ok) {
      Loader.showSuccess(loc.translate('addressSavedSuccess'));
      context.pop();
    } else {
      Loader.showError(
        loc.isArabic ? 'تعذر حفظ العنوان' : 'Could not save address',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final isAr = loc.isArabic;
    final textAlign = isAr ? TextAlign.right : TextAlign.left;

    return Directionality(
      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: context.palette.background,
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ─── Map pin picker ─────────────────────────────────────
              // The pin, not the typed text, is what dispatch runs on, so
              // it leads the form.
              Text(
                loc.translate('pickOnMap'),
                textAlign: textAlign,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: context.palette.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              _buildMap(context),
              const SizedBox(height: 8),
              Text(
                loc.translate('pickOnMapHint'),
                textAlign: textAlign,
                style: TextStyle(fontSize: 12, color: context.palette.textMuted),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _locating ? null : () => _useCurrentLocation(loc),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                  side: BorderSide(color: context.palette.divider, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                icon: _locating
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(Icons.my_location, size: 18, color: AppColors.primary),
                label: Text(
                  loc.translate('useCurrentLocation'),
                  style: TextStyle(
                    color: context.palette.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              _FormField(
                label: isAr ? 'اسم العنوان' : 'Address Label',
                hint: isAr ? 'مثل: المنزل، العمل' : 'e.g. Home, Work',
                controller: _labelController,
                textAlign: textAlign,
              ),
              const SizedBox(height: 20),
              _PhoneFormField(
                label: loc.translate('phoneLabel'),
                hint: loc.translate('phoneHint'),
                controller: _contactNumberController,
                dialCode: _dialCode,
                onDialCodeChanged: (code) => setState(() => _dialCode = code),
                textAlign: textAlign,
              ),
              const SizedBox(height: 20),
              _FormField(
                label: isAr ? 'المحافظة' : 'Governorate',
                hint: isAr ? 'مثل: العاصمة' : 'e.g. Al Asimah',
                controller: _governorateController,
                textAlign: textAlign,
              ),
              const SizedBox(height: 20),
              _FormField(
                label: isAr ? 'المنطقة' : 'Area',
                hint: isAr ? 'مثل: السالمية' : 'e.g. Salmiya',
                controller: _areaController,
                textAlign: textAlign,
              ),
              const SizedBox(height: 20),
              _FormField(
                label: isAr ? 'القطعة' : 'Block',
                hint: isAr ? 'مثل: 4' : 'e.g. 4',
                controller: _blockController,
                textAlign: textAlign,
              ),
              const SizedBox(height: 20),
              _FormField(
                label: isAr ? 'الشارع' : 'Street',
                hint: isAr
                    ? 'مثل: شارع سالم المبارك'
                    : 'e.g. Salem Al Mubarak St.',
                controller: _streetController,
                textAlign: textAlign,
              ),
              const SizedBox(height: 20),
              _FormField(
                label: isAr ? 'رقم المنزل' : 'House Number',
                hint: isAr ? 'مثل: 12' : 'e.g. 12',
                controller: _houseNumberController,
                textAlign: textAlign,
              ),
              const SizedBox(height: 20),
              // Map coordinates — posted as `latitude`/`longitude` by
              // Address.toJson. Normally written by the map above; editing
              // them by hand moves the pin. Always LTR: signed decimal
              // numbers read left-to-right even in the Arabic layout.
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _FormField(
                      label: isAr ? 'خط العرض' : 'Latitude',
                      hint: 'e.g. 29.3759',
                      controller: _latitudeController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                        signed: true,
                      ),
                      textDirection: TextDirection.ltr,
                      textAlign: TextAlign.left,
                      inputFormatters: _coordinateFormatters,
                      focusNode: _latitudeFocus,
                      onSubmitted: (_) => _onCoordinateSubmitted(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _FormField(
                      label: isAr ? 'خط الطول' : 'Longitude',
                      hint: 'e.g. 47.9774',
                      controller: _longitudeController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                        signed: true,
                      ),
                      textDirection: TextDirection.ltr,
                      textAlign: TextAlign.left,
                      inputFormatters: _coordinateFormatters,
                      focusNode: _longitudeFocus,
                      onSubmitted: (_) => _onCoordinateSubmitted(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Save button — mirrors the "Add New Address" CTA on AddressScreen.
              Container(
                height: 54,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(27),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _saving ? null : () => _onSave(loc),
                    borderRadius: BorderRadius.circular(27),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: _saving
                          ? const Center(
                              child: SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  widget.isEditMode
                                      ? loc.translate('saveChanges')
                                      : loc.translate('addAddress'),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Cancel button.
              SizedBox(
                height: 54,
                child: OutlinedButton(
                  onPressed: () => context.pop(),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: context.palette.divider,
                      width: 1.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(27),
                    ),
                    backgroundColor: context.palette.background,
                  ),
                  child: Text(
                    loc.translate('cancel'),
                    style: TextStyle(
                      color: context.palette.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// The pin is painted at the centre of the viewport rather than as a
  /// marker: the customer moves the map under a fixed crosshair, which is
  /// steadier than dragging a marker on a small screen.
  Widget _buildMap(BuildContext context) {
    final pin = _pin;
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        height: 220,
        child: Stack(
          children: [
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: pin ?? _fallbackCenter,
                // Zoomed out until there is a real pin, so a city-level view
                // doesn't read as a chosen doorstep.
                initialZoom: pin == null ? 11 : 16,
                onMapReady: () => _mapReady = true,
                onPositionChanged: _onPositionChanged,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.pinchZoom |
                      InteractiveFlag.drag |
                      InteractiveFlag.doubleTapZoom,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.sfa.app',
                ),
              ],
            ),
            // Nudged up by half its height so the tip — not the middle of
            // the glyph — marks the centre coordinate.
            IgnorePointer(
              child: Center(
                child: Transform.translate(
                  offset: const Offset(0, -20),
                  child: Icon(
                    Icons.location_pin,
                    size: 40,
                    color: pin == null
                        ? context.palette.textMuted
                        : AppColors.primary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Phone field with a leading dial-code picker — [Address.contactNumber]
/// stores the two concatenated (see [_AddEditAddressScreenState._onSave]),
/// since the backend DTO has no separate country-code field.
class _PhoneFormField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final String dialCode;
  final ValueChanged<String> onDialCodeChanged;
  final TextAlign textAlign;

  const _PhoneFormField({
    required this.label,
    required this.hint,
    required this.controller,
    required this.dialCode,
    required this.onDialCodeChanged,
    required this.textAlign,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          textAlign: textAlign,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: context.palette.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Directionality(
          textDirection: TextDirection.ltr,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: context.palette.divider, width: 1.5),
            ),
            child: Row(
              children: [
                GulfCountryCodePicker(
                  initialSelection: dialCode,
                  onChanged: (country) =>
                      onDialCodeChanged(country.dialCode ?? dialCode),
                ),
                Container(height: 24, width: 1, color: context.palette.divider),
                Expanded(
                  child: TextField(
                    controller: controller,
                    keyboardType: TextInputType.phone,
                    textAlign: TextAlign.left,
                    inputFormatters: [
                      PhoneInputFormatter(
                        maxLength: gulfPhoneLengths[dialCode] ?? 9,
                      ),
                    ],
                    style: TextStyle(color: context.palette.textPrimary),
                    decoration: InputDecoration(
                      hintText: hint,
                      hintStyle: TextStyle(
                        color: context.palette.textMuted,
                        fontSize: 13,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 16,
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _FormField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final TextDirection? textDirection;
  final TextAlign textAlign;
  final List<TextInputFormatter>? inputFormatters;
  final FocusNode? focusNode;
  final ValueChanged<String>? onSubmitted;

  const _FormField({
    required this.label,
    required this.hint,
    required this.controller,
    required this.textAlign,
    this.keyboardType,
    this.textDirection,
    this.inputFormatters,
    this.focusNode,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          textAlign: textAlign,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: context.palette.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          textDirection: textDirection,
          textAlign: textAlign,
          focusNode: focusNode,
          onSubmitted: onSubmitted,
          inputFormatters:
              inputFormatters ??
              (keyboardType == TextInputType.phone
                  ? [FilteringTextInputFormatter.allow(RegExp(r'[0-9+\s]'))]
                  : null),
          style: TextStyle(color: context.palette.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: context.palette.textMuted,
              fontSize: 13,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: context.palette.divider,
                width: 1.5,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: context.palette.divider,
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: AppColors.primary, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
