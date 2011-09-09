class Changeentryfee < ActiveRecord::Migration
  def self.up
	  change_column :competitions , :entry_fees,:text
  end

  def self.down
  end
end
