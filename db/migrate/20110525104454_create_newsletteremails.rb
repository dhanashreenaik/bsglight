class CreateNewsletteremails < ActiveRecord::Migration
  def self.up
    create_table :newsletteremails do |t|
      t.integer  :user_id
      t.integer  :newsletter_id
      t.boolean  :emailsend
      t.timestamps
    end
  end

  def self.down
    drop_table :newsletteremails
  end
end

