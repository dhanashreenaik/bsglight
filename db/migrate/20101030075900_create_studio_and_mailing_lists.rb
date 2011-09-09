class CreateStudioAndMailingLists < ActiveRecord::Migration
  def self.up
    create_table :studio_and_mailing_lists do |t|
        t.string   :first_name,           :limit => 50, :null => false
        t.string   :last_name,            :limit => 50, :null => false
       	t.string :email_address,	:limit => 100
		t.string  :address,             :limit => 255
		t.string  :suburb,             :limit => 70
		t.string	:zip_code, :limit => 10
		t.string   :phone_number,               :limit => 25
		t.boolean :studio
		t.boolean :mailing_list
      t.timestamps
    end
  end

  def self.down
    drop_table :studio_and_mailing_lists
  end
end
