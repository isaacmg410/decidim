# frozen_string_literal: true

module Decidim
  module Meetings
    module Admin
      # This class holds a Form to update meeting agenda items
      class MeetingAgendaItemForm < Decidim::Form
        include TranslatableAttributes


        translatable_attribute :title, String
        translatable_attribute :description, String

        attribute :duration, Decidim::Attributes::TimeWithZone
        attribute :parent_id, Integer
        attribute :position, Integer
        attribute :deleted, Boolean, default: false

        # validates :title, translatable_presence: true, unless: :deleted
        # validates :duration, presence: true, unless: :deleted
        # validates :position, numericality: { greater_than_or_equal_to: 0 }, unless: :deleted

        def to_param
          id || "agenda-item-id"
        end
      end
    end
  end
end
