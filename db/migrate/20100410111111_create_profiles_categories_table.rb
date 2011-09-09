class CreateProfilesCategoriesTable < ActiveRecord::Migration

  def self.up

		create_table :profiles_categories do |t|
			t.integer	 :profile_id
			t.string   :category_id
			t.state :string, :limit => 15
			t.timestamps
		end
		add_index :profiles_categories, :profile_id
		add_index :profiles_categories, :category_id

		create_table :categories do |t|
			t.string	 :name
			t.string   :state
			t.timestamps
		end

  end
	

  def self.down
		drop_table :profiles_categories
		drop_table :categories
	end
	
end

