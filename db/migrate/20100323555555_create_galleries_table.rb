class CreateGalleriesTable < ActiveRecord::Migration

  def self.up
		create_table :galleries do |t|
			t.integer	:user_id
      t.string   :title,              :limit => 255, :null => false
      t.text     :description,        :null => false
			t.integer  :price
			t.string   :state,             :limit => 15
      t.integer  :viewed_number,     :default => 0
      t.integer  :comments_number,   :default => 0
      t.integer  :rates_average,     :default => 0
			t.integer  :published,				 :default => false
			t.string   :source
      t.timestamps
		end
		NotificationFilter.create(:name => 'gallery', :group => 'model')
    add_index :galleries, :user_id
	end

  def self.down
		drop_table :galleries
	end
	
end

