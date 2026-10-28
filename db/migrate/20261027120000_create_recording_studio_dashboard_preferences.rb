# frozen_string_literal: true

class CreateRecordingStudioDashboardPreferences < ActiveRecord::Migration[8.1]
  def change
    create_preferences
    index_preferences
  end

  private

  def create_preferences
    create_table :recording_studio_dashboard_preferences, id: :uuid do |t|
      t.string :dashboard_key, null: false
      t.string :actor_type, null: false
      t.uuid :actor_id, null: false
      t.jsonb :overrides, null: false, default: {}
      t.timestamps
    end
  end

  def index_preferences
    add_index :recording_studio_dashboard_preferences,
              %i[dashboard_key actor_type actor_id],
              unique: true,
              name: "idx_rs_dashboard_prefs_on_owner"
  end
end
