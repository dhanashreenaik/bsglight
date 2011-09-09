class Addimagecroptocomp < ActiveRecord::Migration
  def self.up
    add_column :artworks_competitions, :artworkurl_file_name,    :string
    add_column :artworks_competitions, :artworkurl_content_type, :string
    add_column :artworks_competitions, :artworkurl_file_size,    :integer
    add_column :artworks_competitions, :artworkurl_updated_at,   :datetime
  end

  def self.down
    add_column :artworks_competitions, :artworkurl_file_name,    :string
    add_column :artworks_competitions, :artworkurl_content_type, :string
    add_column :artworks_competitions, :artworkurl_file_size,    :integer
    add_column :artworks_competitions, :artworkurl_updated_at,   :datetime
  end
end
