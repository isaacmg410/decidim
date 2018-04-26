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
        validate :total_agenda_duration_lower_than_meeting_duration

        def map_model(model)
          self.agenda_items = model.agenda_items.first_class.map do |agenda_item|
            MeetingAgendaItemsForm.from_model(agenda_item)
          end
        end


        private

        def meeting
          @meeting ||= context[:meeting]
        end

        # def max_choices
        #   errors.add(:choices, :too_many) if selected_choices.size > question.max_choices
        # end
        #
        # def all_choices
        #   errors.add(:choices, :missing) if selected_choices.size != question.number_of_options
        # end
        #
        # def mandatory_label
        #   "*"
        # end
        #
        # def max_choices_label
        #   I18n.t("surveys.question.max_choices", scope: "decidim.surveys", n: question.max_choices)
        # end

        def total_agenda_duration_lower_than_meeting_duration
          puts "-----------------"
          puts "#{agenda_duration}"
          puts "-----------------"
          puts "#{meeting_duration}"
          errors.add(:agenda_duration, :too_many) if agenda_duration > meeting_duration

        end

        def agenda_duration
          duration = Decidim::Meetings::AgendaItem.where(agenda: self.id).sum(&:duration)
        end

        def meeting_duration
          start_time = meeting.start_time
          end_time = meeting.end_time

          duration = ((end_time - start_time)/ 1.minute).round
        end

      end
    end
  end
end
