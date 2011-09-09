class Changesubmissiondeadline < ActiveRecord::Migration
  def self.up
  change_column :competitions ,:submission_deadline,:date
  end

  def self.down
  end
end
