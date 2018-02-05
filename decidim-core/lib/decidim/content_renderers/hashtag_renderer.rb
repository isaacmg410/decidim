# frozen_string_literal: true

module Decidim
  module ContentRenderers
    # A renderer that searches Global IDs representing hashtags in content
    # and replaces it with a link to their detail page with the name.
    #
    # e.g. gid://<APP_NAME>/Decidim::Hashtag/1
    #
    # @see BaseRenderer Examples of how to use a content renderer
    class HashtagRenderer < BaseRenderer
      # Matches a global id representing a Decidim::User
      GLOBAL_ID_REGEX =/(gid:\/\/[\w-]*\/Decidim::Hashtag\/(\d+))/i

      # Replaces found Global IDs matching an existing hashtag with
      # a link to their detail page. The Global IDs representing an
      # invalid Decidim::Hashtag are replaced with an empty string.
      #
      # @return [String] the content ready to display (contains HTML)
      def render
        content.gsub(GLOBAL_ID_REGEX) do |hashtag_gid|
          begin
            hashtag = GlobalID::Locator.locate(hashtag_gid)
            Decidim::HashtagPresenter.new(hashtag).display_hashtag
          rescue ActiveRecord::RecordNotFound => _ex
            ""
          end
        end
      end
    end
  end
end
