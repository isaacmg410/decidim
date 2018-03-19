# frozen_string_literal: true

module Decidim
  module Proposals
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
        return false if action[:scope] != "public"
        return false if action[:subject] != "proposal"

        return true if can_create_proposal?
        return true if can_edit_proposal?
        return true if can_withdraw_proposal?
        return true if action[:action] == "report"

        return true if can_endorse_proposal?
        return true if can_unendorse_proposal?

        return true if can_vote_proposal?
        return true if can_unvote_proposal?

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

      def component
        @component ||= context.fetch(:current_component, nil)
      end

      def space
        @space ||= component&.participatory_space
      end

      def proposal
        @proposal ||= context.fetch(:proposal, nil)
      end

      def authorized?(action)
        return unless component

        ActionAuthorizer.new(user, component, action).authorize.ok?
      end

      def voting_enabled?
        return unless current_settings
        current_settings.votes_enabled? && !current_settings.votes_blocked?
      end

      def vote_limit_enabled?
        return unless component_settings
        component_settings.vote_limit.present? && component_settings.vote_limit.positive?
      end

      def remaining_votes
        return 1 unless vote_limit_enabled?

        proposals = Proposal.where(component: component)
        votes_count = ProposalVote.where(author: user, proposal: proposals).size
        component_settings.vote_limit - votes_count
      end

      def can_create_proposal?
        action[:action] == "create" &&
          authorized?(:create) &&
          current_settings&.creation_enabled?
      end

      def can_edit_proposal?
        action[:action] == "edit" &&
          proposal &&
          proposal.editable_by?(user)
      end

      def can_withdraw_proposal?
        action[:action] == "withdraw" &&
          proposal &&
          proposal.author == user
      end

      def can_endorse_proposal?
        action[:action] == "endorse" &&
          proposal &&
          authorized?(:endorse) &&
          current_settings&.endorsements_enabled? &&
          !current_settings&.endorsements_blocked?
      end

      def can_unendorse_proposal?
        action[:action] == "unendorse" &&
          proposal &&
          authorized?(:endorse) &&
          current_settings&.endorsements_enabled?
      end

      def can_vote_proposal?
        action[:action] == "vote" &&
          proposal &&
          authorized?(:vote) &&
          voting_enabled? &&
          remaining_votes.positive?
      end

      def can_unvote_proposal?
        action[:action] == "unvote" &&
          proposal &&
          authorized?(:vote) &&
          voting_enabled?
      end
    end
  end
end
