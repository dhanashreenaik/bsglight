class Artworksoldnumber < ActiveRecord::Migration
  def self.up
    add_column :artworks, :sold_number, :integer          
  end

  def self.down
  end
end
