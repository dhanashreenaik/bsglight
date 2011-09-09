class Gallery < ActiveRecord::Base

  # Method defined in the ActsAsItem:ModelMethods:ClassMethods (see that library fro more information)
  acts_as_item

	has_many :timings_places, :as => :objekt
	has_many :timings, :through => :timings_places

end
