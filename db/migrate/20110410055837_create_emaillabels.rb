class CreateEmaillabels < ActiveRecord::Migration
  def self.up
    create_table :emaillabels do |t|
      t.string :labelname
      t.timestamps
    end
  end

  def self.down
    drop_table :emaillabels
  end
end
