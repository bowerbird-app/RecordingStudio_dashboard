# frozen_string_literal: true

class CreateStudioBoards < ActiveRecord::Migration[8.1]
  def change
    create_table :studio_boards, id: :uuid do |t|
      t.string :name, null: false
      t.jsonb :layout, null: false, default: {}

      t.timestamps
    end
  end
end
