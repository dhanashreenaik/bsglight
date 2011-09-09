class Order < ActiveRecord::Base

	belongs_to :client, :class_name => 'User'
	belongs_to :creator, :class_name => 'User'
	#has_many :invoices, :as => :purchasable
	has_one :invoice, :as => :purchasable
	has_many :order_lines, :dependent => :destroy
   
	before_create :generate_number

	validates_presence_of :title, :client_id
#	validate :no_duplication
#
#	def no_duplication
#		errors.add_to_base("Invoice already generated for that order") if self.purchasable && self.purchasable.invoices.first
#	end

	def generate_number
    record = true
    while record
      random = "O#{Array.new(9){rand(9)}.join}"
      record = Order.find(:first, :conditions => ["number = ?", random])
    end
    self.number = random
  end

	def self.new_from_cart(cart, client)
	image_array = ['fworkimage','sworkimage','tworkimage','foworkimage','fiworkimage','siworkimage','seworkimage','eworkimage','nworkimage','teworkimage']	
   price_array = ['fworkprice','sworkprice','tworkprice','foworkprice','fiworkprice','siworkprice','seworkprice','eworkprice','nworkprice','teworkprice']
		order = Order.new
		#order.generate_number
		order.title = "Order #{order.number.to_s}"
		order.client_id = client.id
		t_a = 0
		if cart
		cart.each do |k, v|

		    if  k.split('_')[0] == "CompetitionsUser"
             line = OrderLine.new(:orderable_type => k.split('_')[0], :orderable_id => k.split('_')[1].to_i, :number => v.to_i,:imagename=>k.split('_')[2])
		         order.order_lines << line
             t_a += (line.orderable.send price_array.fetch(image_array.index(line.imagename))).to_i  * v.to_i
              
		   else
		                        line = OrderLine.new(:orderable_type => k.split('_').first, :orderable_id => k.split('_').last, :number => v.to_i)
		                    	order.order_lines << line
		                    	t_a += line.orderable.price.to_f * v.to_f
		   end	
		end
		end
		order.total_amount = t_a
		#raise order.inspect

		return order
	end

	def self.complete_from_cart(cart, client)
		order = self.new_from_cart(cart, client)
		order.state = 'completed'
		order.completed_at = Time.now
		#raise order.order_lines.inspect
		if order.save
			return order
		else
			raise order.errors.inspect
			raise "Order not completed"
		end
	end

	def generate_invoice(user, invoicing_info)
		invoice = Invoice.new(
				:purchasable_type => self.class.to_s,
				:purchasable_id => self.id,
				:client_id => user.id,
				:description => "Invoice generated after the validation of your cart the #{I18n.l(self.completed_at, :format => :long)}",
				:deadline => Time.now.to_date + 7.days,
				:original_amount => self.total_amount,
				:final_amount => self.total_amount,
				:payment_medium => invoicing_info['payment_medium'],
				:billing_address => invoicing_info['billing_address'],
				:shipping_address => invoicing_info['shipping_address'],
				:state => 'created'
		)
		invoice.generate_number
		invoice.title= "Invoice #{invoice.number}"
		if invoice.save
			self.state == 'accepted'
			self.save
			return invoice
		else
			raise invoice.errors.inspect
			raise "Invoice generation problem"
		end
	end

	def price
		return self.total_amount.to_i
	end
 
end
