class Addapplication < ActiveRecord::Migration
  def self.up
    change_column :app_homes, :mailing_list_number, :text
  end

  def self.down
    
  end
end
