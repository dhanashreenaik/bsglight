class ExhibitionsUser < ActiveRecord::Base

  belongs_to :user
	belongs_to :exhibition
	
	has_many :artworks_exhibitions
	has_many :artworks, :through => :artworks_exhibitions

	has_many :invoices, :as => :purchasable, :dependent => :delete_all
  

#	after :destroy do
#		# TODO destroy artworks linked to
#	end
 
 
 
 

  named_scope :with_state, lambda{ |state|
		{ :conditions => { :state => state } }
	}

	def generate_invoice(user=nil, invoicing_info={})
	    invoice = Invoice.find(:first,:conditions=>["purchasable_type = ? and  client_id = ? and purchasable_id = ?","ExhibitionsUser" , user.id,self.id])
	  	    if invoice != nil  then
	    return
	    end
	  
		amount1 = (self.price * 0.3).round(2)
		amount2 = self.price - amount1
		invoice = Invoice.new(
				:purchasable_type => self.class.to_s,
				:purchasable_id => self.id,

				:client_id => user.id ,

				:description => "First invoice for the subscription to the exhibition '#{self.exhibition.title}' (30% of the total amount)",
				:deadline => Time.now.to_date + 7.days,
				:original_amount => amount1,
				:final_amount => amount1,

				:payment_medium => invoicing_info['payment_medium'],
				:billing_address => invoicing_info['billing_address'],
				:shipping_address => invoicing_info['shipping_address'],

				:state => 'created'
		)
		invoice.generate_number
		invoice.title= "Invoice #{invoice.number}"
  
		invoice2 = Invoice.new(
				:purchasable_type => self.class.to_s,
				:purchasable_id => self.id,

				:client_id => user.id,

				:description => "Second invoice for the subscription to the competition '#{self.exhibition.title}' (70% of the total amount)",
				:deadline => self.exhibition.timing.ending_date + 7.days,
				:original_amount => amount2,
				:final_amount => amount2,

				:payment_medium => invoicing_info['payment_medium'],
				:billing_address => invoicing_info['billing_address'],
				:shipping_address => invoicing_info['shipping_address'],

				:state => 'created'
		)
		invoice2.generate_number
		invoice2.title= "Invoice #{invoice2.number}"
		if invoice.save && invoice2.save
    
			self.state == 'accepted'
			self.save
			return invoice
		else
			raise "Invoice generation problem"
		end
	end

	def setting_the_price
		tot = 0
		self.exhibition.timing.galleries.each do |e|
			tot += e.price
		end
		self.price = tot
	end
    
  
    
    
	def init
		self.state = 'created'
		self.setting_the_price
		self.save
	end

	def title
		return "Subscription to the exhibition '#{self.exhibition.title}'"
	end

end
