class Addcompetitionfield < ActiveRecord::Migration
  def self.up
    add_column :competitions, :openstatemsg,    :text
    add_column :competitions, :publishfinalmsg,    :text
  end

  def self.down
    add_column :competitions, :openstatemsg
    add_column :competitions, :publishfinalmsg
  end
end
