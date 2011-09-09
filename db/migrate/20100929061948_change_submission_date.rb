class ChangeSubmissionDate < ActiveRecord::Migration
  def self.up
	  change_column(:competitions,:submission_deadline, :string)
  end

  def self.down
  end
end
