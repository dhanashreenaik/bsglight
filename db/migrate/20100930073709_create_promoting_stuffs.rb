class CreatePromotingStuffs < ActiveRecord::Migration
  def self.up
    create_table :promoting_stuffs do |t|
       t.string  :title
       t.string  :description
       

      t.timestamps
    end
  end

  def self.down
    drop_table :pramoting_stuffs
  end
end
