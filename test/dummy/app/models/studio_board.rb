# frozen_string_literal: true

class StudioBoard < ApplicationRecord
  recording_studio_recordable label: "Studio board", root: false, allowed_parent_types: ["Workspace"]
end
