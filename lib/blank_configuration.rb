# Configuration for Blank Application
# 
# Blank Application is configured through the SuperAdministration module accessible to the 'superadmin' user
# 
# Major Application Configurations can be set up using this module.
# 
# The settings are stored in a YAML file.
#
# Initially the /config/customs/default_config.yml file is loaded(default settings).
#
# After the Superadministrator has setup the Superadministration Module the configurations will be stored in the /config/customs/sa_config.yml file
#
# The setttings are accessed through the following methods in the Application
#
module BlankConfiguration
	class ConfigFile
		attr_accessor 'file_name', 'hash'
		def initialize(yaml_file_name)
			@file_name = yaml_file_name
			if File.exist?("#{RAILS_ROOT}/config/customs/#{yaml_file_name}")
				res = YAML.load_file("#{RAILS_ROOT}/config/customs/#{yaml_file_name}")
			else
				res = YAML.load_file("#{RAILS_ROOT}/config/defaults/default_#{yaml_file_name}")
			end
			@hash = res.extend Extentions::HashFeatures
		end
		def self.open(yaml_file_name)
			return self.new(yaml_file_name)
		end

		def save(new_config)
			self.hash = self.hash.merge!(new_config)
			new=File.new("#{RAILS_ROOT}/config/customs/#{self.file_name}", "w+")
			new.syswrite(self.hash.to_yaml)
			return YAML.load_file("#{RAILS_ROOT}/config/customs/#{self.file_name}")
		end

	end

  # Free User Creation
  #
  # Check setting to verify if User can register directly with the application
	def is_allowed_free_user_creation?
		return @configuration['sa_allowed_free_user_creation']=='true'
	end

  # Check if Automatic Private Workspace Creation is Allowed
	def is_given_private_workspace
		return @configuration['sa_automatic_private_workspace']=='true'
	end

  # Check if Email Activation for User is Mandatory
	def is_mandatory_user_activation?
		return @configuration['sa_mandatory_user_activation']=='true'
	end

  # Get Selected Items List
  # 
  # will return a array of string of available items
	def available_items_list
		return @configuration['sa_items']
	end

	def available_profiles
		return @configuration['sa_profiles']
	end

	def available_containers
		return @configuration['sa_containers']
	end

	def is_activated_search_part
		return false
	end

	def is_activated_comment_part
		return false
	end

	def is_activated_keyword_part
		return false
	end

	def is_activated_rating_part
		return false
	end

  # Get Available Languages
  #
  # will return a array of string of available languages if not empty array
	def available_languages
    return (@configuration['sa_languages'].nil? || @configuration['sa_languages'].empty?) ? [] : @configuration['sa_languages']
	end

	def get_configuration
		@configuration ||= BlankConfiguration::ConfigFile.open('sa_config.yml').hash
	end

  #will return a array of string of available layouts if not empty array
  def available_layouts
		return (@configuration['sa_layouts'].nil? || @configuration['sa_layouts'].empty?) ? [] : @configuration['sa_layouts']
	end

  # Set PerPage Values for Pagination(default 10)
	def get_per_page_value
    if current_user.u_per_page
      current_user.u_per_page
		elsif (res=@configuration['sa_per_page_default']).to_i > 0
			return res
		else
			return 10
		end
	end

	# Get the Item types available for FCKE
	def get_fcke_item_types
		return ['page', 'image', 'cms_file', 'video', 'audio', 'bookmark']
	end
  
end