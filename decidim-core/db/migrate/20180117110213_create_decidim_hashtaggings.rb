# frozen_string_literal: true

class CreateDecidimHashtaggings < ActiveRecord::Migration[5.1]
  def self.up
    create_table :decidim_hashtaggings do |t|
      t.references :decidim_hashtag

      t.references :decidim_hashtaggable, polymorphic: true, index: { name: 'idx_hashtaggins_on_hashtaggable_type_and_hashtaggable_id' }

      t.string :context, limit: 128

      t.timestamps
    end

  end

  def self.down
    drop_table :decidim_hashtaggings
  end
end
