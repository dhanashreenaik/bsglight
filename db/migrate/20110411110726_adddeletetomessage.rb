class Adddeletetomessage < ActiveRecord::Migration
  def self.up
    add_column :messages, :deletedm, :boolean
  end

  def self.down
    remove_column :messages, :deletedm
  end
end
