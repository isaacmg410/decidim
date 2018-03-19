# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module Proposals
    # Common logic to ordering resources
    module NeedsPermission
      extend ActiveSupport::Concern

      included do
        helper_method :allowed_to?

        def check_permission_to(action, subject)
          user_not_authorized unless allowed_to?(action, subject)
        end

        def allowed_to?(action, subject, extra_context = {})
          permission_klass.new(
            current_user,
            { scope: permission_scope, action: action.to_s, subject: subject.to_s },
            ability_context.merge(extra_context)
          ).allowed?
        end
      end
    end
  end
end
