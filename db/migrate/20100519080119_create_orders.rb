class CreateOrders < ActiveRecord::Migration
  def self.up
    create_table :orders do |t|
      t.integer  :creator_id
			t.integer  :client_id
			t.string :number
			t.string  :title
			t.float :total_amount
			t.string   :state, :limit => 15
			t.datetime   :completed_at
      t.timestamps
    end
		add_index :orders, :client_id
		NotificationFilter.create(:name => 'order', :group => 'model')

		create_table :order_lines do |t|
			t.integer  :order_id
			t.string   :orderable_type
      t.integer  :orderable_id
			t.integer  :number
      t.timestamps
    end
		add_index :order_lines, :order_id

  end


  def self.down
    drop_table :orders
  end

end