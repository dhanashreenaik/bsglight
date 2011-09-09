class CreateSignatures < ActiveRecord::Migration
  def self.up
    create_table :signatures do |t|
      t.integer :frommail_id
      t.string :signlabel
      t.string :signature
      t.timestamps
    end
  end

  def self.down
    drop_table :signatures
  end
end
