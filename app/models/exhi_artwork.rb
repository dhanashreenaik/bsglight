class ExhiArtwork < ActiveRecord::Base
  set_table_name "artworks"
  has_many :artworks_exhibitions
	has_many :exhibitions, :through => :artworks_exhibitions
	has_many :artworks_competitions
	has_many :exhibitions, :through => :artworks_competitions

  # Paperclip attachment definition
  has_attached_file :image,
                    :url =>    "/uploaded_files/#{RAILS_ENV}/artwork/:id/:style/:basename.:extension",
                    :path => ":rails_root/public/uploaded_files/#{RAILS_ENV}/artwork/:id/:style/:basename.:extension",
                    :styles => { :medium => "400x400", :thumb => "48x48" }
  # Validation of the presence of an attached file
  validates_attachment_presence :image
	# Validation of the type of the attached file
  validates_attachment_content_type :image,
                                    :content_type => ['image/jpeg','image/jpg', 'image/png', 'image/gif','image/bmp', 'image/x-png', 'image/pjpeg']
	# Validation of the size of the attached file
  validates_attachment_size :image, :less_than => 6.megabytes, :message => 'The image is too big (max. 6 Mb).'

	validates_numericality_of :width, :depth, :height, :greater_than => 0, :allow_nil => true

#	named_scope :from_workspace, lambda { |workspace_id|
#		{
#			:joins => "LEFT JOIN items_workspaces ON items_workspaces.itemable_id = '#{self.id}' AND items_workspaces.itemable_type = '#{self.class.to_s}'",
#			:conditions => "items_workspaces.workspace_id = '#{workspace_id}'"
#		}
#	}

	#10x10cm 72dpi or less
	
  # Media Type for the object
	#
	# No actual use but consistency with other media type (Video, Audio).
  #
  # Usage:
  # <tt>object.media_type</tt>
  def media_type
    image
  end

	def size
		return (self.width && self.width!=0) ? "#{self.width.to_s}x#{self.height.to_s}#{self.depth ? 'x'+self.depth.to_s : ''}" : nil
	end

	def edition
		return (self.edition_name && self.edition_name.blank?) ? nil : "#{self.edition_number.to_s} of #{self.edition_name}"
	end
 
end
