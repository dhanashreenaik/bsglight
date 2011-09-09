class Addreplayto < ActiveRecord::Migration
  def self.up
	     add_column :queued_mails, :replayto, :integer
   end

  def self.down
  end
  
end
