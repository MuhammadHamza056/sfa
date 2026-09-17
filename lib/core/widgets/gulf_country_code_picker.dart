import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:sfa/core/theme/app_palette.dart';
import 'package:sfa/utils/phone_number_formatter.dart';

/// [CountryCodePicker] restricted to the Gulf countries this app delivers
/// in, and themed off [AppPalette] — the package defaults its selection
/// dialog to a hardcoded white background, which reads as broken in dark
/// mode.
class GulfCountryCodePicker extends StatelessWidget {
  final String initialSelection;
  final ValueChanged<CountryCode> onChanged;

  const GulfCountryCodePicker({
    super.key,
    required this.initialSelection,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return CountryCodePicker(
      onChanged: onChanged,
      initialSelection: initialSelection,
      countryFilter: gulfCountryIsoCodes,
      showCountryOnly: false,
      showOnlyCountryWhenClosed: false,
      alignLeft: false,
      textStyle: TextStyle(
        color: palette.textPrimary,
        fontWeight: FontWeight.bold,
      ),
      dialogBackgroundColor: palette.surface,
      dialogTextStyle: TextStyle(color: palette.textPrimary),
      searchStyle: TextStyle(color: palette.textPrimary),
      searchDecoration: InputDecoration(
        hintStyle: TextStyle(color: palette.textMuted),
        prefixIconColor: palette.textMuted,
      ),
      headerTextStyle: TextStyle(
        color: palette.textPrimary,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
      closeIcon: Icon(Icons.close, color: palette.textPrimary),
    );
  }
}
