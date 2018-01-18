# frozen_string_literal: true

module Decidim
  module HashtagsHelper
    def linkify_hashtags(hashtaggable_content)
      regex = Decidim::Hashtag::HASHTAG_REGEX
      hashtagged_content = hashtaggable_content.to_s.gsub(regex) do
        link_to($&, hashtag_path($2), {class: :hashtag})
      end
      hashtagged_content.html_safe
    end

    def render_hashtaggable(hashtaggable)
      klass        = hashtaggable.class.to_s.underscore
      view_dirname = klass.pluralize
      partial      = klass.split("/").last
      render "#{partial}", resource: hashtaggable
    end
  end
end
