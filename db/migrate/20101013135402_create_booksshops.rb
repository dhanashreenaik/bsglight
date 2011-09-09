class CreateBooksshops < ActiveRecord::Migration
  def self.up
    create_table :booksshops do |t|
        t.text  :bookshopdetails
      t.timestamps
    end
  end

  def self.down
    drop_table :booksshops
  end
end
