class Artworkcompetitionsell < ActiveRecord::Migration
  def self.up
     add_column :artworks_competitions, :sold, :boolean
  end

  def self.down
    remove_column :artworks_competitions, :sold
  end
end
