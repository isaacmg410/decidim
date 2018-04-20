# frozen_string_literal: true

module Decidim
  module Meetings
    module Admin
      # This class holds a Form to update meeting agenda items
      class MeetingAgendaForm < Decidim::Form
        include TranslatableAttributes

        translatable_attribute :title, String
        attribute :agenda_items, Array[MeetingAgendaItemsForm]

        validates :title, translatable_presence: true

        def map_model(model)
          self.agenda_items = model.agenda_items.map do |agenda_item|
            #MeetingAgendaItemsForm.from_model(agenda_item)
            MeetingAgendaItemsForm.from_model(agenda_item)
          end
        end


        def number_of_agenda_items
          agenda_items.size
        end

      end
    end
  end
end
