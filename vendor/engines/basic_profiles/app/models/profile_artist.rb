require 'regexps'
require 'country_select'

# This class is managing the User object, used for authentication inside the Blank application.
# It is linked with the RestfulAuthenticatin plugin which is providing hte authentication system,
# the session management (with the Session object present).
#
class ProfileArtist < ActiveRecord::Base

	#has_one :user, :as => :profilable, :dependent => :destroy
	belongs_to :user
	
	acts_as_searchable :full_text_fields => [:firstname, :lastname],
					:conditionnal_attribute => []
#  has_attached_file :avatar,
#    :default_url => "/images/default_avatar.png",
#    :url =>  "/uploaded_files/user/:id/:style/:basename.:extension",
#    :path => ":rails_root/public/uploaded_files/user/:id/:style/:basename.:extension",
#    :styles => {
#    :thumb=> "100x200>"}
#  # Validation of the content type of the avatar file
#  validates_attachment_content_type :avatar, :content_type => ['image/jpeg','image/jpg', 'image/png', 'image/gif','image/bmp']
#  # Validation of the size of the avatar file
#	validates_attachment_size(:avatar, :less_than => 5.megabytes)

	validates_presence_of :firstname, :lastname
	# Validation of the format of these fields
  validates_format_of       :firstname, :lastname, :with => /\A(#{ALPHA_AND_EXTENDED}|#{SPECIAL})+\Z/, :allow_blank => true
  validates_length_of       :phone,  :mobile, :in => 7..20, :allow_blank => true
  validates_format_of       :phone,  :mobile, :with => PHONE, :allow_blank => true
  # Validation of fields not in format of
  validates_not_format_of   :biography, :with => /(#{SCRIPTING_TAGS})/, :allow_blank => true

  # User as people for newsletter subscription
  def to_person
#    return Person.new(:first_name => self.firstname, :last_name => self.lastname,
#      :primary_phone => self.phone, :mobile_phone => self.mobile,:city => self.address,
#      :country => self.nationality,:company => self.company,:job_title => self.activity,
#      :created_at => self.created_at,:updated_at => self.updated_at, :model_name => "User")
  end

  # User Full Name 'Lastname FirstName'
	def full_name
		return self.salutation.to_s + " " + self.lastname.to_s + " " + self.firstname.to_s
  end
  
  def full_name_without_salutation
    return self.lastname.to_s.capitalize + " " + self.firstname.to_s.capitalize
  end

	def email
		return self.user.email
	end

end

