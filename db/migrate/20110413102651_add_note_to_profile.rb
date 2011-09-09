class AddNoteToProfile < ActiveRecord::Migration
  def self.up
  add_column :profiles, :notices, :string
  
  
  end

  def self.down
	remove_column :profiles, :notices
  end
end
