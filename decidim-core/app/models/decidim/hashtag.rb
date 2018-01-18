# frozen_string_literal: true

module Decidim
  # A hasthag is used to categorize components
  class Hashtag < ApplicationRecord
    self.table_name = "decidim_hashtags"

    belongs_to :organization, foreign_key: "decidim_organization_id", class_name: "Decidim::Organization"
    has_many :decidim_hashtaggings, dependent: :destroy, foreign_key: "decidim_hashtag_id", class_name: 'Decidim::Hashtagging'

    validates :name, presence: true
    validates :name, uniqueness: { scope: [:decidim_organization_id] }

    # scope :most_used, ->(limit = 20) { order('hashtaggings_count desc').limit(limit) }
    # scope :least_used, ->(limit = 20) { order('hashtaggings_count asc').limit(limit) }

    # this is how Twitter does it:
    # https://github.com/twitter/twitter-text-rb/blob/master/lib/twitter-text/regex.rb
    HASHTAG_REGEX = /(?:\s|^)(#(?!(?:\d+|\w+?_|_\w+?)(?:\s|$))([a-z0-9\-_]+))/i

    # def self.find_by_organization_id_and_name(decidim_organization_id, name)
    #   Decidim::Hashtag.where(decidim_organization_id: decidim_organization_id).where("lower(name) =?", name.downcase).first
    # end
    #
    # def self.find_or_create_by_decidim_organization_id_and_name(decidim_organization_id, name, &block)
    #   puts "--------------- "
    #   puts "#{decidim_organization_id} "
    #   puts "#{name} "
    #   puts "--------------- "
    #   find_by_organization_id_and_name(decidim_organization_id, name) || create(decidim_organization_id: decidim_organization_id, name: name, &block)
    # end

    def name=(val)
      write_attribute(:name, val.downcase)
    end

    def name
      read_attribute(:name).downcase
    end

    def hashtaggables
      self.decidim_hashtaggings.includes(:decidim_hashtaggable).collect { |h| h.decidim_hashtaggable }
    end

    def hashtagged_types
      self.decidim_hashtaggings.pluck(:decidim_hashtaggable_type).uniq
    end

    def hashtagged_ids_by_types
      hashtagged_ids ||= {}
      self.hashtaggings.each do |h|
        hashtagged_ids[h.decidim_hashtaggable_type] ||= Array.new
        hashtagged_ids[h.decidim_hashtaggable_type] << h.decidim_hashtaggable_id
      end
      hashtagged_ids
    end

    def hashtagged_ids_for_type(type)
      hashtagged_ids_by_types[type]
    end

    def to_s
      name
    end
  end
end
