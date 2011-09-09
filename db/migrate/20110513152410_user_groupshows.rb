class UserGroupshows < ActiveRecord::Migration
  def self.up
     create_table :usergroupshows do |t|
      t.integer  :user_id
      t.integer  :groupshow_id
      
      t.string  :state
     end
  end

  def self.down
  end
end
