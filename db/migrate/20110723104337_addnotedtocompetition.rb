class Addnotedtocompetition < ActiveRecord::Migration
  def self.up
    add_column :competitions, :notes,    :text
  end

  def self.down
    remove_column :competitions, :notes
  end
end
