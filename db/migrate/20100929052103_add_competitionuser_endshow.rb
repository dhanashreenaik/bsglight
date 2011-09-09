class AddCompetitionuserEndshow < ActiveRecord::Migration
  def self.up
	  add_column :competitions_users, :bsb_no, :string
	  
  end

  def self.down
  end
end
