# frozen_string_literal: true

module Decidim
  module Meetings
    module Admin
      # This class holds a Form to update meeting agenda items
      class MeetingAgendaForm < Decidim::Form
        include TranslatableAttributes

        translatable_attribute :title, String
        attribute :agenda_items, Array[MeetingAgendaItemForm]

        # validates :title, translatable_presence: true

        def map_model(model)
          self.agenda_items = model.agenda_items.map do |agenda_item|
            MeetingAgendaItemForm.from_model(agenda_item)
          end
        end

        def agenda_items_to_persist
          agenda_items.reject(&:deleted)
        end

      end
    end
  end
end
