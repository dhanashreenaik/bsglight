class Addcolumnsto < ActiveRecord::Migration
  def self.up
         add_column :messages, :deletefrom, :string
         add_column :messages, :deleteto, :string
         add_column :messages, :deletefromt, :string
         add_column :messages, :deletetot, :string
  end

  def self.down
         remove_column :messages, :deletefrom
         remove_column :messages, :deleteto
         remove_column :messages, :deletefromt
         remove_column :messages, :deletetot

  end
end

