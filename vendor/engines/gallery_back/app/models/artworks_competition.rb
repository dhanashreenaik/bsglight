class ArtworksCompetition < ActiveRecord::Base

	belongs_to :artwork
	belongs_to :competition
	belongs_to :competitions_user,:foreign_key=>"competitions_users_id"
  
  has_attached_file :avatar,
                    :url =>"/uploaded_files/competition/artwork/:id/:style/:basename.:extension",
                    :path =>":rails_root/public/uploaded_files/competition/artwork/:id/:style/:basename.:extension",
                    :styles => { :medium => "600x400", :thumb => "48x48" }
end
