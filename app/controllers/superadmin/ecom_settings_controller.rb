class Superadmin::EcomSettingsController < Admin::ApplicationController

	# Filter restricting the access to only superadministrator user
	before_filter :is_superadmin?

	def index
		@ecom_config_hash = BlankConfiguration::ConfigFile.open('ecom.yml').hash
	end

	def updating
    @ecom_config = BlankConfiguration::ConfigFile.open('ecom.yml')
		@ecom_config.save(params[:ecom_config])
		flash[:notice] = "Ecommerce Settings Updated"
    redirect_to superadmin_mailer_settings_path
  end


end
