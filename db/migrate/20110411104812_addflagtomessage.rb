class Addflagtomessage < ActiveRecord::Migration
  def self.up
     add_column :messages, :flag, :boolean
  end

  def self.down
    remove_column :messages, :flag
  end
end
