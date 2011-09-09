class Profile < ActiveRecord::Base

	belongs_to :user
	has_many :profiles_containers, :dependent => :delete_all
	# Relation N-1 getting Workspace objects through the 'users_workspaces' table
  CONTAINERS.each do |container|
    has_many container.pluralize.to_sym, :source => :container, :through => :users_profiles, :source_type => container.classify.to_s, :class_name => container.classify.to_s
  end
	
	has_many :profiles_categories
	has_many :categories, :through => :profiles_categories

	# Relation N-1 with the polymorphic 'contacts_workspaces' table
  has_many :contacts_workspaces, :as => :contactable, :dependent => :destroy

	#acts_as_searchable :full_text_fields => [:firstname, :lastname], :conditionnal_attribute => []
  validates_uniqueness_of :email_address
  validates_presence_of :first_name, :last_name
  validates_presence_of :suburb
  validates_presence_of :zip_code
		
	# Validation of the format of these fields
  validates_format_of :first_name, :last_name, :with => /\A(#{ALPHA_AND_EXTENDED}|#{SPECIAL})+\Z/, :allow_blank => false

  validates_format_of       :address, :with => /\A(#{ALPHA_AND_EXTENDED}|#{SPECIAL}|#{NUM})+\Z/, :allow_blank => false
	#validates_not_format_of   :address, :with => /(#{SCRIPTING_TAGS})/, :allow_blank => true
  validates_length_of       :phone_number, :in => 7..20, :allow_blank => false
  validates_format_of       :phone_number, :with => /(#{PHONE})/, :allow_blank => true
  validates_format_of			:website, :with => /(#{URL})/, :allow_blank => true

	after_create :add_to_admin_contacts

	named_scope :superadmin_filtered, {
		:conditions => ["profiles.id > 1"]
	}

	named_scope :from_category, lambda{ |cat_id|
		{
			:select => "DISTINCT profiles.*",
			:joins => "LEFT JOIN profiles_categories ON profiles_categories.profile_id = profiles.id",
			:conditions => "profiles_categories.id = '#{cat_id}'"
		}
	}

	named_scope :with_conditions_on_user, lambda{ |*args|
		#raise args.inspect
		{ :select => "DISTINCT profiles.*", :joins => "LEFT JOIN users ON users.id = profiles.user_id" }.merge(args.first)
	}

	# Create Private worksapce for User on creation called 'Private space of user_login'
	def create_profile_workspace
		# Creation of the private workspace for the user
		ws = Workspace.new(:title => "Archive for #{self.full_name}",
      :description => "Archive for #{self.full_name}",
      :body => "Worksapce containing all the content linked to the contact #{self.full_name}",
      :creator_id => self.user_id,
      :available_items => get_configuration['sa_items'],
      :state => 'profile')
		# To assign the 'ws_admin' role to the user in his privte workspace
		ws.save(false)
		ws.profiles_containers.create(:profile_id => self.id)
	end

	def profile_workspace
		if c=ProfilesContainer.find(:first, :conditions => { :profile_id => self.id })
			return c.container
		else
			return nil
		end
	end

        def full_address_for_invoice
		 self.address.to_s + " " +self.country.to_s + " " +self.city.to_s
	end	
	def  full_name_for_invoice
	return self.first_name.to_s + " " + self.last_name.to_s 
	end
	def add_to_admin_contacts
		ws = User.find(:first, :conditions => { :system_role_id => Role.find_by_name('admin') }).private_workspace
		ContactsWorkspace.create(:workspace_id => ws.id, :contactable_id => self.id, :contactable_type => self.class.to_s)
		# 
		if self.user_id.nil?
			cat = Category.find(1) # TODO : how to be sure to always check the right one, need a :db_nae field or something
			ProfilesCategory.create(:profile_id => self.id, :category_id => cat.id)
		end
	end

	# User Full Name 'Lastname FirstName'
	def full_name(with_salutation=false)
		return (with_salutation && self.salutation ? self.salutation.to_s + " " : '')+ self.first_name.to_s + " " + self.last_name.to_s
  end

	def switch_workspace_to_user
		
	end
	
	def full_address(separator)
		res = [self.address, self.suburb, self.zip_code.to_s, self.city, self.state, self.country]
		return separator ? res.delete_if{ |e| e.nil? }.join(separator) : res
	end


#  [:address, :zip_code, :city, :country, :phone_number, :website, :biography].each do |m|
#		define_method m.to_s do
#			return self.specific_info ? self.specific_info[m] : nil
#		end
#	end
#
#	def specific_info= param
#		self.specific_info = param
#	end

end
