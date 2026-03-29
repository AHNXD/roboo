# Architecture

## Current Repository Structure

Observed structure:

- `lib/core/`
- `lib/features/auth/`
- `lib/features/app/`
- `lib/features/shared/`

Observed feature shape:

- `presentation/view` or `presentation/views`
- `presentation/view-model`
- `data/repos`
- sometimes `data/models`

Observed wiring reality:

- auth has real repositories and Cubits
- most app features have placeholder `temp_repo` and `temp_cubit` files
- most screens still render hardcoded data
- almost no feature screens are currently wired with `BlocProvider` / `BlocBuilder`

## MVVM In This Repository

### View

Where it lives:

- feature screens under `presentation/view` or `presentation/views`
- feature widgets under local `widgets/`

View responsibilities:

- render state
- collect user input
- call Cubit actions
- keep local visual-only state such as tab index or animation state

View must not:

- call APIs
- parse JSON
- construct request payloads
- own feature business flow

### ViewModel

In this repo, `Cubit` is the ViewModel layer.

Where it lives:

- `presentation/view-model/`

Cubit responsibilities:

- expose feature state
- trigger repository calls
- convert repository results into UI states
- own loading/error/success transitions

Cubit must not:

- import widgets
- contain raw `Dio` request code if a repository exists
- become a god object for multiple unrelated screens

### Model / Data

Where it lives:

- `data/repos/`
- `data/models/`

Repository responsibilities:

- choose endpoint
- build request payload
- call `ApiServices`
- parse response
- return `Either<Failure, T>`

Data layer must not:

- import presentation code
- depend on widget classes
- expose raw `Response` objects to the View

## Dependency Direction

Required direction:

`View -> Cubit -> Repository -> ApiServices`

Allowed shared dependencies:

- `core/errors`
- `core/utils`
- `core/widgets`
- localization

Forbidden direction:

- `data -> presentation`
- `widget -> repository -> API` without Cubit

## Current Implementation Vs Target Integration Architecture

### Current Implementation

- shared `Dio` wrapper exists in `ApiServices`
- shared error handling exists
- `get_it` exists but registers only a small subset of dependencies
- locale state is wired globally
- auth has real repos/Cubits but current requests do not fully match the Postman collection
- most non-auth features are UI-first and not actually connected to their placeholder data layers

### Target Architecture For New API Work

For each feature being integrated:

- View stays declarative
- Cubit becomes the feature ViewModel
- repository owns API interaction
- models are added only for the feature being integrated
- hardcoded screen data is replaced by Cubit state

Do not try to make the whole repo reach the target architecture in one task.

## Shared Infrastructure To Reuse

- `lib/core/Api_services/api_services.dart`
- `lib/core/Api_services/auth_interceptor.dart`
- `lib/core/errors/error_handler.dart`
- `lib/core/errors/failuer.dart`
- `lib/core/utils/cache_helper.dart`
- `lib/core/utils/services_locater.dart`
- `lib/core/utils/app_localizations.dart`

## Routing

Observed pattern:

- many screens expose static `routeName`
- named routes are registered in `lib/core/utils/routs.dart`
- some detail screens still use direct `MaterialPageRoute`

Rule:

- keep the existing pattern used by the feature you are editing
- do not rewrite routing globally as part of a feature integration

## Dependency Injection

Observed pattern:

- `get_it` is used in `services_locater.dart`
- `Dio`, `ApiServices`, locale, and some auth repositories are registered
- placeholder feature repos/Cubits are not registered

Rule:

- register only the dependencies needed by the feature you are integrating
- do not instantiate repositories in widgets

## Localization

Observed pattern:

- custom JSON-based localization
- strings accessed with `"key".tr(context)`

Rule:

- all new user-facing strings must be localization keys in both `en.json` and `ar.json`

## Testing

Observed state:

- no `test/` directory
- no established test convention in the repo

Rule:

- if tests are added, keep them feature-scoped and lightweight
- do not invent a full testing architecture while integrating one feature

## Rules For Adding API-Backed Code

### Case A: Feature Already Has Repo + Cubit Structure

1. Keep the existing feature folder.
2. Replace placeholder repo/Cubit names with real feature names if you are integrating that feature now.
3. Add real repository methods and models.
4. Wire the screen to Cubit if it is not already wired.

### Case B: Feature Has UI But No Real Data Wiring

1. Keep the existing screen and widget structure where possible.
2. Add a feature repository.
3. Add a feature Cubit and states.
4. Move hardcoded data out of the screen.
5. Keep only visual-only state in the widget tree.

## Architecture Violations To Avoid

- widget directly calling `ApiServices`
- widget directly calling repository methods for feature flow
- Cubit constructing and parsing raw HTTP responses when repository separation already exists
- repository importing screen code
- keeping new API logic inside `temp_*` classes after a feature becomes real
- mixing admin endpoints into a mobile user feature
- using placeholder scaffolding as proof that a feature is already integrated
