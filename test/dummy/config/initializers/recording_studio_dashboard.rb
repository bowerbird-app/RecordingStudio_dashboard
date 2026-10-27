# frozen_string_literal: true

Dir[Rails.root.join("app/components/demo/**/*.rb")].each { |file| require file }

RecordingStudioDashboard.register_widget(
  :overview,
  component: Demo::OverviewComponent,
  title: "Studio overview",
  default_span: 6
)

RecordingStudioDashboard.register_widget(
  :checklist,
  component: Demo::ChecklistComponent,
  title: "Getting started",
  default_span: 6
)

RecordingStudioDashboard.register_widget(
  :recent_items,
  component: Demo::RecentItemsComponent,
  title: "Recent items",
  default_span: 12,
  options: %i[limit display source],
  empty: :message,
  empty_message: "No recent items yet"
)

RecordingStudioDashboard.register_widget(
  :metric,
  component: Demo::MetricComponent,
  title: "Metric",
  default_span: 6,
  options: %i[label value],
  empty: :message,
  empty_message: "No figure yet",
  permission: ->(context) { context.permit_metrics? }
)

RecordingStudioDashboard.register(:home) do
  header component: Demo::GreetingComponent

  row :studio, title: "Your studio", description: "Two different widgets share this row." do
    widget :overview, span: 6, mandatory: true
    widget :checklist, span: 6 do
      visible_if :onboarding_incomplete?
    end
  end

  row :activity, title: "Recent activity", description: "One widget owns every card inside it.",
      action: { label: "View all", url: "/dashboards/carousel" }, visible_if: :show_activity? do
    widget :recent_items, span: 12, config: { limit: 3, display: :grid }
  end

  row :stats, title: "Statistics" do
    widget :metric, id: :downloads, span: 6, config: { label: "Downloads", value: 128 }
    widget :metric, id: :views, span: 6, config: { label: "Views", value: 960 }
  end
end

RecordingStudioDashboard.register(:carousel) do
  header component: Demo::GreetingComponent

  row :activity, title: "Recent activity", description: "The same widget type, configured as a carousel." do
    widget :recent_items, span: 12, config: { limit: 4, display: :carousel }
  end

  row :stats, title: "Statistics" do
    widget :metric, id: :carousel_downloads, span: 6, config: { label: "Downloads", value: 128 }
    widget :metric, id: :carousel_views, span: 6, config: { label: "Views", value: 0 }
  end
end

RecordingStudioDashboard.register(:empty) do
  header component: Demo::GreetingComponent

  row :gone, title: "Seasonal notes", visible_if: :never? do
    widget :overview, id: :seasonal_overview, span: 12
  end

  row :cleared, title: "Cleared row" do
    widget :checklist, id: :hidden_checklist, visible_if: :never?
  end

  row :vacant, title: "Needs content", empty: { policy: :message, message: "This section is waiting for content." } do
    widget :recent_items, id: :empty_items, span: 12, config: { limit: 3, display: :grid, source: "empty" }
  end
end

RecordingStudioDashboard.register(:personalised, policy: :personalised) do
  header component: Demo::GreetingComponent

  row :studio, title: "Your studio" do
    widget :overview, span: 6, mandatory: true
    widget :checklist, span: 6 do
      visible_if :onboarding_incomplete?
    end
  end

  row :activity, title: "Recent activity" do
    widget :recent_items, id: :personal_items, span: 12, config: { limit: 3, display: :grid }
  end

  row :stats, title: "Statistics" do
    widget :metric, id: :personal_downloads, span: 6, config: { label: "Downloads", value: 128 }
    widget :metric, id: :personal_views, span: 6, config: { label: "Views", value: 960 }
  end
end
