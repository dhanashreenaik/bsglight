class CreateBottomlines < ActiveRecord::Migration
  def self.up
    create_table :bottomlines do |t|
      t.text :bottomline

      t.timestamps
    end
  end

  def self.down
    drop_table :bottomlines
  end
end
