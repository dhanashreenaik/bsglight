class AddCompetition < ActiveRecord::Migration
  def self.up
	  add_column :competitions, :location, :string
	  add_column :competitions, :no_of_entry, :integer
	  add_column :competitions, :framing, :string
	  add_column :competitions, :entry_fees, :string
	  add_column :competitions, :format, :string
	  add_column :competitions, :delivery, :string
	  add_column :competitions, :collection, :string
	  add_column :competitions, :insurance, :string
	  add_column :competitions, :return_of_artwork, :text
	  
	  
  end

  def self.down
  end
end
