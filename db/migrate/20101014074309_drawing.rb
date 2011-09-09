class Drawing < ActiveRecord::Migration
  def self.up
    create_table :drawings do |t|
        t.text  :drawingdetails
      t.timestamps
    end
  end

  def self.down
  end
end
