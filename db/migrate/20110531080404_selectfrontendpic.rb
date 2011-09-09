class Selectfrontendpic < ActiveRecord::Migration
  def self.up
     add_column :frontendpics, :selectpic, :boolean
  end

  def self.down
     remove_column :frontendpics, :selectpic, :boolean
  end
end
