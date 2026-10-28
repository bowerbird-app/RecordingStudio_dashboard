# Dashboard architecture

A dashboard is an ordered list of rows. A row is an ordered list of widget placements. A placement names a registered widget type and carries that placement's span and config. The widget component owns the content inside the placement.

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

Flatpack draws cards, grids, carousels, empty states, and alerts. This gem decides which placements remain and how wide they are.

A row heading is the section title and an optional action. It does not render a subtitle. The title uses Flatpack section title spacing `:none`, and the row uses a small gap above the widget grid. The header, the heading, the section title, and the action use `.fp-on-backdrop` so page text follows a layout photo. The action is a small Flatpack default button. That class retints page text, not default button tokens, so the filled pill stays readable over the photo. The widget grid does not use the class, so cards and other widget text keep their own color.

## Render order

`Composer` follows this order.

1. Load the definition from the registry, or from `definition_from_layout`.
2. Read the trusted context and, when the policy stores preferences, the actor's override row.
3. Apply permitted overrides. Mandatory placements stay when hide is requested.
4. Skip a row whose `visible_if` is false. Children of that row are not prepared.
5. Skip a placement that fails `permission`, the widget type `visible_if`, or the placement `visible_if`. `prepare` does not run.
6. Call `prepare` once for each remaining placement.
7. Drop empty placements whose policy is `:hide`.
8. Drop a row that has no placements left and whose empty policy is `:hide`.
9. Assign effective spans, then render.

One widget error is logged and shown as an alert. The rest of the dashboard still renders.

## Single card

```ruby
RecordingStudioDashboard.register_widget :overview, component: OverviewComponent, default_span: 6

row :studio, title: "Your studio" do
  widget :overview, span: 6
end
```

`OverviewComponent` renders one card. The dashboard only supplies the column span. Card headings in the dummy widgets use Flatpack `SectionTitle` (`size: :md`, `spacing: :none`, `level: :h3`).

## Collection

```ruby
row :activity, title: "Recent activity" do
  widget :recent_items, span: 12, config: { limit: 10, display: :carousel, sort: :recent_activity }
end
```

`recent_items` is one placement. The component reads `config[:display]` and renders a Flatpack carousel or a grid of cards. Those cards are not widget registrations.

## Metric

```ruby
RecordingStudioDashboard.register_widget(
  :metric,
  component: MetricComponent,
  default_span: 6,
  options: %i[label value],
  empty: :message,
  empty_message: "No figure yet",
  permission: ->(context) { context.permit_metrics? }
)

row :stats, title: "Stats" do
  widget :metric, id: :downloads, span: 6, config: { label: "Downloads", value: 128 }
  widget :metric, id: :views, span: 6, config: { label: "Views", value: 0 }
end
```

`downloads` and `views` share the metric type and keep separate config. `value: 0` is content. A `nil` value is empty and shows the message. `permit_metrics?` runs before `prepare`.

## Two widgets in one row

```ruby
row :studio, title: "Your studio" do
  widget :overview, span: 6, mandatory: true
  widget :checklist, span: 6 do
    visible_if :onboarding_incomplete?
  end
end
```

The overview and the checklist are different types. Their components do not share a layout object.

## Conditional visibility

`visible_if :onboarding_incomplete?` calls that method on the context. A proc is called with the context. False removes the placement from the row.

A row `visible_if` that is false removes the row, its heading, and its action. Placements in that row are not prepared.

## Empty state

Placement and widget empty policies use the same names.

| Policy | Result |
| --- | --- |
| `:hide` | The placement is removed. A row with no placements left is removed too. |
| `:message` | Flatpack empty state, using the preparation message or the configured message. |
| `:placeholder` | Flatpack skeleton. |
| `:custom` | The configured component, with `context:`, `config:`, and `preparation:`. |

A row can set `empty: { policy: :message, message: "This section is waiting for content." }` so the heading remains after its widgets are empty.

## Expansion

`:expand` gives leftover columns to the widgets that remain. Earlier widgets receive the remainder first. Each span stays inside 1..12. `:preserve` leaves the configured spans in place. The default is `:expand`.

## Policies

| Policy | Stored overrides | Recording |
| --- | --- | --- |
| `:fixed` | Ignored. Preferences are not read. | None. |
| `:personalised` | Row order, placement order, hidden placements, spans, and added placements. | None. The definition stays in code. |
| `:user_created` | Same flags as personalised. | Optional. `definition_from_layout` reads a layout hash of registered widget ids. |

`Overrides#to_h` omits empty keys. A hide of one placement stores `{ "hidden_placements" => ["checklist"] }` and does not copy the default rows.

A custom `Policy` may turn individual flags on. `Policy.resolve` accepts `:fixed`, `:personalised`, `:user_created`, or a `Policy` instance.

## Widget contract

`register_widget` accepts `component`, `title`, `description`, `default_span`, `supported_spans`, `options`, `permission`, `visible_if`, `empty`, `empty_message`, and `empty_component`. A type `visible_if` applies to every placement of that widget.

Unknown `config` keys raise `ArgumentError` at registration time. A span outside `supported_spans` raises too.

`Preparation` states are `:content`, `:empty`, `:loading`, and `:error`. Not permitted and not applicable never become preparations. Those placements are omitted before `prepare`.
