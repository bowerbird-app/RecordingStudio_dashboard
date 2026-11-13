# frozen_string_literal: true

RecordingStudioRootSwitchable.configure do |config|
  # The switcher resolves its actor before the host sets Current.actor.
  # Prefer the signed-in user so a leftover Current.actor cannot hide them.
  config.current_actor_resolver = lambda do |controller:|
    signed_in = controller.current_user if controller.respond_to?(:current_user)
    signed_in.presence || Current.actor
  end

  # Mounted switcher pages use the same shell as the rest of the dummy.
  # A symbol layout name is no longer accepted; the callable receives the controller.
  config.layout = lambda do |controller:|
    if controller.respond_to?(:devise_controller?) && controller.devise_controller?
      "application"
    else
      RecordingStudio::DEFAULT_LAYOUT
    end
  end

  config.after_switch_redirect = lambda do |controller:, return_to:, **|
    candidate_path = return_to.presence
    candidate_path = controller.main_app.root_path if candidate_path.blank?

    if internal_route?(candidate_path)
      candidate_path
    else
      controller.main_app.root_path
    end
  end

  config.scope :all_workspaces do |scope|
    scope.label = "All workspaces"
    scope.description = "Every workspace root in the dummy app."
    scope.available_roots = lambda do |actor: nil, **|
      next [] if actor.blank?

      Workspace.order(:name).filter_map do |workspace|
        recording = RecordingStudio::Recording.find_by(recordable: workspace)
        next unless RecordingStudio.root_recording?(recording)
        next unless RecordingStudioAccessible.authorized?(actor: actor, recording: recording, role: :view)

        recording
      end
    end
    scope.access_check = lambda do |actor: nil, recording: nil, **|
      actor.present? && recording.present? &&
        RecordingStudioAccessible.authorized?(actor: actor, recording: recording, role: :view)
    end

    scope.default_root = lambda do |roots:, **|
      roots.first
    end
  end
end

def internal_route?(path)
  routes = [
    Rails.application.routes,
    RecordingStudioRootSwitchable::Engine.routes
  ]

  routes.any? do |route_set|
    route_set.recognize_path(path, method: :get)
    true
  rescue StandardError
    false
  end
end
