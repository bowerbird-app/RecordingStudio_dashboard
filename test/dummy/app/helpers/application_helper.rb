module ApplicationHelper
  def dummy_page_nav(title:, back_url: nil, back_label: "Home")
    # The default layout paints content_for(:title) as a second page heading.
    # These screens already render their heading, so title is intentionally unused here.
    flat_pack_page_nav(
      round: true,
      style: :default,
      back_href: back_url,
      back_tooltip: back_label,
      class: "fp-on-backdrop"
    )
    recording_studio_background_image(asset_path("dashboard-backdrop.svg"))

    recording_studio_page_nav_right do
      concat tag.div(class: "fp-on-backdrop flex items-center gap-2") {
        safe_join([
          recording_studio_root_switch_dropdown(style: :ghost, size: :md),
          render(
            FlatPack::Button::Component.new(
              text: "Sign out",
              style: :ghost,
              size: :md,
              href: main_app.destroy_user_session_path,
              data: { turbo_method: :delete }
            )
          )
        ])
      }
    end
  end
end
