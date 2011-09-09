class CreateFrommails < ActiveRecord::Migration
  def self.up
    create_table :frommails do |t|
      t.string  :frommail
      t.timestamps
    end
  end

  def self.down
    drop_table :frommails
  end
end
