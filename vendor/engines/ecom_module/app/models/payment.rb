#require 'active_merchant'
require "rubygems"
require "net/https"
require "uri"
require "date"
require "ruby-paypal"

class Payment < ActiveRecord::Base

	validates_presence_of :user_id, :invoice_id

#	belongs_to :credit_card
#	accepts_nested_attributes_for :credit_card
	belongs_to :user
	belongs_to :invoice


	def active_merchant_process(credit_card_given)
		# Send requests to the gateway's test servers
		ActiveMerchant::Billing::Base.mode = :test

		# Create a new credit card object
		credit_card = ActiveMerchant::Billing::CreditCard.new(
			:number     => credit_card_given.number,
			:month      => credit_card_given.expiring_date.month,
			:year       => credit_card_given.expiring_date.year,
			:first_name => credit_card_given.first_name,
			:last_name  => credit_card_given.last_name,
			:verification_value  => credit_card_given.verification_value
		)

		amount = self.amount_in_cents

		if credit_card.valid?

			# Create a gateway object to the TrustCommerce service
			gateway = ActiveMerchant::Billing::TrustCommerceGateway.new(
				:login    => 'TestMerchant',
				:password => 'password',
				:default_currency => 'AUD'
			)

			# Authorize for $10 dollars (1000 cents)
			response = gateway.authorize(amount, credit_card)

			if response.success?
				# Capture the money
				gateway.capture(amount, response.authorization)
				self.state = 'online_validated'
				self.save
			else
				raise StandardError, response.message
			end

		else
			raise StandardError, "Credit card not valid"
		end
		
	end

 def make_paypal_payment(more_amount ,params) 
        username = "kedar._1307778315_biz_api1.pragtech.co.in"
        password = "1307778325"
        signature = "AOrvOfVxLIlci28rFr5.0uNFZt-5A0RGW5jfcK7gepaohgBNnJ4AFDF5"
        amount = more_amount.to_s
        card_type = params[:credit_card][:type_of_card].upcase
        card_no = params[:credit_card][:number]
        cardexpdate=Date.civil(params["credit_card"]["expiring_date(1i)"].to_i,params["credit_card"]["expiring_date(2i)"].to_i).strftime("%m%Y")
        exp_date = cardexpdate
        first_name = params[:credit_card][:first_name]
        last_name = params[:credit_card][:last_name] 
        billing_address = "paud phata pune"
        cvc=params[:credit_card][:verification_value]
        paypal = Paypal.new(username, password, signature) # uses the PayPal sandbox
        response = paypal.do_direct_payment_sale("192.168.0.16", amount, card_type,card_no, exp_date, first_name, last_name,cvc=nil,{:STREET=>"1 Main St",:city=>"San Jose",:STATE=>"ca",:zip=>95131})
        if response.ack == 'Success' 
                      self.state = 'online_validated'
                      self.save
        else
        end
 end

 
 

  def common_wealth_bank_process(amount_in_cents,params,no="")
        cardexpdate=Date.civil(params["credit_card"]["expiring_date(1i)"].to_i,params["credit_card"]["expiring_date(2i)"].to_i)
        amount_in_cents = amount_in_cents
        uri = URI.parse("https://migs.mastercard.com.au/vpcdps?vpc_Version=1&vpc_Command=pay&vpc_AccessCode=C5ED3BE7&vpc_MerchTxnRef=#{params[:credit_card][:user_id]}&vpc_Merchant=TESTGRAPRECOM01&vpc_OrderInfo=#{params[:credit_card][:user_id]}&vpc_Amount=#{amount_in_cents.to_i}&vpc_CardNum=#{no}&vpc_cardExp=#{cardexpdate.strftime('%y%m')}&vpc_locale=en")
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        #http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        request = Net::HTTP::Post.new(uri.request_uri)
        response = http.request(request)
        responsearray=response.body.split("&")
            responsearray.each do |res|
                	if  res.split("=")[0] == "vpc_Message"
             		    if res.split("=")[1] =="Approved"
                                self.state = 'online_validated'
                                self.save
                                #invoice.validating                      
                		elsif  res.split("=")[1] =="Declined"
                    	       self.state = 'Declined'
                                self.save
                		elsif  res.split("=")[1] =="Unspecified+Failure"  
		                        self.state = "Unspecified+Failure"  
                                self.save
                		elsif  res.split("=")[1] =="Referred"   
                                 self.state = "Referred"
                                self.save
                		elsif  res.split("=")[1] =="Timed+Out"   
			                      self.state = "Timed+Out"   
                                self.save
                    	elsif  res.split("=")[1] =="Expired+Card"   
                    			  self.state = "Expired+Card"
                                self.save
                		elsif  res.split("=")[1] =="Insufficient+Funds"   
			                      self.state = "Insufficient+Funds"
                                self.save
		                else 
			        		   self.state = res.split("=")[1]
                                self.save
		                end
	               end	
	     end
    end


	def sending_confirmation_to_client
		if QueuedMail.add('UserMailer', 'payment_confirmation', [self, self.invoice.client], 0, true)
		else
			raise "Payment confirmation not sent"
		end
	end

end
