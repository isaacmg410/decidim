# frozen_string_literal: true

class CreateDecidimHashtags < ActiveRecord::Migration[5.1]
  def self.up
    create_table :decidim_hashtags do |t|
      t.references :decidim_organization

      t.string :name
      t.integer :decidim_hashtaggings_count, default: 0

      t.timestamps
    end
    add_index :decidim_hashtags, :name, unique: true
  end

  def self.down
    drop_table :decidim_hashtags
  end
end
