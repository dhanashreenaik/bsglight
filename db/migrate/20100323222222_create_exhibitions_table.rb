class CreateExhibitionsTable < ActiveRecord::Migration

  def self.up
    create_table :artworks_exhibitions do |t|
			t.integer :artwork_id
			t.integer :exhibition_id
			t.integer :exhibitions_users
			t.integer :position
			t.timestamps
		end
		add_index :artworks_exhibitions, :artwork_id
		add_index :artworks_exhibitions, :exhibition_id

    create_table :exhibitions do |t|
      t.integer  :user_id
      t.string   :title,              :limit => 255, :null => false
      t.text     :description,        :null => false
			t.string   :state,             :limit => 15
      t.integer  :viewed_number,     :default => 0
      t.integer  :comments_number,   :default => 0
      t.integer  :rates_average,     :default => 0
			t.integer  :published,				 :default => false
			t.string   :source
      t.timestamps
    end
		add_index :exhibitions, :user_id
		NotificationFilter.create(:name => 'exhibition', :group => 'model')
  end

	create_table :exhibitions_users do |t|
		t.integer :user_id
		t.integer :exhibition_id
		t.datetime :invited_at
		t.string :state
		t.float :price
		t.timestamps
	end
	add_index :exhibitions_users, :user_id
	add_index :exhibitions_users, :exhibition_id

  def self.down
    drop_table :artworks_exhibitions
		drop_table :exhibitions
		drop_table :exhibitions_users
	end
	
end

