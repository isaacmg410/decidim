# frozen_string_literal: true

module Decidim
  module Meetings
    # The data store for a Meeting in the Decidim::Meetings component. It stores a
    # title, description and any other useful information to render a custom meeting.
    class AgendaItem < Meetings::ApplicationRecord
      # include Decidim::HasAttachments
      include Decidim::Traceable
      include Decidim::Loggable

      belongs_to :agenda, -> { order(:position) }, foreign_key: "decidim_agenda_id", class_name: "Decidim::Meetings::Agenda"

      default_scope { order(:position) }
      # validates :title, presence: true
      # validate  :description, presence: true

      def self.log_presenter_class_for(_log)
        Decidim::Meetings::AdminLog::AgendaItemPresenter
      end
    end
  end
end
