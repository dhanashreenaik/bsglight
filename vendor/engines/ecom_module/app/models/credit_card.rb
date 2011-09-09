class CreditCard < ActiveRecord::Base

	has_many :payments
	belongs_to :user

	#validates_presence_of :number, :first_name, :last_name, :expiring_date, :verification_value
  validates_presence_of :number,  :expiring_date, :verification_value
	#validates_length_of :number, :is => 12
	#validates_format_of :number, :with => /(#{NUM})/

	#validates_length_of :verification_value, :is => 3
	#validates_format_of :verification_value, :with => /(#{NUM})/

	validate :valid_expiring_date

	def to_s
		return "#{self.type_of_card} #{self.last_name} #{self.number.to_s} (#{self.expiring_month}/#{self.expiring_year}) #{self.verification_value}"
	end

	def valid_expiring_date
    errors.add_to_base("The expiring date is not valid") unless self.expiring_date < Time.now.to_date
  end

end
