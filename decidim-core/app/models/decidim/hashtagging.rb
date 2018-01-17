# frozen_string_literal: true

module Decidim
  class Hashtagging < ApplicationRecord
    DEFAULT_CONTEXT = 'hashtags'

    belongs_to :hashtag, class_name: 'Decidim::Hashtag', counter_cache: "decidim_hashtaggings_count"
    belongs_to :hashtaggable, polymorphic: true

    scope :by_contexts, ->(contexts) { where(context: (contexts || DEFAULT_CONTEXT)) }
    scope :by_context, ->(context = DEFAULT_CONTEXT) { by_contexts(context.to_s) }

    validates :context, :hashtag_id, presence: true
    
  end
end
