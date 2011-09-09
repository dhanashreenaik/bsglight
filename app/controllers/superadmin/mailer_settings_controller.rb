class Superadmin::MailerSettingsController < Admin::ApplicationController
  
  before_filter :is_superadmin?

  def index
    @mailer_config_hash = BlankConfiguration::ConfigFile.open('action_mailer.yml').hash
    
  end

  def updating
    @mailer_config = BlankConfiguration::ConfigFile.open('action_mailer.yml')
    @mailer_config = @mailer_config.save(params[:mailer_config])
    ActionMailer::Base.smtp_settings = {
      :address => @mailer_config['sa_mailer_address'],
      :domain => @mailer_config['sa_mailer_domain'],
      :port => @mailer_config['sa_mailer_port'],
      :user_name => @mailer_config['sa_mailer_user_name'],
      :password => @mailer_config['sa_mailer_password'],
      :authentication => @mailer_config['sa_mailer_authentication'].to_sym,
			:enable_starttls_auto => @mailer_config['sa_mailer_enable_starttls_auto']
    }
		flash[:notice] = "Action Mailer Settings Updated"
    redirect_to superadmin_mailer_settings_path
  end


end
