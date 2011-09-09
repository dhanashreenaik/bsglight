class Changeusercompstreettoaddress < ActiveRecord::Migration
  def self.up
  rename_column :competitions_users , :street,:address
  end

  def self.down
  end
end
