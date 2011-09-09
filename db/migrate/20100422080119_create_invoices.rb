class CreateInvoices < ActiveRecord::Migration
  def self.up
    create_table :invoices do |t|
      t.integer  :creator_id
			t.integer  :client_id
			t.string :purchasable_type
			t.integer :purchasable_id
			t.string :number
      t.string   :title,              :limit => 255, :null => false
      t.text     :description,        :null => false
			t.string   :state,             :limit => 15
			t.string :payment_medium
			t.string :billing_address
			t.string :shipping_address
			t.date		:deadline
			t.float   :original_amount
			t.float		:final_amount
			t.datetime   :sent_at
			t.datetime   :validated_at
      t.timestamps
    end
		add_index :invoices, :client_id
		NotificationFilter.create(:name => 'invoice', :group => 'model')

  end


  def self.down
    drop_table :invoices
  end

end
