class Addgroupshoweditionameandnumber < ActiveRecord::Migration
  def self.up
    add_column :groupshowartworks, :editionname, :integer
    add_column :groupshowartworks, :editionumber, :integer
  end

  def self.down
    remove_column :groupshowartworks, :editionname
    remove_column :groupshowartworks, :editionumber
  end
end
