# frozen_string_literal: true

module Decidim
  module ContentParsers
    # A parser that searches user mentions in content.
    #
    # A word starting with `#` will be considered as a possible hashtagging if
    # they only contains letters, numbers or underscores. If the `#` is
    # followed with an underscore, then it is not considered.
    #
    # @see BaseParser Examples of how to use a content parser
    class HashtagParser < BaseParser

      Metadata = Struct.new(:hashtags)

      # Replaces found hashtags matching a name of an existing
      # hashtag with a global id.
      #
      # @return [String] the content with the hashtags replaced by a global id

      def rewrite
        content.gsub(Decidim::Hashtag::HASHTAG_REGEX) do |match|
          if (hashtag = Decidim::Hashtag.find_or_create_by(organization: organization, name: Regexp.last_match[2]))
            Regexp.last_match[1] + hashtag.to_global_id.to_s
          else
            match
          end
        end
      end

      def metadata
        Metadata.new(
          Decidim::Hashtag.where(organization: organization, name: content.scan(Decidim::Hashtag::HASHTAG_REGEX).flatten)
        )
      end

      private

      def organization
        Thread.current[:organization]
      end
    end
  end
end
