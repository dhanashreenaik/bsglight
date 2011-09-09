class ArtworksExhibition < ActiveRecord::Base

	belongs_to :artwork
	belongs_to :exhibition
	belongs_to :exhibitions_user

	#validates_presence_of :position

end