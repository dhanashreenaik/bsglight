class AddNewColumnSourceForAllItems < ActiveRecord::Migration
  def self.up
    ITEMS.each do |item| 
      add_column item.pluralize.to_sym, :source, :string, :default => 'form' if table_exists?(item.pluralize.to_sym)
    end
  end

  def self.down
    ITEMS.each do |item| 
      remove_column item.pluralize.to_sym, :source if table_exists?(item.pluralize.to_sym)
    end
  end
end
