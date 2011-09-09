class Addlabeltomsgcopy < ActiveRecord::Migration
  def self.up
    add_column :message_copies, :emaillabel_id, :integer
    add_column :message_copies, :labeled, :boolean
    
  end

  def self.down
    remove_column :message_copies, :emaillabel_id
  end
end
