class CompetitionsSubscription < ActiveRecord::Base

	belongs_to :competition
	has_many :competitions_users

	validates_presence_of :maximum_works_number, :price

	validates_format_of :maximum_works_number, :with => /\A[0-9]*\Z/i

	def to_s
		return "Price : #{self.price} -- Maximum works to submit : #{self.maximum_works_number}<br />Description : #{self.description}<br />"
	end

	def price= param
		self[:price] = param.to_f
	end

end
