class AddCompetitionUser < ActiveRecord::Migration
  def self.up
	    add_column :competitions_users, :name, :string
	    add_column :competitions_users, :email, :string
	    add_column :competitions_users, :suburb, :string
	    add_column :competitions_users, :post_code, :integer
	    add_column :competitions_users, :here_prize, :string
	    add_column :competitions_users, :others, :string
	    add_column :competitions_users, :total_entry, :string
	    add_column :competitions_users, :payment_type, :string
	    add_column :competitions_users, :card_name, :string
	    add_column :competitions_users, :card_number, :string
	    add_column :competitions_users, :exp_date, :string
	    add_column :competitions_users, :biography, :text
	    add_column :competitions_users, :return_of_artwork, :string
	    add_column :competitions_users, :bank_account, :string
	    
	    
	    
	    
	    add_column :competitions_users, :fworktitle, :string
	    add_column :competitions_users, :fworkmedium, :string
	    add_column :competitions_users, :fworksize, :string
	    add_column :competitions_users, :fworkprice, :string
	    add_column :competitions_users, :fworkimage, :string
	    
	    add_column :competitions_users, :sworktitle, :string
	    add_column :competitions_users, :sworkmedium, :string
	    add_column :competitions_users, :sworksize, :string
	    add_column :competitions_users, :sworkprice, :string
	    add_column :competitions_users, :sworkimage, :string
	    
	    add_column :competitions_users, :tworktitle, :string
	    add_column :competitions_users, :tworkmedium, :string
	    add_column :competitions_users, :tworksize, :string
	    add_column :competitions_users, :tworkprice, :string
	    add_column :competitions_users, :tworkimage, :string
	    
	    
	    add_column :competitions_users, :foworktitle, :string
	    add_column :competitions_users, :foworkmedium, :string
	    add_column :competitions_users, :foworksize, :string
	    add_column :competitions_users, :foworkprice, :string
	    add_column :competitions_users, :foworkimage, :string
	    
	    
	    add_column :competitions_users, :fiworktitle, :string
	    add_column :competitions_users, :fiworkmedium, :string
	    add_column :competitions_users, :fiworksize, :string
	    add_column :competitions_users, :fiworkprice, :string
	    add_column :competitions_users, :fiworkimage, :string
	    
	    
	    add_column :competitions_users, :siworktitle, :string
	    add_column :competitions_users, :siworkmedium, :string
	    add_column :competitions_users, :siworksize, :string
	    add_column :competitions_users, :siworkprice, :string
	    add_column :competitions_users, :siworkimage, :string
	    
	    
	    
	    add_column :competitions_users, :seworktitle, :string
	    add_column :competitions_users, :seworkmedium, :string
	    add_column :competitions_users, :seworksize, :string
	    add_column :competitions_users, :seworkprice, :string
	    add_column :competitions_users, :seworkimage, :string
	    
	    
	    add_column :competitions_users, :eworktitle, :string
	    add_column :competitions_users, :eworkmedium, :string
	    add_column :competitions_users, :eworksize, :string
	    add_column :competitions_users, :eworkprice, :string
	    add_column :competitions_users, :eworkimage, :string
	    
	    
	    add_column :competitions_users, :nworktitle, :string
	    add_column :competitions_users, :nworkmedium, :string
	    add_column :competitions_users, :nworksize, :string
	    add_column :competitions_users, :nworkprice, :string
	    add_column :competitions_users, :nworkimage, :string
	    
	    
	    add_column :competitions_users, :teworktitle, :string
	    add_column :competitions_users, :teworkmedium, :string
	    add_column :competitions_users, :teworksize, :string
	    add_column :competitions_users, :teworkprice, :string
	    add_column :competitions_users, :teworkimage, :string
	    
	    
	    
	    
  end

  def self.down
  end
end
