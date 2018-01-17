# frozen_string_literal: true

module Decidim
  # A hasthag is used to categorize components
  class Hashtag < ApplicationRecord

    belongs_to :organization, dependent: :destroy, class_name: "Decidim::Organization"
    has_many :hashtaggings, dependent: :destroy, class_name: 'Decidim::Hashtagging'

    validates :name, presence: true
    validates :name, uniqueness: { scope: [:organization] }
    validates :name, length: { maximum: 255 }

    scope :most_used, ->(limit = 20) { order('hashtaggings_count desc').limit(limit) }
    scope :least_used, ->(limit = 20) { order('hashtaggings_count asc').limit(limit) }

  end
end
