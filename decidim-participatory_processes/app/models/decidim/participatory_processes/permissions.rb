# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    class Permissions
      def self.allows?(user, action, process = nil)
        new(user, action, process).allowed?
      end

      def initialize(user, action, process = nil)
        @user = user
        @action = action
        @process = process
      end

      def allowed?
        # this line could probably be moved to the `admin` engine
        # and make it call all participatory spaces Permissions classes
        # to check if any of them allowed the user to visit the admin
        return true if has_manageable_processes? && admin_read_dashboard_action?

        # org admins and space admins can do everything in the admin section
        return true if admin_user? && action[:scope] == "admin"

        # space collaborators can only read, nothing else
        return true if collaborator_user? && admin_read_action?

        return true if action[:scope] == "admin" && action[:subject] == "moderation" && can_manage_process?

        return true if action[:scope] == "public"
        false
      end

      private

      attr_reader :user, :process, :action

      # It's an admin user if it's an organization admin or is a space admin
      # for the current `process`.
      def admin_user?
        user.admin? || can_manage_process?(role: :admin)
      end

      # It's an admin user if it's an space collaborator for the current `process`.
      def collaborator_user?
        can_manage_process?(role: :collaborator)
      end

      # Checks if it has any manageable process, with any possible role.
      def has_manageable_processes?(role: :any)
        participatory_processes_with_role_privileges(role).any?
      end

      # Whether the user can manage the given process or not.
      def can_manage_process?(role: :any)
        participatory_processes_with_role_privileges(role).include? process
      end

      # Returns a collection of Participatory processes where the given user has the
      # specific role privilege.
      def participatory_processes_with_role_privileges(role)
        Decidim::ParticipatoryProcessesWithUserRole.for(user, role)
      end

      # Checks if the action is to read in the admin or not.
      def admin_read_action?
        action[:scope] == "admin" && action[:action] == "read"
      end

      # Checks if the action is to read the admin dashboard or not.
      def admin_read_dashboard_action?
        action == { scope: "admin", action: "read", subject: "dashboard" }
      end
    end
  end
end
