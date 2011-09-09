class Superadmin::MailingSettingsController < Admin::ApplicationController
  
  before_filter :is_superadmin?

  def index
    @mails_config_hash = BlankConfiguration::ConfigFile.open('mailing.yml').hash
  end

  def updating
    @mailer_config = BlankConfiguration::ConfigFile.open('mailing.yml')
    @mailer_config.save(params[:mailer_config])
		flash[:notice] = "Mailing Settings Updated"
    redirect_to superadmin_mailing_settings_path
  end


end
