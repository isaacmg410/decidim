# frozen_string_literal: true

module Decidim
  module Proposals
    class ViewModel < Decidim::ViewModel
      include Decidim::Proposals::ApplicationHelper
      include Decidim::Proposals::Engine.routes.url_helpers
      include Decidim::ActionAuthorization
      include Decidim::ActionAuthorizationHelper
    end
  end
end