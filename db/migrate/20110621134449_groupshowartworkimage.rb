class Groupshowartworkimage < ActiveRecord::Migration
  def self.up
    add_column :groupshowartworks, :artworkurl_file_name,    :string
    add_column :groupshowartworks, :artworkurl_content_type, :string
    add_column :groupshowartworks, :artworkurl_file_size,    :integer
    add_column :groupshowartworks, :artworkurl_updated_at,   :datetime
  end

  def self.down
    remove_column :groupshowartworks, :artworkurl_file_name
    remove_column :groupshowartworks, :artworkurl_content_type
    remove_column :groupshowartworks, :artworkurl_file_size
    remove_column :groupshowartworks, :artworkurl_updated_at
  end
end
