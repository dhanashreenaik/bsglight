class ShowUserTypeController < ApplicationController
	def index
		
		@role=Role.find(current_user.system_role_id)
	end	
end
