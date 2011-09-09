class Alterqueudmail < ActiveRecord::Migration
  def self.up
	  add_column :queued_mails, :fromread, :boolean
	  rename_column :queued_mails , :read,:toread
  end

  def self.down
  end
end
