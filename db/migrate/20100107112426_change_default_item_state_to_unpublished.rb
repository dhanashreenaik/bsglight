class ChangeDefaultItemStateToUnpublished < ActiveRecord::Migration
  def self.up
    ITEMS.each do |item|
      add_column item.pluralize.to_sym, :published, :boolean, :default => false if table_exists?(item.pluralize.to_sym)
    end
  end

  def self.down
    ITEMS.each do |item|
      drop_column item.pluralize.to_sym if table_exists?(item.pluralize.to_sym)
    end
  end
end
