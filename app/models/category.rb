class Category < ActiveRecord::Base

	has_many :profiles_categories
	has_many :profiles, :through => :profiles_categories

	validates_presence_of :name

end
