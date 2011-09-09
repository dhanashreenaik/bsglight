class CreateGroupshowartworks < ActiveRecord::Migration
  def self.up
    create_table :groupshowartworks do |t|
      t.integer  :groupshow_id
      t.integer  :user_id
      t.string   :artworkurl
      t.string   :title
      t.string   :medium
      t.integer  :size1
      t.integer  :size2
      t.integer  :size3
      t.integer  :price
      
      t.timestamps
    end
  end

  def self.down
    drop_table :groupshowartworks
  end
end
