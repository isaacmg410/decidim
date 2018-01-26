# frozen_string_literal: true

module Decidim
  # This concern contains the logic related to followable resources.
  module Hashtaggable
    extend ActiveSupport::Concern

    included do
      has_many :decidim_hashtaggings, as: :decidim_hashtaggable, dependent: :destroy, class_name: "Decidim::Hashtagging"
      has_many :decidim_hashtags, through: :decidim_hashtaggings, class_name: "Decidim::Hashtag"
      before_save :update_hashtags

      def hashtaggable_content
        self.class.hashtaggable_attributes
        content = ""
        self.class.hashtaggable_attribute_name.each do |field|
          if field.is_a?(Hash)
            I18n.available_locales.each do |locale|
              content += send(field)[locale.to_s] + " "
            end
          else
            content += send(field) + " "
          end
        end
        content.to_s
      end

      def update_hashtags
        self.decidim_hashtags = parsed_hashtags
      end

      def parsed_hashtags
        parsed_hashtags = []
        array_of_hashtags_as_string = scan_for_hashtags(hashtaggable_content)
        array_of_hashtags_as_string.each do |s|
          parsed_hashtags << Decidim::Hashtag.find_or_create_by(decidim_organization_id: organization.id, name: s[1])
        end
        parsed_hashtags
      end

      def scan_for_hashtags(content)
        match = content.scan(Decidim::Hashtag::HASHTAG_REGEX)
        match.uniq!
        match
      end
    end

    module ClassMethods
      attr_accessor :hashtaggable_attribute_name

      def hashtaggable_attributes(*name)
        self.hashtaggable_attribute_name ||= name || :body
      end
    end
  end
end
