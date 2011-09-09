class CreateTemporaryInbox < ActiveRecord::Migration
  def self.up
     create_table :tempraryinboxes do |t|
      t.string :fromemail
      t.string :subject
      t.text :body
      t.timestamps
    end
  end

  def self.down
  end
end
