class AtEndWork < ActiveRecord::Migration
  def self.up
	   add_column :competitions_users, :at_end_work, :string
  end

  def self.down
  end
end
