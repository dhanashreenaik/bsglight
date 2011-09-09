class CreateFrontendpics < ActiveRecord::Migration
  def self.up
    create_table :frontendpics do |t|
         t.timestamps
    end
    add_column :frontendpics, :front_end_pics_file_name,    :string
       add_column :frontendpics, :front_end_pics_content_type, :string
       add_column :frontendpics, :front_end_pics_file_size,    :integer
       add_column :frontendpics, :front_end_pics_updated_at,   :datetime
  end

  def self.down
      remove_column :frontendpics, :front_end_pics_file_name
      remove_column :frontendpics, :front_end_pics_content_type
      remove_column :frontendpics, :front_end_pics_file_size
      remove_column :frontendpics, :front_end_pics_updated_at
  end
end
 
