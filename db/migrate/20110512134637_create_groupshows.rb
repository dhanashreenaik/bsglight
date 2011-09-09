class CreateGroupshows < ActiveRecord::Migration
  def self.up
    create_table :groupshows do |t|
      t.integer  :user_id
      t.string   :title,              :limit => 255, :null => false
      t.text     :description,        :null => false
      t.date     :starting_date      
      t.date     :ending_date   
      t.string   :note
      t.string   :gallery_id 
	    t.timestamps
    end
    add_index :groupshows, :user_id
  end

  def self.down
    drop_table :groupshows
  end
end
