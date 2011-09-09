class Usergroupshow < ActiveRecord::Base
  belongs_to :groupshow
  belongs_to :user
  
  
  	def generate_invoice(user=nil, invoicing_info={},price=0)
    	    		invoice = Invoice.new(
		    		:purchasable_type => self.class.to_s,
		    		:purchasable_id => self.id,
		    		:client_id => self.user_id,
		    		:description => "Invoice for the subscription to the GroupShow '#{self.groupshow.title}'",
		    		:deadline => Time.now.to_date + 7.days,
		    		:original_amount => price,
		    		:final_amount => price,
		    		:payment_medium => invoicing_info['payment_medium'].to_s ,
		    		:billing_address => self.user.profile.full_address_for_invoice,
		    		:shipping_address => self.user.profile.full_address_for_invoice,
		    		:state => 'created'
		            )
		        invoice.generate_number
		        invoice.title= "Invoice #{invoice.number}"
		        if invoice.save
		        	return invoice
		        else
	    		end
	end
  
  
end
