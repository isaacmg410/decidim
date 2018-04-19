# frozen_string_literal: true

class CreateDecidimAgendas < ActiveRecord::Migration[5.1]
  def change
    create_table :decidim_meetings_agendas do |t|
      t.jsonb :title
      t.references :decidim_meeting, null: false, index: true

      t.timestamps
    end
  end
end
