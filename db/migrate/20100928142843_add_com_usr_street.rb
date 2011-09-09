class AddComUsrStreet < ActiveRecord::Migration
  def self.up
	    add_column :competitions_users, :street, :string
  end

  def self.down
  end
end
