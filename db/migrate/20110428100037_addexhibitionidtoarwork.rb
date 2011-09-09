class Addexhibitionidtoarwork < ActiveRecord::Migration
  def self.up
   add_column :artworks, :exhibition_id, :integer
  end

  def self.down
     remove_column :artworks, :exhibition_id, :integer
  end
end
