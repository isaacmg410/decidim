# frozen_string_literal: true

module Decidim
  module ContentRenderers
    autoload :BaseRenderer, "decidim/content_renderers/base_renderer"
    autoload :UserRenderer, "decidim/content_renderers/user_renderer"
    autoload :HashtagRenderer, "decidim/content_renderers/hashtag_renderer"
    autoload :HashtagTitleRenderer, "decidim/content_renderers/hashtag_title_renderer"
  end
end
