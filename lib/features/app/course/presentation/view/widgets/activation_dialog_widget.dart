import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:roboo/core/utils/app_localizations.dart';
import 'package:roboo/core/utils/colors.dart';
import 'package:roboo/core/utils/constats.dart';
import 'package:roboo/core/utils/external_links.dart';
import 'package:roboo/core/utils/functions.dart';
import 'package:roboo/core/widgets/custome_text_field.dart';
import 'package:roboo/core/widgets/primary_button.dart';
import 'package:roboo/features/app/course/data/models/course_place_model.dart';

class ActivationDialogs {
  /// [places] comes from the course's `available_places` — the centres that
  /// sell the activation code. Online courses carry them too, which is why the
  /// list is not tied to offline courses.
  static void showLocationsDialog(
    BuildContext context, {
    required List<CoursePlaceModel> places,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        insetPadding: EdgeInsets.symmetric(horizontal: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          "locations_title".tr(context),

          style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (places.isEmpty)
                _buildLocationItem("no_places_available".tr(context))
              else
                ...places.map((place) => _buildPlaceItem(context, place)),
              const SizedBox(height: 20),

              Row(
                children: [
                  Flexible(
                    flex: 1,
                    child: PrimaryButton(
                      text: "ok".tr(context),
                      mainColor: AppColors.primaryTwoColors,
                      backgroundColor: AppColors.primaryColors,
                      onTap: () => Navigator.pop(context),
                    ),
                  ),
                  if (AppContact.hasWhatsApp) ...[
                    const SizedBox(width: 8),
                    Flexible(
                      flex: 2,
                      child: PrimaryButton(
                        text: "contact_on_whatsapp".tr(context),
                        mainColor: AppColors.shadowGreen,
                        backgroundColor: AppColors.green,
                        iconData: FontAwesomeIcons.whatsapp,
                        onTap: () {
                          Navigator.pop(context);
                          ExternalLinks.openWhatsApp(
                            context,
                            phone: AppContact.whatsAppNumber,
                            message: "whatsapp_code_message".tr(context),
                          );
                        },
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Every centre carries `latitude`/`longitude`, so the row opens it in the
  /// device's map app.
  static Widget _buildPlaceItem(BuildContext context, CoursePlaceModel place) {
    final label = place.labelFor(Localizations.localeOf(context).languageCode);
    final hasCoordinates =
        double.tryParse(place.latitude?.trim() ?? '') != null &&
        double.tryParse(place.longitude?.trim() ?? '') != null;

    if (!hasCoordinates) return _buildLocationItem(label);

    return InkWell(
      onTap: () => ExternalLinks.openMap(
        context,
        latitude: place.latitude,
        longitude: place.longitude,
        label: label,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: GoogleFonts.cairo(color: Colors.grey[700]),
              ),
            ),
            const SizedBox(width: 6),
            const Icon(
              Icons.location_on,
              size: 16,
              color: AppColors.primaryColors,
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildLocationItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: GoogleFonts.cairo(color: Colors.grey[700]),
      ),
    );
  }

  static void showCodeInputDialog(
    BuildContext context,
    ValueChanged<String> onConfirm, {
    List<CoursePlaceModel> places = const [],
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        insetPadding: EdgeInsets.symmetric(horizontal: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          "enter_code_title".tr(context),

          style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
        ),
        content: _CodeInputContent(onConfirm: onConfirm, places: places),
      ),
    );
  }
}

/// The controller lives in a State so it is disposed once the dialog has really
/// left the tree. Disposing it from `showDialog().then(...)` tears it down while
/// the dialog is still animating out, which throws "used after being disposed".
class _CodeInputContent extends StatefulWidget {
  final ValueChanged<String> onConfirm;
  final List<CoursePlaceModel> places;

  const _CodeInputContent({required this.onConfirm, required this.places});

  @override
  State<_CodeInputContent> createState() => _CodeInputContentState();
}

class _CodeInputContentState extends State<_CodeInputContent> {
  final TextEditingController _codeController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void _confirm() {
    final code = _codeController.text.trim();
    if (code.isEmpty) {
      messages(context, "this_field_is_required".tr(context), AppColors.red);
      return;
    }

    Navigator.pop(context);
    widget.onConfirm(code);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.maxFinite,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "code_usage_note".tr(context),
            style: GoogleFonts.cairo(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          CustomTextField(
            hintText: "code_hint".tr(context),
            controller: _codeController,
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: PrimaryButton(
                  text: "confirm".tr(context),
                  backgroundColor: AppColors.primaryColors,
                  mainColor: AppColors.primaryTwoColors,
                  enterButton: true,
                  onTap: _confirm,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: PrimaryButton(
                  text: "where_to_buy".tr(context),
                  mainColor: AppColors.primaryColors,
                  iconData: Icons.maps_home_work_outlined,
                  withBorder: true,
                  onTap: () {
                    Navigator.pop(context);
                    ActivationDialogs.showLocationsDialog(
                      context,
                      places: widget.places,
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
