class Addflagtomsgcopy < ActiveRecord::Migration
  def self.up
     add_column :message_copies, :flag, :boolean
  end

  def self.down
     remove_column :message_copies, :flag, :boolean
  end
end

