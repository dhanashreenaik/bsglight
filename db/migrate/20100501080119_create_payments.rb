class CreatePayments < ActiveRecord::Migration
  def self.up
    create_table :payments do |t|
      t.integer  :user_id
			t.integer  :invoice_id
			t.integer  :credit_card_id
			t.string	:state
			t.string :note
			t.integer :amount_in_cents
			t.string :currency
#      t.string   :title,              :limit => 255, :null => false
#      t.text     :description,        :null => false
#			t.string   :state,             :limit => 15
#      t.integer  :viewed_number,     :default => 0
#      t.integer  :comments_number,   :default => 0
#      t.integer  :rates_average,     :default => 0
#			t.integer  :published,				 :default => false
#			t.string   :source
      t.timestamps
    end
		add_index :payments, :user_id
		NotificationFilter.create(:name => 'payments', :group => 'model')

		create_table :credit_cards do |t|
			t.integer :user_id
			t.string :type_of_card
			t.string :first_name
			t.string :last_name
			t.integer :number
			t.date :expiring_date
			t.integer :verification_value
			t.timestamps
		end
		add_index :credit_cards, :user_id

  end

  def self.down
    drop_table :payments
		drop_table :credit_cards
  end

end
