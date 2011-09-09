class Addnotetoinvoice < ActiveRecord::Migration
  def self.up
     add_column :invoices, :note,    :string
  end

  def self.down
     remove_column :invoices, :note
  end
end
