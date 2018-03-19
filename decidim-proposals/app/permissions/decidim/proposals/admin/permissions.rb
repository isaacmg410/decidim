# frozen_string_literal: true

module Decidim
  module Proposals
    module Admin
      class Permissions
        def self.allows?(user, action, context)
          new(user, action, context).allowed?
        end

        def initialize(user, action, context)
          @user = user
          @action = action
          @context = context
        end

        def allowed?
          # Stop checks if the user is not authorized to perform the
          # action for this space
          return false unless spaces_allows_user?

          # The public part needs to be implemented yet
          return false if action[:scope] != "admin"

          if create_action?
            # There's no special condition to create proposal notes, only
            # users with access to the admin section can do it.
            return true if action[:subject] == "proposal_note"

            # Proposals can only be created from the admin when the
            # corresponding setting is enabled.
            return true if action[:subject] == "proposal" && admin_creation_is_enabled?

            # Proposals can only be answered from the admin when the
            # corresponding setting is enabled.
            return true if action[:subject] == "proposal_answer" && admin_proposal_answering_is_enabled?
          end

          # Every user allowed by the space can update the category of the proposal
          return true if action[:subject] == "proposal_category" && action[:action] == "update"

          # Every user allowed by the space can import proposals from another_component
          return true if action[:subject] == "proposals" && action[:action] == "import"

          false
        end

        private

        attr_reader :user, :action, :context

        def spaces_allows_user?
          Decidim::ParticipatoryProcesses::Permissions.allows?(user, action, space)
        end

        def current_settings
          @current_settings ||= context.fetch(:current_settings, nil)
        end

        def component_settings
          @component_settings ||= context.fetch(:component_settings, nil)
        end

        def space
          @space ||= context.fetch(:current_component, nil)&.participatory_space
        end

        def admin_creation_is_enabled?
          current_settings.try(:creation_enabled?) &&
            component_settings.try(:official_proposals_enabled)
        end

        def admin_proposal_answering_is_enabled?
          current_settings.try(:proposal_answering_enabled) &&
            component_settings.try(:proposal_answering_enabled)
        end

        def create_action?
          action[:action] == "create"
        end
      end
    end
  end
end
