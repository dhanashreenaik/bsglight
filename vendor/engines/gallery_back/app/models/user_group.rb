class UserGroup < ActiveRecord::Base

	acts_as_item

	has_many :user_groups_users, :dependent => :destroy
	has_many :users, :through => :user_groups_users

end
