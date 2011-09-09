class CreateAppHomes < ActiveRecord::Migration
  def self.up
    create_table :app_homes do |t|
         t.string  :houres
         t.text  :openings
         t.text :staff
         t.text :costs
         t.string :gallery_planlink
         t.text :bookings
         t.string :bsgproposallink
         t.text :opening_night
         t.string :staffed
         t.integer :mailing_list_number
         t.string :mailing_list_desc
         t.string :invitation
         t.text :advertising
         t.text :sales
         t.text :your_obligations
      t.timestamps
    end
  end

  def self.down
    drop_table :app_homes
  end
end
