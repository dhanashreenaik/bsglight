class CreateExhiArtworks < ActiveRecord::Migration
  def self.up
    create_table :exhi_artworks do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :exhi_artworks
  end
end
