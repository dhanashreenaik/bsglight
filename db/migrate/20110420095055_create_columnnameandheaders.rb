class CreateColumnnameandheaders < ActiveRecord::Migration
  def self.up
    create_table :columnnameandheaders do |t|
      t.string :column_header
      t.string :column_name
      t.string :idoffieldwithtablename
      t.timestamps
    end
  end

  def self.down
    drop_table :columnnameandheaders
  end

end

