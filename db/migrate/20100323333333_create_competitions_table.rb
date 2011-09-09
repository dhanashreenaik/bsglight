class CreateCompetitionsTable < ActiveRecord::Migration

  def self.up
    create_table :competitions do |t|
			t.integer  :user_id
			t.integer :timing_id
      t.string   :title,              :limit => 255, :null => false
      t.text     :description,        :null => false
			t.string :type
			t.date :submission_deadline
			t.integer :prizes_total_amount
			t.text :prizes_detail
			t.integer :judge_id
			t.string :commission
			t.string	:limit_size
			t.boolean :auction_activated
			t.text :message_for_subscribers
			t.string   :state,             :limit => 15
      t.integer  :viewed_number,     :default => 0
      t.integer  :comments_number,   :default => 0
      t.integer  :rates_average,     :default => 0
			t.integer  :published,				 :default => false
			t.string   :source
      t.timestamps
		end
		add_index :competitions, :user_id
		NotificationFilter.create(:name => 'competition', :group => 'model')

		create_table :competitions_users do |t|
			t.integer :user_id
			t.integer :competitions_subscription_id
			t.integer :competition_id
			t.string :state
			t.float :price
			t.timestamps
		end
		add_index :competitions_users, :user_id
		add_index :competitions_users, :competition_id
		# Too long index
		#add_index :competitions_subscriptions_users, :competitions_subscription_id

		create_table :competitions_subscriptions do |t|
			t.integer :competition_id
			t.integer :maximum_works_number
			t.string  :description
			t.float  :price
			t.timestamps
		end
		add_index :competitions_subscriptions, :competition_id

		create_table :artworks_competitions do |t|
			t.integer :artwork_id
			t.integer :competition_id
			t.string  :state
			t.integer :mark
			t.timestamps
		end
		add_index :artworks_competitions, :competition_id
		add_index :artworks_competitions, :artwork_id
		
  end

  def self.down
		drop_table :competitions
		drop_table :competitions_users
		drop_table :competitions_subscriptions
		drop_table :artworks_competitions
	end

end
