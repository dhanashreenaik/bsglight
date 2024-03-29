  # == Schema Information
# Schema version: 20181126085723
#
# Table name: users
#
#  id                        :integer(4)      not null, primary key
#  login                     :string(40)
#  firstname                 :string(255)
#  lastname                  :string(255)
#  email                     :string(255)
#  address                   :string(500)
#  company                   :string(255)
#  phone                     :string(255)
#  mobile                    :string(255)
#  activity                  :string(255)
#  nationality               :string(255)
#  edito                     :text
#  avatar_file_name          :string(255)
#  avatar_content_type       :string(255)
#  avatar_file_size          :integer(4)
#  avatar_updated_at         :datetime
#  crypted_password          :string(40)
#  salt                      :string(40)
#  activation_code           :string(40)
#  activated_at              :datetime
#  password_reset_code       :string(40)
#  system_role_id            :integer(4)
#  created_at                :datetime
#  updated_at                :datetime
#  remember_token            :string(40)
#  remember_token_expires_at :datetime
#  newsletter                :boolean(1)
#  last_connected_at         :datetime
#  u_layout                  :string(255)
#  u_per_page                :integer(4)
#  u_language                :string(255)
#  date_of_birth             :date
#  gender                    :string(255)
#  salutation                :string(255)
#

require 'digest/sha1'
require 'regexps'

# This class is managing the User object, used for authentication inside the Blank application.
# It is linked with the RestfulAuthenticatin plugin which is providing hte authentication system,
# the session management (with the Session object present).
#
class User < ActiveRecord::Base

	# Libraries from RestfulAuthenticatin plugin
  include Authentication
  include Authentication::ByPassword
  include Authentication::ByCookieToken
	# Library provinding access to the Blank application configuration
	include BlankConfiguration
	has_one :profile, :dependent => :destroy
	#default_scope :include => [:profile]
	accepts_nested_attributes_for :profile, :reject_if => lambda { |a| a[:first_name].blank? && a[:last_name].blank? && a[:address].blank? && a[:zip_code].blank? && a[:phone_number].blank? && a[:suburb].blank? }, :allow_destroy => true
	# Relation N-1 with the 'users_workspaces' table
  has_many :users_containers, :dependent => :delete_all
	# Relation N-1 getting Workspace objects through the 'users_workspaces' table
  CONTAINERS.each do |container|
    has_many container.pluralize.to_sym, :source => :containerable, :through => :users_containers, :source_type => container.classify.to_s, :class_name => container.classify.to_s, :dependent => :delete_all,:foreign_key=>"creator_id"
  end
	# Relation N-1 with the 'rattings' table
  has_many :ratings
	# Relation N-1 with the 'comments' table
  has_many :comments
	# Relation N-1 getting the FeedItem objects through the 'feed_sources' table
  has_many :feed_items, :through => :feed_sources, :order => "last_updated DESC"
	# Relation N-1 with the polymorphic 'contacts_workspaces' table
  has_many :contacts_workspaces, :as => :contactable, :dependent => :delete_all
	# Relation N-1 with the 'people' table
  has_many :people, :order => 'email ASC', :dependent => :delete_all
	# Relation with notifications
  has_many :notification_subscriptions, :dependent => :delete_all
  has_many :notification_filters, :through => :notification_subscriptions

  has_many :groups , :dependent => :delete_all

  has_many :saved_searches, :dependent => :delete_all

	has_many :invoices, :foreign_key => 'client_id', :dependent => :delete_all
	has_many :exhibitions_users, :dependent => :delete_all
	has_many :exhibitions, :through => :exhibitions_users
	has_many :competitions_users, :dependent => :delete_all
	has_many :competitions, :through => :competitions_users
	has_many :competitions_subscriptions, :through => :competitions_users
  has_many :groupshowartworks
	has_many :user_groups_users, :dependent => :delete_all
	has_many :user_groups, :through => :user_groups_users
   has_many :orders, :foreign_key => 'client_id', :dependent => :delete_all
	# Mixin method use to get this object search (see Searchable:ModelMethods for more)
	acts_as_searchable :full_text_fields => [:login],
					:conditionnal_attribute => []
	# Mixin method including the methods used for roles and permissions checkings (see Authorized::ModelMethods for more)
	acts_as_authorized
	# Mixin method alloing to make easy search on the model (see Authorizable::ModelMethods for more)
	acts_as_authorizable
	
	#accepts_nested_attributes_for :basic_profile
  # Paperclip attachment definition for user avatar
  has_attached_file :avatar,
    :default_url => "/images/default_avatar.png",
    :url =>  "/uploaded_files/user/:id/:style/:basename.:extension",
    :path => ":rails_root/public/uploaded_files/user/:id/:style/:basename.:extension",
    :styles => {
    :thumb=> "100x100>"}
  # Validation of the content type of the avatar file
  validates_attachment_content_type :avatar, :content_type => ['image/jpeg','image/jpg', 'image/png', 'image/gif','image/bmp']
  # Validation of the size of the avatar file
	validates_attachment_size(:avatar, :less_than => 5.megabytes)

  # Validationof the presence of these attributes
  #validates_presence_of :login,:message=>"First Name Or Last Name Can't Be Blank"
  validates_presence_of      :email, :system_role_id,:message=>"Please Enter Email"
	validates_presence_of     :password, :on => :create,:message=>"Please Enter Password"
	validates_presence_of     :password_confirmation, :on => :create,:message=>"Please Enter Confirm Password"
	# Validation of the confirmation of this attribute
	validates_confirmation_of :password, :on => :create,:message=>"Please Enter Password And Confirm Password Correctly"
	# Validation of the uniqueness of these attributes
  validates_uniqueness_of   :login,     :case_sensitive => false, :on => :create,:message=>"First Name Or Last Name Is Already Taken"
	validates_uniqueness_of   :email,    :case_sensitive => false, :on => :create,:message=>"Email Is Already Taken"
	# Validation of the length of these attributes
  validates_length_of       :login,     :within => 3..40,:message=>"Enter Valid First Name Or Last Name"
	validates_length_of       :email,    :within => 6..40,:message=>"Email Is Too Short"
	# Validation of the format of these fields
  validates_format_of       :login,    :with => /\A[0-9A-Za-z_\.-]+\z/,:message=>"Please Enter Valid First Name Or Last Name"
	validates_format_of       :email,    :with => RE_EMAIL_OK,:message=>"Please Check The Format Of Email"

  # Encrypt the password before storing in the database
	before_save :encrypt_password
  # Create the activation code before creating the user for email activation
  before_create :make_activation_code
  after_create :make_activate_at
  # HACK HACK HACK -- how to do attr_accessible from here?
  # prevents a user from submitting a crafted form that bypasses activation
  # anything else you want your user to change should be added here.
  attr_accessible :login, :email, :password, :password_confirmation, :avatar, :system_role_id, :last_connected_at, :u_layout, :u_language, :u_per_page, :profile_attributes
		# will return all contacts of a user(people + subscribed users of current user's workspaces). If workspace passed return contacts(people and subscribed users) of given workspace
#  def get_contacts_list(workspace=nil)
#    contacts = []
#    if workspace
#      contacts = ContactsWorkspace.all(:all, :conditions =>["contactable_type ='Person' AND workspace_id=#{workspace.id}"],:group =>'contactable_id').map{|cw| cw.contactable}
#      contacts  += ContactsWorkspace.all(:all, :conditions =>["contactable_type ='User' AND workspace_id=#{workspace.id}"],:group =>'contactable_id').map{|cw| cw.contactable.to_person}
#    else
#      contacts = self.people
#      contacts  += ContactsWorkspace.all(:all, :conditions =>["contactable_type ='User' AND workspace_id IN (#{User.first.workspaces.all(:select => 'workspaces.id').map{|u| u.id}.join(',')})"],:group =>'contactable_id').map!{|cw| cw.contactable.to_person}
#    end
#    return contacts
#  end
	named_scope :superadmin_filtered, {
		:conditions => ["users.id > 1"]
	}


  has_many :sent_messages, :class_name => "Message", :foreign_key => "author_id"
  has_many :received_messages, :class_name => "MessageCopy", :foreign_key => "recipient_id"
  has_many :mailfolders
  before_create :build_inbox
  
  def inbox
    mailfolders.find_by_name("Inbox")
  end
  
  def build_inbox
    mailfolders.build(:name => "Inbox")
  end




	def all_containers
		res = []
		CONTAINERS.each do |cont|
			
			res << self.send(cont.pluralize.to_sym)
		end
		res = res
		return res
	end


	def make_activate_at
		self.activated_at = Time.now
		self.save
	end	

  # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
  #
  # uff.  this is really an authorization, not authentication routine.  
  # We really need a Dispatch Chain here or something.
  # This will also let us return a human error message.
  #
	def self.authenticate(login, password)
         u = find_by_login(login) # need to get the salt
         u && u.authenticated?(password) ? u : nil
       end
      
       def self.authenticate_by_email(email,password)
             u = find_by_email(email) # need to get the salt
             u && u.authenticated?(password) ? u : nil
       end       
 

  # Display Name of User(login)
	def display_name
    login
	end

  # Check if User Currently Online
	def currently_online
    true
	end 

  # Create Private worksapce for User on creation called 'Private space of user_login'
	def create_private_workspace_with_role(role)
		# Creation of the private workspace for the user
		ws = Workspace.new(:title => "#{self.profile.full_name} workspace",
      :description => "Workspace containing all the content created by the user #{self.login}",
      :body => "It is the first workspace for #{self.profile.full_name}, it is where all his content will always be stock.",
      :creator_id => self.id,
			# TODO custommm for gallery
      :available_items => (role=='admin') ? get_configuration['sa_items'] : ['artworks'],
      :state => 'private')
		# To assign the 'ws_admin' role to the user in his privte workspace
		ws.save(false)
		ws.users_containers.create(:user_id => self.id, :role_id => Role.find_by_name(role).id)
	end

	def accessing_public_containers_with_role(container_name, role_name)
		container_name.classify.constantize.find(:all, :conditions => { :state => 'public' }).each do |cont|
			UsersContainer.create(:user_id => self.id, :containerable_type => container_name, :containerable_id => cont.id, :role_id => Role.find(:first, :conditions => { :name => role_name }))
		end
	end

	def private_workspace
		
		return Workspace.find(:first, :conditions => { :creator_id => self.id, :state => 'private'})
	end

#  def self.subscribers_of(model_id,action_id)
#
#        self.find_by_sql("
#        select *
#        from users U
#        where id in (select NS.user_id
#                     from notification_subscriptions NS JOIN notification_filters NF ON NS.notification_filter_id = NF.id
#                     where NF.id = #{model_id})
#          AND id in (select NS2.user_id
#                     from notification_subscriptions NS2 JOIN notification_filters NF2 ON NS2.notification_filter_id = NF2.id
#                     where NF2.id = #{action_id}) ")
#
#  end

	# Activate the user in the database.
  def activate
    @activated = true
    self.activated_at = Time.now.utc
    self.activation_code = 'unlocked'
    save(false)
  end

	# Lock the user in the database
	def lock
		self.activated_at = nil
    self.activation_code = 'locked'
    save(false)
	end

	# Unlock the user in the database
	def unlock
		self.activated_at = Time.now
    self.activation_code = 'unlocked'
    save(false)
	end

  # Check if User is Active
  # 
  # the existence of an activation code means User has not Activated yet
  def active?
    activation_code.nil?
  end

  # Returns true if the user has just been activated.
  def pending?
    @activated
  end
  
  #	# Encrypts some data with the salt.
  #  def self.encrypt(password, salt)
  #    Digest::SHA1.hexdigest("--#{salt}--#{password}--")
  #  end
  #
  #  # Encrypts the password with the user salt
  #  def encrypt(password)
  #    self.class.encrypt(password, salt)
  #  end
  #
  #  def authenticated?(password)
  #    crypted_password == encrypt(password)
  #  end

  def remember_token?
    remember_token_expires_at && Time.now.utc < remember_token_expires_at
  end

  # These create and unset the fields required for remembering users between browser closes
  def remember_me
    remember_me_for 2.weeks
  end

  def remember_me_for(time)
    remember_me_until time.from_now.utc
  end

  def remember_me_until(time)
    self.remember_token_expires_at = time
    self.remember_token            = encrypt("#{email}--#{remember_token_expires_at}")
    save(false)
  end

  def forget_me
    self.remember_token_expires_at = nil
    self.remember_token            = nil
    save(false)
  end

	# To change password
	def recently_reset?
    @reset
  end

  def delete_reset_code
    self.password_reset_code = nil
    save(false)
  end

  def create_reset_code
    @reset = true
    self.password_reset_code = Digest::SHA1.hexdigest( Time.now.to_s.split(//).sort_by {rand}.join )
    save(false)
  end
  
  def is_private?(ws)
    self.private_workspace == ws
  end
  
  def container_ids(container)
    self.send(container.pluralize).collect{|c| c.id.to_s }
  end
  
  def get_items_of_type(item_type="articles")
    result = []
    self.workspaces.each{ |w| result << w.send(item_type) }
    return result.flatten.uniq
  end

	def auto_login
     chars = 'abcdefghjkmnpqrstuvwxyzABCDEFGHJKLMNPQRSTUVWXYZ23456789'
     extrachar = ''
     extrachar << chars[rand(chars.size)] 
     extrachar << chars[rand(chars.size)] 
     extrachar << chars[rand(chars.size)] 
		i = 0
		if self.profile && self.profile.first_name && self.profile.last_name
			until self.login
				check = "#{self.profile.first_name[0..i].downcase.underscore}.#{self.profile.last_name.downcase.underscore}"+extrachar
				if !User.exists?(:login => check)
					self.login = check
				end
				i = i+1
			end
		end
	end

	def auto_password
		self.password = Array.new(12){ (rand(122-97) + 97).chr }.join
		self.password_confirmation = self.password
	end

  protected
  # before filter
  def encrypt_password
    return if password.blank?
    self.salt = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{login}--") if new_record?
    self.crypted_password = encrypt(password)
  end

  def password_required?
    crypted_password.blank? || !password.blank?
  end

  def make_activation_code
    self.activation_code = Digest::SHA1.hexdigest( Time.now.to_s.split(//).sort_by {rand}.join )
  end








end


































