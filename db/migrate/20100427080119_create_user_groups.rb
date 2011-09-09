class CreateUserGroups < ActiveRecord::Migration
  def self.up
    create_table :user_groups do |t|
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
		add_index :user_groups, :user_id
		NotificationFilter.create(:name => 'user_groups', :group => 'model')

		create_table :user_groups_users do |t|
			t.integer :user_group_id
			t.integer :user_id
			t.timestamps
		end

  end

  def self.down
    drop_table :user_groups
		drop_table :user_groups_users
  end

end
