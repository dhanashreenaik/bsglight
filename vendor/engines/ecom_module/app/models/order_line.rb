class OrderLine < ActiveRecord::Base

	belongs_to :order
	belongs_to :orderable, :polymorphic => true

	validates_presence_of :orderable_type, :orderable_id, :number
 
end
