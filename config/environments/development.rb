# Settings specified here will take precedence over those in config/environment.rb

# In the development environment your application's code is reloaded on
# every request.  This slows down response time but is perfect for development
# since you don't have to restart the webserver when you make code changes.

# This changement is BAD. Should be set at FALSE but generate an error on plugin reload
config.cache_classes = false

# Log error messages when you accidentally call methods on nil.
config.whiny_nils = true

# Show full error reports and disable caching
config.action_controller.consider_all_requests_local = false
config.action_view.debug_rjs                         = true
config.action_controller.perform_caching             = false
config.action_mailer.delivery_method = :smtp
# Don't care if the mailer can't send
config.action_mailer.raise_delivery_errors = true

begin
  require 'bullet'

  config.after_initialize do
    Bullet.enable = true 
    Bullet.alert = true
    Bullet.bullet_logger = true  
    Bullet.console = true
    Bullet.rails_logger = true
    Bullet.disable_browser_cache = true
  end
rescue
  logger.info "Bullet not loaded"
  p "Install Bullet Gem:- sudo gem install bullet"
end  

config.reload_plugins = true
ActiveSupport::Deprecation.silenced = true
#ActiveSupport::Dependencies.explicitly_unloadable_constants << "Admin"
#ActiveSupport::Dependencies.explicitly_unloadable_constants << "ActsAcItem"
#ActiveSupport::Dependencies.explicitly_unloadable_constants << "ActsAsContainer"

#ActiveSupport::Dependencies.load_once_paths.delete(File.expand_path(File.dirname(__FILE__))+'/lib')

ActionMailer::Base.smtp_settings = {
 :address => "smtp.gmail.com",
  :port => "587",
  :domain => "pragtech.co.in",
  :authentication => :plain,
  :user_name => "test@pragtech.co.in",
  :password => "test123",
  :enable_starttls_auto => true,
}
