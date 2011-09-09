class Superadmin::GeneralSettingsController < Admin::ApplicationController

	# Filter restricting the access to only superadministrator user
	before_filter :is_superadmin?

	# Action managing the form presenting the general settings of the application
	#
	# Usage URL :
	# - GET  /admin/general_settings/editing
	def index
		@configuration_hash = BlankConfiguration::ConfigFile.open('sa_config.yml').hash
	end

	# Action updating the YAML config file with the params set in the previous form
	#
	# Usage URL :
	# - PUT /admin/general_settings/updating
	def updating
		@configuration = BlankConfiguration::ConfigFile.open('sa_config.yml')
		@configuration.save(params[:configuration])
		# Actions to do after
    if params[:apply_to_all_private_workspaces]
      Workspace.is_private.each do |ws|  
        ws.update_attributes(:available_items => @configuration['sa_config.yml'])
      end
    end
    if params[:apply_to_all_containers] == 'true'
      CONTAINERS.each do |container|
        container.classify.constantize.all.each do |c|
          c.update_attributes(:available_items => @configuration['sa_config.yml'])
        end
      end
    end
		flash[:notice] = "General settings updated"
    redirect_to superadmin_general_settings_path
	end


end
