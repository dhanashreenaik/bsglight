class TimingsPlace < ActiveRecord::Base

  belongs_to :objekt, :polymorphic => true
	belongs_to :timing

	#validates_presence_of :timing_id, :objekt_id, :objekt_type

end
