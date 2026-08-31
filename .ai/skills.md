# Skills

These workflows are for AI agents making implementation changes in this repo.

For the most common one — connecting a feature to an endpoint and rendering real data —
the executable version with verified code templates lives in
`.claude/skills/api-feature-integration/`. Workflows 3 to 8 below are the prose form of it.

## 1. Create A New Feature

**Use when**

- a feature does not already exist

**Workflow**

1. Inspect sibling features in the same scope.
2. Create only the folders needed now.
3. Add screen first.
4. Add Cubit only if the feature has state beyond local UI behavior.
5. Add repository only if API/data work is in scope.
6. Add route and DI only if the feature is used immediately.

**Expected files**

- feature folder
- optional screen
- optional Cubit/state
- optional repo/model

**Done when**

- the feature follows the existing feature-first structure
- no unused abstraction was added

## 2. Add A Screen To An Existing Feature

**Use when**

- adding list, detail, edit, or sub-flow screens

**Workflow**

1. Inspect the feature’s existing navigation style.
2. Add the screen under the feature’s current `presentation` structure.
3. Reuse feature-local widgets first.
4. If the screen needs API data, connect it to the feature Cubit.

**Done when**

- navigation matches the feature’s current style
- screen contains no networking code

## 3. Prepare A Feature For API Integration

**Use when**

- the feature has static UI or placeholder `temp_*` files

**Case A: feature already has repo/Cubit scaffolding**

1. Read the screen, `temp_repo`, and `temp_cubit`.
2. Identify hardcoded data in the UI.
3. Rename placeholders only inside this feature.
4. Keep reusable widgets stable if possible.

**Case B: feature has UI only**

1. Add repository.
2. Add Cubit and states.
3. Replace hardcoded flow with Cubit-driven state.

**Done when**

- the feature has a clear View -> Cubit -> Repository path
- hardcoded feature data is isolated or removed

## 4. Integrate One Feature With Backend APIs

**Use when**

- one feature has a clear Postman match

**Workflow**

1. Read the exact Postman folder and requests.
2. Record method, path, auth, body mode, and sample payloads.
3. Mark missing response details as unclear.
4. Read the current Flutter feature files.
5. Add repository/model code.
6. Add or update Cubit states and actions.
7. Wire the screen to Cubit.
8. Remove only the mocked data replaced by the new flow.

**Done when**

- the feature uses Postman-backed endpoints
- Cubit is the ViewModel layer
- the screen handles loading/error/success

## 5. Add A New API Endpoint To An Existing Feature

**Use when**

- one integrated feature needs one more backend action

**Workflow**

1. Extend the existing repository.
2. Extend models only if required.
3. Extend Cubit states/actions.
4. Update the screen with minimal scope.

**Done when**

- the endpoint lives in the existing feature boundary
- no duplicate repo/Cubit was created

## 6. Add Or Update A Cubit Flow

**Use when**

- a feature has no real ViewModel flow yet
- a placeholder Cubit needs real behavior

**Workflow**

1. Define the feature states.
2. Inject repository into Cubit.
3. Emit loading before async work.
4. Emit success, empty, or error after repository result.
5. Wrap the screen with `BlocProvider` and render from state.

**Done when**

- Cubit owns the feature flow
- the screen no longer owns async business logic

## 7. Fix An API Integration Bug

**Use when**

- request shape, parsing, auth, or state flow is wrong

**Workflow**

1. Compare code against the Postman request.
2. Fix the lowest correct layer first:
   - request construction
   - repository parsing
   - Cubit state flow
   - shared API behavior only if truly shared
3. Document ambiguities instead of inventing behavior.

**Done when**

- the fix matches repo structure and Postman evidence
- no unrelated cleanup is bundled in

## 8. Refactor A Partially Integrated Feature

**Use when**

- a feature mixes placeholders, hardcoded UI, and partial API code

**Workflow**

1. Keep the feature boundary.
2. Replace `temp_*` names in that feature only.
3. Move API logic into repository.
4. Move state flow into Cubit.
5. Keep pure UI widgets simple.

**Done when**

- the feature is easier to extend without changing unrelated code

## 9. Add Localization Keys

**Use when**

- adding or changing visible UI text

**Workflow**

1. Add the key to `assets/lang/en.json`.
2. Add the same key to `assets/lang/ar.json`.
3. Use `.tr(context)` in the widget.

**Done when**

- both language files are updated
- no new hardcoded visible text remains

## 10. Add Tests

**Use when**

- a feature change is risky enough to justify coverage

**Workflow**

1. Add tests only for the feature being changed.
2. Prefer repository parsing or Cubit state-flow tests first.
3. Add widget tests only when screen behavior is stable enough.

**Done when**

- tests cover the changed feature, not broad app behavior

## 11. Update Technical Documentation

**Use when**

- a feature integration changes how future agents should work

**Workflow**

1. Update only the affected AI docs.
2. Separate current state from target guidance.
3. Record unresolved API ambiguity plainly.

**Done when**

- the docs match the actual code and Postman evidence
