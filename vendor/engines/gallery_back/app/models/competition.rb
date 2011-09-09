class Competition < ActiveRecord::Base

  # Method defined in the ActsAsItem:ModelMethods:ClassMethods (see that library fro more information)
  acts_as_item

	has_one :timing, :as => :objectable, :dependent => :delete
	accepts_nested_attributes_for :timing, :reject_if => lambda { |a| a[:starting_date].blank? }, :allow_destroy => true

	has_many :competitions_subscriptions, :dependent => :delete_all
	accepts_nested_attributes_for :competitions_subscriptions, :reject_if => lambda { |a| a[:price].blank? }, :allow_destroy => true

	has_many :competitions_users, :dependent => :delete_all
	has_many :users, :through => :competitions_users
	has_many :artworks_competitions, :dependent => :delete_all
	has_many :artworks, :through => :artworks_competitions
#	accepts_nested_attributes_for :artworks, :reject_if => lambda { |a| a[:title].blank? }, :allow_destroy => true
    

	#has_one :timing, :as => :objectable
	#accepts_nested_attributes_for :timing, :reject_if => lambda { |a| a[:starting_date].blank? }, :allow_destroy => true
 validates_presence_of :timing ,:message=>"Please Enter Exhibition Date"
	#validates_presence_of :submission_deadline
 validates_format_of :prizes_total_amount, :with => /\A[0-9]*\Z/i
  
 validates_presence_of :entry_fees
 validates_presence_of :submission_deadline
 validates_presence_of :no_of_entry
 validate :entry_fee_format

def entry_fee_format
 
          self.entry_fees.each do |x|
            
            if  !(x.split("works")[1] != nil and    x.split("works")[1].split(/\r/)[0].split("$")[1].to_i > 0  and x.split("works")[1].split(/\r/)[0].split("$")[1].to_i != 0)
                errors.add_to_base("Entry Fee Validation Failed") 
            else
            end 
         end   
end

  after_save :send_results_notification
	
	def judge
		return User.find(self.judge_id)
	end

	def send_results_notification
		if self.state == "results_publish"
			place=0
			self.artworks_competitions.all(:conditions => "mark > 0", :order => 'mark DESC')[0..4].each do |res|
				place += 1
				#QueuedMail.add('UserMailer', 'results_notification', [res.artwork.user, self, place], 0, false)
			end
		end
	end

end
