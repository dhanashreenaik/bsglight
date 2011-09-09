class CreateProfiles < ActiveRecord::Migration
  def self.up
    create_table :profiles do |t|
			t.integer :user_id
      t.string   :salutation,          :limit => 5
      t.string   :first_name,           :limit => 50, :null => false
			t.string   :middle_name,				 :limit => 50
      t.string   :last_name,            :limit => 50, :null => false
      t.string   :gender,              :limit => 6
      t.date :birth_date
			t.string   :nationality,         :limit => 50
			t.boolean  :getting_newsletter,		:default => false
			t.string :state

			t.string :email_address,	:limit => 100
			t.string  :address,             :limit => 255
			t.string  :suburb,             :limit => 70
			t.string	:zip_code, :limit => 10
			t.string  :city, :limit => 50
			t.string  :country_state, :limit => 50
			t.string  :country, :limit => 50
      t.string   :phone_number,               :limit => 25
			t.string  :website,	:limit => 255
      t.text   :biography

      t.timestamps
    end
		add_index :profiles, :user_id

		create_table :profiles_containers do |t|
			t.integer :profile_id
			t.string :container_type
			t.integer :container_id
			t.timestamps
		end
  end

  def self.down
    drop_table :profiles
		drop_table :profiles_containers
  end
end
