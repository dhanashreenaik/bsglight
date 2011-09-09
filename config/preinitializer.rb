# Defining constants
# Defining the project name
PROJECT_NAME = 'blank'.freeze
# Containers Available to current setup
CONTAINERS = ['workspace','website','folder'].freeze
# Items available to the current setup
ITEMS = (['article', 'image', 'cms_file', 'video', 'audio', 'bookmark', 'newsletter', 'group', 'page']+
	['artwork', 'competition', 'exhibition', 'gallery', 'user_group']).freeze
# Variable defining the languages available for the application
LANGUAGES = ['en-US', 'fr-FR'].freeze
# Profiles for users
PROFILES = ['profile_contact', 'profile_artist'].freeze
# Variable defining the workspace types available for the application
WS_TYPES = ['closed', 'public', 'authorized', 'archived'].freeze
# Variable defining the right types for the application
RIGHT_TYPES = ['system', 'container'].freeze
# Variable defining the different state for the comments for the application
COMMENT_STATE = ['posted', 'validated', 'rejected'].freeze
# Variable defining the default comment status for the application
DEFAULT_COMMENT_STATE = 'validated'
# Variable defining the available layout for the application
LAYOUTS_AVAILABLE = ['gallery', 'application', 'app_fat_menu'].freeze
# # Variable defining the filtering attributes available for the application
SEARCH_FILTERS = ['created_at', 'comments_number', 'viewed_number', 'rates_average', 'title'].freeze
#
IMAGE_TYPES = ["image/jpeg", "image/pjpeg", "image/gif", "image/png", "image/x-png", "image/ico"].freeze
# Set the default Captcha images number
CAPTCHA_IMAGES_NUMBER = 10
# Variable to define number of newsletters to send per hour
NEWSLETTERS_PER_HOUR = 20
# Variable for website files
WEBSITE_FILES = "website_files"
WEBSITES_FOLDER = "#{RAILS_ROOT}/public/#{WEBSITE_FILES}/"
WEBSITE_TEMPLATES_FOLDER = "#{RAILS_ROOT}/public/website_templates".freeze
DEFAULT_WEBSITE_TEMPLATE = "#{WEBSITE_TEMPLATES_FOLDER}/default/default.html.erb".freeze