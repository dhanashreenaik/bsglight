class Addlink < ActiveRecord::Migration
  def self.up
	  add_column :promoting_stuffs, :link, :string
  end

  def self.down
  end
end
