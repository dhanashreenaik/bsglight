class Invoice < ActiveRecord::Base

	belongs_to :client, :class_name => 'User'
	belongs_to :creator, :class_name => 'User'
	belongs_to :purchasable, :polymorphic => true

	has_one :payment

	serialize :billing_address
	serialize :shipping_address

	validates_presence_of :title, :client_id, :final_amount#, :purchasable_type, :purchasable_id
	# TODO but for exhibition you have two invoices ............
	#validate :no_duplication

	def no_duplication
		errors.add_to_base("Invoice already generated for that order") if self.purchasable && self.purchasable.invoices.first
	end

#	before_save do
#		self['final_amount'] ||= self['original_amount']
#	end

	after_create :sending_to_client

	def generate_number
    record = true
    while record
      random = "I#{Array.new(9){rand(9)}.join}"
      record = Invoice.find(:first, :conditions => ["number = ?", random])
    end
    self.number = random
		return random
  end

	def sending_to_client
    
    if self.purchasable_type == 'ExhibitionsUser'
    elsif self.purchasable_type == 'CompetitionsUser'
       self.sent_at = Time.now
       self.save
    else  
          adminuser = User.find_by_login("admin");
          @message = adminuser.sent_messages.new
          @message.subject = "Invoice " + self.number.to_s
          @message.body = "Hello, Please find attached your invoice For Your Payment For "
          @message.prepare_copies(self.client.email)
          @message.save
          if QueuedMail.add('UserMailer', 'send_invoice', [self, self.client], 0, true)
            self.sent_at = Time.now
            self.save
          else
            raise "Invoice email not queued"
          end
    end
    
	end

    def  accept_cash_or_cheque_or_bank_payment(cashorchequeorbank)
            self.state = "created"
            self.payment_medium = cashorchequeorbank
          	if self.save
            		if self.purchasable_type == 'ExhibitionsUser' || self.purchasable_type == 'CompetitionsUser' || self.purchasable_type == 'Order'
				        purc = self.purchasable
				        purc.state = "accepted"
				    end
			end	        
    end



	def validating(payment_mode="online_validated")
		self.state = 'validated'
		self.validated_at = Time.now
		self.payment_medium = payment_mode
		
		if self.purchasable_type == 'CompetitionsUser' #this is because because im calculating more amount while making the payment
		    invoice = Invoice.find(:all,:conditions=>["purchasable_type = ? and client_id = ? and purchasable_id = ?",'CompetitionsUser',self.client_id,self.purchasable_id])
		    invoice.each do |inv|
		    inv.state = "validated"
		    inv.save
		    end
		end
		p "i saved here myself as validated"
    p self
		if self.save
			if self.purchasable_type == 'ExhibitionsUser' || self.purchasable_type == 'CompetitionsUser' || self.purchasable_type == 'Order'

				purc = self.purchasable
        
                   if  purc.instance_of? ExhibitionsUser 
                         invoice = Invoice.find(:last,:conditions=>["purchasable_type = ? and  client_id = ? and purchasable_id = ?","ExhibitionsUser" , self.client_id,self.purchasable_id])
                         invoice1 = Invoice.find(:first,:conditions=>["purchasable_type = ? and  client_id = ? and purchasable_id = ?","ExhibitionsUser" , self.client_id,self.purchasable_id])

                          if  invoice.state == "validated"  and  invoice1.state == "validated"
                               purc.state = "validated"
                          end
                  else
                    
            purc.state = "validated"
             
            end
              if purc.save
                # email
                    if !self.payment
                        if payment = Payment.create(:invoice_id => self.id, :user_id => self.client_id, :amount_in_cents => self.final_amount * 100, :state => payment_mode)
                                else
                          raise "Error during payment creation : "+payment.errors.inspect
                        end
                    else
                      payment = self.payment
                      # #raise "Payment already done ..."
                    end
                payment.sending_confirmation_to_client
              else
                raise "Purchasable object and payment not done ..."
              end
			else


         if self.purchasable_type == 'Invoice'
         else 
           raise "samerelapute"
         end
        
			end
		else
			raise self.errors.inspect
		end
	end

	def billing_address_s
		self.billing_address.values.join(', ')
	end

	def shipping_address_s
		self.shipping_address.values.join(', ')
	end
 
end
