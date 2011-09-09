class Addvarificationcode < ActiveRecord::Migration
  def self.up
  add_column :competitions_users, :varification_code, :string
  end

  def self.down
  end
end
