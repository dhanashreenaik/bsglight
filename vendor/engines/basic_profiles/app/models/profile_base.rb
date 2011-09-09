require 'regexps'
require 'country_select'

# This class is managing the User object, used for authentication inside the Blank application.
# It is linked with the RestfulAuthenticatin plugin which is providing hte authentication system,
# the session management (with the Session object present).
#
class ProfileBase < ActiveRecord::Base

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
  validates_format_of :firstname, :lastname, :with => /\A(#{ALPHA_AND_EXTENDED}|#{SPECIAL})+\Z/, :allow_blank => true

  # User Full Name 'Lastname FirstName'
	def full_name(salutation=false)
		return ((salutation && self.salutation) ? self.salutation.to_s + " " : '') + self.lastname.to_s + " " + self.firstname.to_s
  end

end

