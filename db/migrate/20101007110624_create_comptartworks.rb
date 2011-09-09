class CreateComptartworks < ActiveRecord::Migration
  def self.up
    create_table :comptartworks do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :comptartworks
  end
end
