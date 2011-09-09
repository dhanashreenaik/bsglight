class Addsoldtogroupshow < ActiveRecord::Migration
  def self.up
    add_column :groupshowartworks, :sold, :boolean
  end

  def self.down
    remove_column :groupshowartworks, :sold, :boolean
  end
end
