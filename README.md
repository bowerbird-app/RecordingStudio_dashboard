# Recording Studio Dashboard

Recording Studio Dashboard composes dashboards for Recording Studio applications. A host registers dashboards, rows, and widgets in Ruby. The gem places each widget on a 12-column grid. The widget renders everything inside its area.

The dummy app demonstrates the framework with generic studio widgets. Featured In can register its own widgets the same way. This gem does not depend on press kits, messages, or any other domain gem.

## Hierarchy

```text
Dashboard
  ├── Header
  ├── Row
  │     ├── Widget
  │     │     └── Widget-owned content
  │     └── Widget
  │           └── Widget-owned content
  └── Row
        └── Widget
              ├── Content item
              ├── Content item
              └── Content item
```

A widget is one dashboard unit. Cards, checklist steps, carousel slides, and metric figures inside that unit belong to the widget's component. The dashboard counts placements, not the items a widget draws.

## Register a dashboard

Definitions live in Ruby. They are not database records.

```ruby
RecordingStudioDashboard.register(:home) do
  header component: WelcomeComponent

  row :press_center, title: "Your press center" do
    widget :press_center_overview, span: 6
    widget :getting_started, span: 6
  end

  row :activity, title: "Recent activity", action: { label: "View all", url: "/kits" } do
    widget :recent_press_kits, span: 12, config: { limit: 10, display: :carousel }
  end

  row :stats, title: "Stats" do
    widget :downloads, span: 6
    widget :views, span: 6
  end
end
```

`RecordingStudioDashboard.component(:home, context: context)` returns the dashboard component. Render it from a host view. The header component receives `context:`. Site logo, account menu, and top navigation stay in the host layout.

A row heading is the section title and an optional action. It does not render a subtitle.

Two different widget types can share a row. Each placement has a stable id. The id defaults to the widget type id, and a second placement of the same type sets its own id.

## Register a widget

Other gems and the host register widget types. The same type can appear on many dashboards.

```ruby
RecordingStudioDashboard.register_widget(
  :recent_press_kits,
  component: RecentKitsComponent,
  default_span: 12,
  supported_spans: [6, 12],
  options: %i[limit display sort],
  empty: :message,
  empty_message: "No recent items yet"
)
```

A widget component may implement `self.prepare(context, config)`. It returns one `RecordingStudioDashboard::Preparation`.

```ruby
def self.prepare(context, config)
  items = context.recent_items(config)
  return RecordingStudioDashboard::Preparation.empty if items.nil?
  return RecordingStudioDashboard::Preparation.empty(message: "No recent items yet") if items.empty?

  RecordingStudioDashboard::Preparation.content(items)
end
```

`prepare` runs once. The component then receives `context:`, `config:`, and `preparation:`. A missing `prepare` renders `Preparation.content(config)`. A raised error becomes `Preparation.error` for that placement and is written to the Rails log. Sibling widgets still render.

`nil` stays empty. A metric that measured zero returns `Preparation.content(0)`.

The widget chooses Flatpack components for its content. A collection can render `FlatPack::Grid` or `FlatPack::Carousel`. The dashboard does not register the cards inside that collection.

## Visibility and empty states

Permission runs before `prepare`. A false permission drops the placement and does not load its data. A `visible_if` symbol is sent to the context. A callable receives the context. A hidden placement takes no columns.

Empty policies are `:hide`, `:message`, `:placeholder`, and `:custom`. `:hide` removes the placement. The other three keep the width and render Flatpack empty state, a skeleton, or `empty_state.component`.

```ruby
widget :getting_started, span: 6 do
  visible_if :onboarding_incomplete?
end
```

When every placement in a row is gone, the row drops, including its title and action. Set a row `empty:` policy when the heading should remain.

```ruby
row :vacant, title: "Needs content", empty: { policy: :message, message: "This section is waiting for content." } do
  widget :recent_items, config: { source: "empty" }
end
```

## Width after a widget leaves

`collapse: :expand` is the default. Remaining widgets share the freed columns, up to 12. `collapse: :preserve` keeps each configured span. Spans that already sum to 12 stay as configured.

```ruby
row :overview, title: "Overview", collapse: :expand do
  widget :profile, span: 6
  widget :setup, span: 6
end
```

If `setup` is hidden, `profile` renders at span 12.

## Fixed, personalised, and user-created dashboards

`:fixed` ignores stored overrides. No preference row is read.

`:personalised` allows row order, widget order, hide, resize, and add. A `mandatory: true` placement ignores hide. `RecordingStudioDashboard::Preference` stores only the override keys that differ from the definition. `recording_studio_dashboard:migrations` creates `recording_studio_dashboard_preferences`.

`:user_created` uses the same override flags. Build the definition with `definition_from_layout` when the layout is persisted data. The layout names registered widget ids. Pass the header component at render time. The dummy `StudioBoard` is a Recording with `root: false` and `allowed_parent_types: ["Workspace"]`. Fixed and personalised dashboards stay in code.

## Dummy app

`test/dummy` is a host. Sign in at `/users/sign_in` with `admin@admin.com` / `Password`.

- `/` renders the fixed home dashboard.
- `/dashboards/carousel` reuses the recent-items widget as a Flatpack carousel.
- `/dashboards/expanded` hides the checklist, so the overview fills the row.
- `/dashboards/empty` drops hidden rows and shows a row-level empty message.
- `/dashboards/personalised` stores a hide override for the checklist.
- `/dashboards/restricted` denies the metric permission before `prepare`.
- `/studio_boards/:id` renders a user-created board from its layout.

Open port 3000 after the Cloud Agent setup in `.cursor/`. Dummy credentials use the shared RecordingStudio development master key.

## Tech stack

| Component | Version |
| --- | --- |
| Ruby | 3.3+ |
| Rails | 8.1+ |
| PostgreSQL | 16 |
| Tailwind CSS | 4 |
| RecordingStudio | 4.x (`~> 4.2` in the gemspec; dummy GitHub tag `v4.7.0`) |
| Accessible | dummy GitHub tag `v0.18.0` |
| Trashable | dummy GitHub tag `v0.11.0` (`require: false`) |
| Root Switchable | dummy GitHub tag `v0.9.0` |
| Flatpack | dummy GitHub tag `v0.1.315` |
| Devise | current dummy pin |

Capability mixins stay opt-in. Installing this gem does not enable a mixin on host types. The dummy Workspace enables Accessible on its own. Use `RecordingStudio::Hooks` and `RecordingStudio::Services::BaseService` from core. This gem does not copy those classes.

## Documentation

Architecture and the registration reference live in `docs/recording_studio_dashboard/ARCHITECTURE.md`.
