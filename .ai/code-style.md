# Code Style

## Naming

- screen files: `*_screen.dart`
- widget files: `*_widget.dart`
- Cubit files: `*_cubit.dart`
- state files: `*_state.dart`
- repository contract files: `*_repo.dart`
- repository implementation files for new work: `*_repo_impl.dart`
- model files: `*_model.dart`
- request/params files only when needed: `*_request.dart`, `*_params.dart`

Existing repo caveat:

- some files use `iplm` / `ipml`
- keep legacy names when editing in place unless the task includes renaming that feature cleanly

## Folder Rules

- keep work inside the existing feature folder
- keep `presentation/view-model/` because that is the repo convention
- keep feature widgets inside the feature unless they are already shared
- keep models and repos under the feature’s `data/`

Do not create a new top-level architecture branch for one task.

## View Rules

Views may:

- render Cubit state
- gather user input
- hold local visual state
- navigate using the feature’s current routing style

Views may not:

- call `ApiServices`
- call `Dio`
- parse API responses
- hold feature business rules

## Cubit Rules

Cubit is the ViewModel layer in this repo.

Cubits must:

- expose explicit states
- call repositories
- emit loading before async work
- emit success, empty, or error after async work

Cubits must not:

- import widgets
- own raw HTTP code when a repository exists
- manage multiple unrelated feature flows in one class

## State Rules

Use explicit states such as:

- `Initial`
- `Loading`
- `Success`
- `Error`

Add feature-specific states only when needed:

- `Loaded`
- `Empty`
- `Submitting`
- `ResendCodeSuccess`

Do not use `bool` return values from Cubit as the main state contract.

## Repository Rules

Repositories must:

- use shared `ApiServices`
- build request payloads
- parse response data
- convert failures via `ErrorHandler`
- return `Either<Failure, T>`

Repositories must not:

- import presentation code
- return raw `Response` objects to Cubits unless the task explicitly requires a low-level migration step

## Model Rules

- add only the fields supported by Postman or observed response usage
- keep fields nullable if the response shape is not proven
- prefer feature-local models
- do not create shared models just because two features both have `id` and `name`

## Loading / Error / Success Handling

Every API-backed screen should make room for:

- initial state
- loading state
- success or loaded state
- empty state when list data can be empty
- error state

Do not replace error handling with silent failures or print-only debugging.

## Localization Rules

- every new visible string must use `"key".tr(context)`
- add keys to both `assets/lang/en.json` and `assets/lang/ar.json`
- keep API error display compatible with localization keys where shared error constants are already used

Do not add new hardcoded UI strings during feature integration.

## Routing Rules

- if the feature uses `routeName`, keep using it
- update `lib/core/utils/routs.dart` only when adding a new named route
- preserve direct constructor navigation for detail screens if that is already how the feature works

Do not bundle routing refactors into an unrelated API task.

## Dependency Injection Rules

- register new repositories/services in `lib/core/utils/services_locater.dart`
- inject repositories into Cubits
- create Cubits at the screen boundary, not deep inside child widgets

Do not instantiate repositories or `ApiServices` in the screen.

## Reusable Widget Rules

- reuse feature-local widgets before creating new shared widgets
- move a widget to `core/widgets/` only if it is genuinely shared across features
- keep widgets small once they start mixing rendering and flow logic

## Safe Refactoring Rules

- rename `temp_*` only inside the feature being integrated
- remove hardcoded mock data only when replaced by real state
- do not rename or reorganize unrelated features while implementing one feature

## Anti-Patterns

- widget -> `ApiServices`
- widget -> repository for feature flow
- raw JSON parsing in a screen
- hardcoded mock lists left in place after API wiring
- new app-wide abstraction created after seeing only one feature
- admin and app endpoints mixed in one user feature
- leaving real integrated code inside `temp_repo` or `temp_cubit`
