class Addsoldtocompetitionartwork < ActiveRecord::Migration
  def self.up
    add_column :competitions_users, :fsold, :boolean
    add_column :competitions_users, :ssold, :boolean
    add_column :competitions_users, :tsold, :boolean
    add_column :competitions_users, :fosold, :boolean
    add_column :competitions_users, :fisold, :boolean
    add_column :competitions_users, :sisold, :boolean
    add_column :competitions_users, :sesold, :boolean
    add_column :competitions_users, :eisold, :boolean
    add_column :competitions_users, :nsold, :boolean
    add_column :competitions_users, :tesold, :boolean
  end

  def self.down
    remove_column :competitions_users, :fsold
    remove_column :competitions_users, :ssold
    remove_column :competitions_users, :tsold
    remove_column :competitions_users, :fosold
    remove_column :competitions_users, :fisold
    remove_column :competitions_users, :sisold
    remove_column :competitions_users, :sesold
    remove_column :competitions_users, :eisold
    remove_column :competitions_users, :nsold
    remove_column :competitions_users, :tesold
  end
end
