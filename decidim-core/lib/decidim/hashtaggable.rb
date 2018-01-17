# frozen_string_literal: true

module Decidim
  # This concern contains the logic related to followable resources.
  module Hashtaggable
    extend ActiveSupport::Concern

    included do
      has_many :hashtaggings, as: :hashtaggable,  dependent: :destroy, class_name: "Decidim::Hashtagging"
      has_many :base_hashtags, through: :hashtaggings, source: :hashtag, class_name: "Decidim::Hashtag"
    end
  end
end
