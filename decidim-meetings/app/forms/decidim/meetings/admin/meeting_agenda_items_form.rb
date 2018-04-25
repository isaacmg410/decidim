# frozen_string_literal: true

module Decidim
  module Meetings
    module Admin
      # This class holds a Form to update meeting agenda items
      class MeetingAgendaItemsForm < Decidim::Form
        include TranslatableAttributes

        translatable_attribute :title, String
        translatable_attribute :description, String

        attribute :duration, Integer, default: 0
        attribute :parent_id, Integer
        attribute :position, Integer
        attribute :deleted, Boolean, default: false
        attribute :attachments, AttachmentForm

        validates :title, translatable_presence: true, unless: :deleted
        validates :position, numericality: { greater_than_or_equal_to: 0 }, unless: :deleted
        validates :duration, presence: true, numericality: { greater_than_or_equal_to: 0 }


        def to_param
          id || "meeting-agenda-item-id"
        end

      end
    end
  end
end
