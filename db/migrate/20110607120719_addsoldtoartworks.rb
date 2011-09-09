class Addsoldtoartworks < ActiveRecord::Migration
  def self.up
    add_column :artworks, :sold, :boolean
  end

  def self.down
    remove_column :artworks, :sold
  end
end
