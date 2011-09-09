# This initializer is setting all the global variable of the Blank application.

# Loading the Configuration module
include BlankConfiguration

#ActiveRecord::Base.send(:include, CustomModelValidations)
include CustomModelValidations

load 'country_select.rb'

# INCLUDING LIBRAIRIES IN DA GOOD PLACE
# for authorization
load 'authorized.rb'
load 'authorizable.rb'
ActiveRecord::Base.send                   :include, Authorized::ModelMethods
ActionController::Base.send               :include, Authorizable::ControllerMethods
ActiveRecord::Base.send                   :include, Authorizable::ModelMethods
# for research
load 'searchable.rb'
ActiveRecord::Base.send                   :include, Searchable::ModelMethods
ActionController::Base.send               :include, Searchable::ControllerMethods

conf = BlankConfiguration::ConfigFile.open('sa_config.yml').hash
# Setting the locales files and the default language
if !conf['sa_default_language'].to_s.blank?
  I18n.default_locale = "#{conf['sa_default_language']}"
else
  I18n.default_locale = "en-US"
end
LOCALES_DIRECTORY = "#{RAILS_ROOT}/config/locales"
I18n.load_path += Dir[File.join(RAILS_ROOT, 'config', 'locales', '*.yml')]
# Variable used by ExceptionNotifier plugin
if conf['sa_exception_notifier_activated'] == 'true' && !conf['sa_application_name'].empty?
  APPLICATION_ADMINS = conf['sa_exception_followers_email']
  APPLICATION_NAME = conf['sa_application_name']
  ExceptionNotifier.exception_recipients = APPLICATION_ADMINS
  ExceptionNotifier.sender_address = 'admin@blank.com'
  ExceptionNotifier.email_prefix = APPLICATION_NAME
end

# Load action_mailer settings if they are already set
if File.exist?("#{RAILS_ROOT}/config/customs/action_mailer.yml")
  @mailer_config = YAML.load_file("#{RAILS_ROOT}/config/customs/action_mailer.yml")
  ActionMailer::Base.smtp_settings = {
    :address => @mailer_config['sa_mailer_address'],
    :domain => @mailer_config['sa_mailer_domain'],
    :port => @mailer_config['sa_mailer_port'],
    :user_name => @mailer_config['sa_mailer_user_name'],
    :password => @mailer_config['sa_mailer_password'],
    :authentication => (@mailer_config['sa_mailer_authentication'] && !@mailer_config['sa_mailer_authentication'].blank?) ? @mailer_config['sa_mailer_authentication'].to_sym : nil,
		:enable_starttls_auto => (@mailer_config['sa_mailer_enable_starttls_auto'] == '1')
  }
end
ActionMailer::Base.delivery_method = :smtp
ActionMailer::Base.perform_deliveries = true || (RAILS_ENV == 'production')
ActionMailer::Base.default_charset = "utf-8"
ActionMailer::Base.raise_delivery_errors = true || (RAILS_ENV == 'production')
ActionMailer::Base.template_root = "#{RAILS_ROOT}/app/views/admin"
ActionMailer::Base.default_url_options[:host] = RAILS_ENV == 'production' ? "localhost:3000" : "localhost:3000"


TRANSLATION_SITE = 'http://admin:secret@translator.thinkdry.com'
WEBSITE_TEMPLATES = Dir.new(WEBSITE_TEMPLATES_FOLDER).reject{|i| i.include?(".") }.freeze

#require 'fileutils'

#['image', 'audio', 'video', 'cmsfile', 'user', 'articlefile', 'workspaces', 'websites', 'folders'].each do |obj|
#  FileUtils.mkdir_p RAILS_ROOT + '/public/uploaded_files/'+ obj
#end

