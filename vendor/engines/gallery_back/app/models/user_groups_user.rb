class UserGroupsUser < ActiveRecord::Base

	belongs_to :user_group
	belongs_to :user
 
end
