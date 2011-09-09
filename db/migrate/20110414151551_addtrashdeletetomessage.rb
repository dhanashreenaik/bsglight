class Addtrashdeletetomessage < ActiveRecord::Migration
  def self.up
   add_column :messages, :deletedmt, :boolean
  end

  def self.down
    remove_column :messages, :deletedmt
  end
end
