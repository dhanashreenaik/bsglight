class Addcompetitionconfirm < ActiveRecord::Migration
	
  def self.up
	  add_column :competitions_users, :confirm, :boolean	
  end

  def self.down
  end
  
end
