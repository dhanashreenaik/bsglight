class Addexhibitiondate < ActiveRecord::Migration
  def self.up
	    add_column :competitions, :exhibition_date, :string
  end

  def self.down
  end
end
