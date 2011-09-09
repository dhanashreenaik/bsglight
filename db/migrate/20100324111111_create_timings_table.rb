class CreateTimingsTable < ActiveRecord::Migration

  def self.up

		create_table :timings do |t|
			t.string	 :objectable_type
			t.integer	 :objectable_id
			t.string   :note
			t.integer :period_id
			t.date :starting_date
			t.date :ending_date
			t.time :starting_time
			t.time :ending_time
			t.string :places_id
			t.string  :state
			t.timestamps
		end

		create_table :timings_places do |t|
			t.string :objekt_type
			t.integer :objekt_id
			t.integer :timing_id
		end

  end

  def self.down
		drop_table :timings
		drop_table :timings_places
	end
	
end

