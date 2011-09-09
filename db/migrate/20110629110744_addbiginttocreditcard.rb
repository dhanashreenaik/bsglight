class Addbiginttocreditcard < ActiveRecord::Migration
  def self.up
    change_column :credit_cards, :number, :bigint
  end

  def self.down
    change_column :credit_cards, :number, :integer
  end
end
