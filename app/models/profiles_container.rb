class ProfilesContainer < ActiveRecord::Base

	belongs_to :profile
	# Relation 1-N with the 'workspaces' table
	belongs_to :container, :polymorphic => true
	
	validates_presence_of :profile_id, :container_type, :container_id
	validates_uniqueness_of :profile_id, :scope => [:container_type, :container_id]

end
