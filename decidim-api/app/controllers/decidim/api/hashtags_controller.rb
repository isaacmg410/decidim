# frozen_string_literal: true

module Decidim
  module Api
    # This controller takes queries from an HTTP endpoint and sends them out to
    # the Schema to be executed, later returning the response as JSON.
    class HashtagsController < Api::ApplicationController
      skip_authorization_check

      def hashtags
        result = Hashtag.where(organization: current_organization).map{|h| { id: h.id, name: h.name}}
        render json: result
      end
    end
  end
end
