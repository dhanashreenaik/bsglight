class CreateLinks < ActiveRecord::Migration
  def self.up
    create_table :links do |t|
         t.string :link_name
         t.string :link_src
	 t.boolean :approve
	 t.integer :user_id
         
      t.timestamps
    end
  end

  def self.down
    drop_table :links
  end
end
