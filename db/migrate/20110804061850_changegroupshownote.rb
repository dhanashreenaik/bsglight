class Changegroupshownote < ActiveRecord::Migration
  def self.up
    change_column :groupshows, :note, :text
  end

  def self.down
  end
end
