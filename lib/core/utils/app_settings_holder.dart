import '../../features/shared/settings/data/models/app_settings_model.dart';
import '../../features/shared/settings/data/repos/app_settings_repo.dart';

/// Holds the contact details for the whole app.
///
/// These are read from widget build methods that cannot await, so the values
/// live here rather than in a cubit: the fetch runs once at startup, and until
/// it lands `current` is [AppSettingsModel.empty], which hides the controls
/// that depend on it. A failed fetch is not surfaced — no phone number simply
/// means no WhatsApp button, exactly as before the values existed.
class AppSettingsHolder {
  final AppSettingsRepo _repo;

  AppSettingsHolder(this._repo);

  AppSettingsModel _current = AppSettingsModel.empty;

  AppSettingsModel get current => _current;

  Future<void> load() async {
    final result = await _repo.getSettings();
    result.fold((_) {}, (settings) => _current = settings);
  }
}
