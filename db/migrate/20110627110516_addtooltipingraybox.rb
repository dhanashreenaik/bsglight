class Addtooltipingraybox < ActiveRecord::Migration
  def self.up
     add_column :artworks_competitions, :prize_detail,    :string
  end

  def self.down
     remove_column :artworks_competitions, :prize_detail
  end
end
