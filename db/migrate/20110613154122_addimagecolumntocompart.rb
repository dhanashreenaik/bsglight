class Addimagecolumntocompart < ActiveRecord::Migration
   def self.up
      add_column :artworks_competitions, :avatar_file_name,    :string
      add_column :artworks_competitions, :avatar_content_type, :string
      add_column :artworks_competitions, :avatar_file_size,    :integer
      add_column :artworks_competitions, :avatar_updated_at,   :datetime
    end

    def self.down
      remove_column :artworks_competitions, :avatar_file_name
      remove_column :artworks_competitions, :avatar_content_type
      remove_column :artworks_competitions, :avatar_file_size
      remove_column :artworks_competitions, :avatar_updated_at
    end
end
