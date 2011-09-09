# This librairy will define methods allowing to control easily the authorization
# on action (controller part) and on object (model part).
#
module Authorizable

  module ControllerMethods

		# Mixin concept : The ClassMethods defined after are automatically inside the class/module
		# where you are including that module.
    def self.included(base)
      base.extend ClassMethods
    end
    
    module ClassMethods
			# This mixin method will : 
			# - set the action skipping the logging part
			# - define the method checking the permission depending of the action
			# - set this method as a before_filter
			def acts_as_authorizable(*args)
				options = args.extract_options!
				skip_before_filter :is_logged?, :only => options[:skip_logging_actions]
				before_filter :permission_checking
				skip_before_filter :permission_checking , :only => options[:skip_permission_actions]				
				define_method :permission_checking do
					
					if options[:actions_permissions_links][params[:action]]
						obj = params[:controller].split('/')[1].classify.constantize
						@current_object = ['new', 'create','validate'].include?(params[:action]) ? obj.new : obj.find(params[:id])
						#no_permission_redirection unless @current_user && @current_object.send("accepts_#{hash[params[:action]]}_for?".to_sym, @current_user)
						no_permission_redirection unless @current_user && @current_object.has_permission_for?(options[:actions_permissions_links][params[:action]], @current_user, current_container)
					else
					       return true
						# it is permissive
					#p "qqqqqqqqqqqqqqqqqqqqqqqddddddddddddddddd"	
						# you have to manage manually
					end
				end
				include Authorizable::ControllerMethods::InstanceMethods
      end
    end
    
    module InstanceMethods
    end
		
  end
end

module Authorizable
  module ModelMethods

		# Mixin concept
    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods

			def containers_checking(user, containers, permission)
				# Check if these workspace are matching the really authorized ones, and set 'nil for all' condition
#				container_ids ||= container.classify.constantize.allowed_to_user_with_permission(user, self.to_s.underscore + '_' + permission, container).find(:all, :select => "#{container.pluralize}.id, #{container.pluralize}.title").map{ |e| e.id }
#				container_ids = container_ids.map{|w_id| w_id.to_i} & container.classify.constantize.allowed_to_user_with_permission(user, self.to_s.underscore + '_' + permission, container).find(:all, :select => "#{container.pluralize}.id, #{container.pluralize}.title").map{ |e| e.id }
				containers ||= []
				containers_checked = []
				# as nil means all, but empty ?
				if containers.nil? || containers.empty?
					# checking for all the containers
					CONTAINERS.each do |container|
						containers_checked = containers_checked + container.classify.constantize.allowed_to_user_with_permission(user, permission).map{ |e| [e.class.to_s, e.id] }
					end
				else
					# recheck of client params for the given workspaces
					containers_checked = containers.delete_if{ |e| !user.has_container_permission(e.split('-').first, e.split('-').last, permission) }.map{ |e| [e.split('-').first, e.split('-').last] }
				end
				containers_final = {}
				containers_checked.each do |e|
					if containers_final.has_key?(e[0])
						containers_final[e[0]] << e[1]
					else
						containers_final.merge!({ e[0] => [e[1]] })
					end
				end
				return containers_final
			end
			
			# This mixin method will manage different inclusion regarding the type of the object calling it , so :
			# - define the scope useful to get objects list depending on permissions and workspaces
			# - include the specific instance methods allowing to check permission on an object instance
      def acts_as_authorizable
				include Authorizable::ModelMethods::InstanceMethods
				if ITEMS.include?(self.to_s.underscore)
					named_scope :matching_user_with_permission_in_containers, lambda { |user, permission, containers|
						containers_final = containers_checking(user, containers, self.to_s.underscore+'_'+permission)
						# So we can retrieve directly as the workspaces are checked, hihihi
						if user.has_system_permission(self.to_s.underscore, permission)
							{  }
              # So we can retrieve directly as the workspaces are checked, hihihi
						elsif !containers_final.empty?
							{ :select => "DISTINCT #{self.to_s.underscore.pluralize}.*",
								:joins => containers_final.map{ |cont, ids| "LEFT JOIN items_#{cont.underscore.pluralize} AS ic ON #{self.to_s.underscore.pluralize}.id = ic.itemable_id AND ic.itemable_type='#{self.to_s}'"}.join(' '),
								:conditions => containers_final.map{ |cont, ids| "ic.#{cont.underscore}_id IN (#{ids.join(',')})"}.join(' ')
							}
						else
              # In order to return nothing ...
							{ :conditions => "1=2" }
						end
          }
					include Authorizable::ModelMethods::ItemInstanceMethods
				elsif CONTAINERS.include?(self.to_s.underscore)
					named_scope :matching_user_with_permission_in_containers, lambda { |user, permission, containers|
						# Check if these workspace are matching the really authorized ones, and set 'nil for all' condition
#            container_ids ||= container.classify.constantize.allowed_to_user_with_permission(user, container + '_' + permission, container).find(:all, :select => "#{container.pluralize}.id, #{container.pluralize}.title").map{ |e| e.id }
#						container_ids = container_ids.map{|w_id| w_id.to_i} & container.classify.constantize.allowed_to_user_with_permission(user, container+ '_' + permission, container).all(:select => "#{container.pluralize}.id, #{container.pluralize}.title").map{ |e| e.id }
						containers_final = containers_checking(user, containers, permission)
						# In case of system permission
						if user.has_system_permission(self.to_s.underscore, permission)
							{  }
              # So we can retrieve directly as the workspaces are checked, hihihi
						elsif !containers_final[self.to_s.underscore].empty?
							{ 
                :conditions => "id IN (#{container_ids.join(',')})"
              }
						else
              # In order to return nothing ...
							{ :conditions => "1=2" }
						end
          }
					# Scope getting the workspaces authorized for an user with a specific permission
					named_scope :allowed_to_user_with_permission, lambda { |user, permission_name|
						raise 'User required' unless user
						raise 'Permission name' unless permission_name
						if user.has_system_role('admin')
							{ :order => "#{self.to_s.underscore.pluralize}.title ASC" }
						else
							{ :joins => "LEFT JOIN users_containers ON users_containers.containerable_id = #{self.to_s.underscore.pluralize}.id AND users_containers.containerable_type = '#{self.to_s}' AND users_containers.user_id = #{user.id.to_i} "+
									"LEFT JOIN permissions_roles ON permissions_roles.role_id = users_containers.role_id "+
									"LEFT JOIN permissions ON permissions_roles.permission_id = permissions.id",
								:conditions => "permissions.name = '#{permission_name.to_s}'" ,
								:select => "DISTINCT #{self.to_s.underscore.pluralize}.*",
								:order => "#{self.to_s.underscore.pluralize}.title ASC"
							}
						end
					}

					# Scope getting the workspaces authorized for an user with a specific role
					named_scope :allowed_to_user_with_container_role, lambda { |user, role_name|
						raise 'User required' unless user
						raise 'Role name' unless role_name
						{ :joins => "LEFT JOIN users_containers ON users_containers.containerable_id = #{self.to_s.underscore.pluralize}.id AND users_containers.containerable_type = '#{self.to_s.underscore.pluralize}' AND users_containers.user_id = #{user.id.to_i} "+
								"LEFT JOIN roles ON roles.id = users_containers.role_id",
							:conditions => "roles.name = '#{role_name.to_s}'" ,
							:select => "DISTINCT #{self.to_s.underscore.pluralize}.*",
							:order => "#{self.to_s.underscore.pluralize}.title ASC"
						}
					}
					include Authorizable::ModelMethods::ContainerInstanceMethods
				elsif ['user', 'profile'].include?(self.to_s.underscore)
					named_scope :matching_user_with_permission_in_containers, lambda { |user, permission, containers|
						# Check if these workspace are matching the really authorized ones, and set 'nil for all' condition
#						container_ids ||= container.classify.constantize.allowed_to_user_with_permission(user, self.to_s.underscore+'_'+permission, container).find(:all, :select => "#{container.pluralize}.id, #{container.pluralize}.title").map{ |e| e.id }
#						container_ids = container_ids & container.classify.constantize.allowed_to_user_with_permission(user, self.to_s.underscore+'_'+permission, container).find(:all, :select => "#{container.pluralize}.id, #{container.pluralize}.title").map{ |e| e.id }
						containers_final = containers_checking(user, containers, permission)
						# In case of system permission
						if user.has_system_permission(self.to_s.underscore, permission)
							{  }
              # So we can retrieve directly as the workspaces are checked, hihihi
						elsif containers_final.first
							{ :select => "DISTINCT #{self.to_s.underscore.pluralize}.*",
								:joins => containers_final.map{ |cont, ids| "LEFT JOIN items_#{cont.pluralize} ON #{self.to_s.underscore.pluralize}.id = items_#{cont.pluralize}.itemable_id AND items_#{cont.pluralize}.itemable_type='#{self.to_s}'"}.join(' '),
								:conditions => containers_final.map{ |cont, ids| "items_#{cont.pluralize}.#{cont}_id IN (#{ids.join(',')})"}.join(' ')
							}
						else
              # In order to return nothing ...
							{ :conditions => "1=2" }
						end
          }
					include Authorizable::ModelMethods::UserInstanceMethods
				end
			end
    end

    module InstanceMethods
			# Generic method called on an instance to check if the permission is matching or no
			def has_permission_for?(permission, user, container)
				return accepting_action(user, permission, container)
			end
		end
		
		module UserInstanceMethods
      def accepting_action(user, action, container, spe_cond=false, sys_cond=false, ws_cond=true)
                        
        # Special access
        if self.id && ['show','edit'].include?(action) || spe_cond
          return true
        end
        # System access
        if user.has_system_permission(self.class.to_s.underscore, action) || sys_cond
          return true
        end
        
        # Workspace access
        # The only permission linked to an user in a workspace is 'show'
        if (action == 'show')
					# TODO problem here, undefined method 'users'
          (container ? [container] : self.all_containers).each do |cont|
            if cont.users.include?(user)
		
              if user.has_container_permission(cont.class.to_s.underscore, cont.id, self.class.to_s.underscore+'_'+action) && ws_cond
                return true
              end
            end
          end
        end
        
        # Check if the user is the current_user
        if self.id == user.id
          return true
        end
				
        false
      end
		end

		module ContainerInstanceMethods
			def accepting_action(user, action, container, spe_cond=false, sys_cond=false, ws_cond=true)
				# Special access
				if user.has_system_role('superadmin') #|| (self.state == 'private' && self.creator_id == user.id)
					return true
				end
				# System access
				if user.has_system_permission(self.class.to_s.underscore, action)# || self.state == 'public'
					return true
				end
				# Workspace access
				# Not for new and index normally ...
				if self.users.include?(user)
					if user.has_container_permission(container.class.to_s.underscore, self.id, self.class.to_s.underscore+'_'+action) && ws_cond
						return true
					end
				end
				false
			end
		end

		module ItemInstanceMethods
			def get_sa_config
				if File.exist?("#{RAILS_ROOT}/config/customs/sa_config.yml")
					return YAML.load_file("#{RAILS_ROOT}/config/customs/sa_config.yml")
				else
					return YAML.load_file("#{RAILS_ROOT}/config/customs/default_config.yml")
				end
			end

			def accepting_action(user, action, container, active=true)
				model_name = self.class.to_s
				# Special stuff
				if !get_sa_config['sa_items'].include?(model_name.underscore) || !active
					return false
				end
        # System access
				if user.has_system_permission(model_name.underscore, action)
					return true
				end
        # Workspace access
				if container
					if container.available_items.to_s.split(',').include?(model_name.underscore)
						# Then with workspace full access
						if user.has_container_permission(container.class.to_s, container.id, model_name.underscore+'_'+action)
							return true
						end
					end
				else
					# TODO hot spots ... too bad to check all workspaces in case there are a lot ...
					contl = user.all_containers.flatten
					if !self.new_record?
						contl = contl & self.all_containers.flatten
					end
					contl.each do |cont|
						 
#						raise cont.inspect
						# First of all, to check if this workspace accpets these items
						if cont.available_items.to_s.split(',').include?(model_name.underscore)
							# Then with workspace full access
							if user.has_container_permission(cont.class.to_s, cont.id, model_name.underscore+'_'+action)
								return true
							end
						end # if item available in ws
					end
				end
				# go away
				false
			end
		end
		
  end
end
