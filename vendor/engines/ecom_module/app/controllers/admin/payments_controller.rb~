class Admin::PaymentsController < Admin::ApplicationController

	acts_as_ajax_validation

	def index
		@current_objects = Payment.all
	end

	def new
		@current_object = Payment.new
		#@invoice = Invoice.find(session[:invoice_id])
		@invoice = Invoice.find(params[:iid])
		if @invoice.state == 'validated'
			flash[:error] = "Invoice already paid, refresh the page pressing F5"
			render :text => @template.blank_main_div(:title => 'System error', :hsize => 'sixH', :modal => true), :layout => false
		else
			session[:invoice] = @invoice
			#@current_object.build_credit_card
			@credit_card = CreditCard.new
			render :partial => 'new', :layout => false
		end
	end

	def create
	    @order = session[:purchasable]

		@current_object = Payment.new(params[:payment])		#@invoice = session[:invoice]		#@current_object.amount_in_cents = @invoice.final_amount ? @invoice.final_amount * 100 : @invoice.original_amount * 100
		if      @order.instance_of? ExhibitionsUser
		        @current_object.amount_in_cents =params[:invoice_amount].to_i*100
	    elsif  @order.instance_of? CompetitionsUser
	    	     @current_object.amount_in_cents = (@order.find_price(@order.competition.id) ) * 100
	    else #all the amount is get set here		#@current_object.amount_in_cents = @invoice.final_amount ? @invoice.final_amount * 100 : @invoice.original_amount * 100
		end#amount seting if end
	    @current_object.user = @current_user		#@current_object.invoice = @invoice
		if  @order.instance_of? ExhibitionsUser
		                   if params[:invoicing_info][:payment_medium] ==  "online" 
    		                              @current_object.common_wealth_bank_process((params[:invoice_amount].to_i*100),params)
	                       elsif  params[:invoicing_info][:payment_medium] ==  "cash"  or   params[:invoicing_info][:payment_medium] ==  "cheque"
                           elsif  params[:invoicing_info][:payment_medium] ==  "paypal"  
                                          @current_object.make_paypal_payment((params[:invoice_amount].to_i),params) 
	                      end
      elsif      @order.instance_of? CompetitionsUser
	        	   if @order.invoices.last   
		                           total_amount = 0
		                           @order.invoices.each {|x| total_amount = total_amount + x.final_amount}
		                          if  total_amount  < @order.find_price(@order.competition.id) 
		                                 more_amount = (@order.find_price(@order.competition.id) ) -  total_amount
		                                @current_object.amount_in_cents = more_amount * 100
                                         if params[:invoicing_info][:payment_medium] ==  "online" 
    		                                         @current_object.common_wealth_bank_process((more_amount * 100),params)
	                                     elsif  params[:invoicing_info][:payment_medium] ==  "cash"  or   params[:invoicing_info][:payment_medium] ==  "cheque"
               	                         elsif  params[:invoicing_info][:payment_medium] ==  "paypal"  
	                                                       @current_object.make_paypal_payment((more_amount * 100),params) 
	                                     end
		                        else
		                                                    render :text=>"You Did not changed the entry field or if  you decremented it then send email to admin  <a href='/admin/competitions/#{@order.competition.id}'>Go Back To see the competition</a>"
		                               return
		                        end   
	                else
	                            if params[:invoicing_info][:payment_medium] ==  "online" 
	     	                                 @current_object.common_wealth_bank_process(((@order.find_price(@order.competition.id) ) * 100),params)#payment is done if invoice is not yet  created. for competition user
                                elsif  params[:invoicing_info][:payment_medium] ==  "cash"  or   params[:invoicing_info][:payment_medium] ==  "cheque"
                                elsif  params[:invoicing_info][:payment_medium] ==  "paypal"  
                                                  @current_object.make_paypal_payment(((@order.find_price(@order.competition.id) ) * 100),params) 
		                         end 
		           end 
	else #here it may be come that while working in this method and it fails somewhere and    session[:purchasable] = nil. generaly this is not the normal case
	             	   if    @order.instance_of? Order
	             	            make_order_payment
	             	            return
	             	   else
	             	    render :text=>"There Is Internal Error While Making the payment Please Try Go Back And Try Again<a href='/admin/profiles/#{current_user.id}'>Back</a> "
                       end
     return
	end#bank procedure if end
		#here  after the payment is done what message is required to be sent is get decided and the invoice is get generated
	if @current_object.state == 'online_validated'	     # flash[:notice] = 'Your Payment Is Done And Invoice Will Be Sent To You By Email'
	                       if    @order.instance_of? CompetitionsUser   
	                                if  @order and @order.invoices.last
	                                         total_amount = 0
	                            	        @order.invoices.each {|x| total_amount = total_amount + x.final_amount}
	                                        if  total_amount  < @order.find_price(@order.competition.id) 
	                                                  make_the_payment
	                                                   flash[:notice] = "Your Extra Selected Entry Payment Is Done <a href='/admin/competitions/#{@order.competition.id}'>Go Back To see the competition</a>"
	                                        else
	                                                flash[:error] = "Your Payment Is Already Done Please Go To Home Page  <a href='/admin/competitions/#{@order.competition.id}'>Go Back To see the competition</a>"
			                                end
			                              render :text => @template.blank_main_div(:title => 'System error', :hsize => 'sixH', :modal => true), :layout => false
			                              return
		                            else   
		                                   make_the_payment
	                                 end
	                     else
	                             if @order.instance_of? ExhibitionsUser 
    	                              make_the_payment_exhibition
	                              end
	                     end     
	                     if  @order.instance_of? ExhibitionsUser 
	                                   if   params[:invoicing_info][:payment_medium] ==  "cash"  or   params[:invoicing_info][:payment_medium] ==  "cheque"
    	                                         render :text=>"After Your Payment Is Done Admin  Will Validate You. After That Your Artwork Will Be Selected.   <a href='/admin/exhibitions/#{@order.exhibition.id}'>Select Artwork</a>"
	                                    else
	                                           invoice = Invoice.find(:last,:conditions=>["purchasable_type = ? and  client_id = ? and purchasable_id = ?","ExhibitionsUser" , @order.user,@order.id])
                	                       	   if  invoice.state == "created"
                                            	    create_pdf(invoice.id,invoice.number,invoice.sent_at.strftime("%d %b %Y"),invoice.client.profile.full_address_for_invoice,invoice.client.profile.full_name_for_invoice,@order.exhibition.title,invoice.final_amount.to_i,@order.exhibition.timing.note)
                                                 QueuedMail.add( 'UserMailer',  'send_invoice_exhibition', [@current_object.user.profile.email_address,"invoice#{invoice.id}","Your Exhibition Payment Is Done And An Invoice Is Sent to Your Email.",invoice, @current_object.user],0,true,@current_object.user.profile.email_address,"test@pragtech.co.in") 
		                                       end    
	                                    
                                               render :text=>"Your Payment Is Done Now Upload And Then Select The Artworks  <a href='/admin/exhibitions/#{@order.exhibition.id}'>Select Artwork</a>"
	                                    end            
             	        elsif  @order.instance_of? CompetitionsUser
                                 if   params[:invoicing_info][:payment_medium] ==  "cash"  or   params[:invoicing_info][:payment_medium] ==  "cheque"
    	                              render :text=>"After Your Payment Is Done Admin  Will Validate You. After That Your Artwork Will Be Selected.  Please Make The Payment Before #{@order.submission_date} <a href='/admin/competitions/#{@order.competition.id}'>Go Back To see the competition</a>"
                                else
      	                              render :text=>"Your Payment Is Done . The Invoice Is Sent To You By Email.   <a href='/admin/competitions/#{@order.competition.id}'>Go Back To see the competition</a>"
                                end     	       
	                    end
	else
		            if params[:invoicing_info][:payment_medium] ==  "cash"  or   params[:invoicing_info][:payment_medium] ==  "cheque"  
                              if  @order.instance_of? CompetitionsUser
			                       make_the_payment
		                       else
		                               	make_the_payment_exhibition
	                       	           invoice = Invoice.find(:last,:conditions=>["purchasable_type = ? and  client_id = ? and purchasable_id = ?","ExhibitionsUser" , @order.user,@order.id])
	                               	   if  invoice.state == "created"
                                            	    create_pdf(invoice.id,invoice.number,invoice.sent_at.strftime("%d %b %Y"),invoice.client.profile.full_address_for_invoice,invoice.client.profile.full_name_for_invoice,@order.exhibition.title,invoice.final_amount.to_i,@order.exhibition.timing.note)
                                             		QueuedMail.add('UserMailer', 'send_invoice_exhibition', [invoice, @order.user], 0, true)
		                               end       
		                      end      
		                       if  @order.instance_of? CompetitionsUser   
                                   render :text=>"After Your Payment Is Done Admin  Will Validate You. After That Your Artwork Will Be Selected.  Please Make The Payment Before #{@order.competition.submission_deadline} <a href='/admin/competitions/#{@order.competition.id}'>Go Back To see the competition</a>"
                               else
                                   render :text=>"After Your Payment Is Done Admin  Will Validate You. After That Your Artwork Will Be Selected.  <a href='admin/exhibitions/#{@order.exhibition.id}'>Select Artwork</a>"
                               end            	       
                   	       return
                   end
	            @credit_card = CreditCard.new
	            flash[:error] = 'Error during the payment save  '+@current_object.state.to_s
		        render :partial => 'new', :layout => false
	end
 end

  
  def  make_order_payment
            session[:purchasable] = nil
            @current_object.amount_in_cents =  @order.total_amount*100
            @invoice = @order.generate_invoice(@current_user, params[:invoicing_info]) 
              if params[:invoicing_info][:payment_medium] ==  "online" 
    		           @current_object.common_wealth_bank_process(@order.total_amount*100,params)
	         elsif  params[:invoicing_info][:payment_medium] ==  "cash"  or   params[:invoicing_info][:payment_medium] ==  "cheque"
             elsif  params[:invoicing_info][:payment_medium] ==  "paypal"
                        @current_object.make_paypal_payment(@order.total_amount.to_i,params) 
  	         end
  	         if @current_object.state == 'online_validated'	    
  	        
  	                   session[:cart] ={}
              	       	if params[:invoicing_info][:payment_medium] == "paypal"
                                            @invoice.validating("paypal")
                        else
                                               @invoice.validating
                        end     
               	                       render :text=>"Your Payment Is Done . The Invoice Is Sent To You By Email.   <a href='/admin/profiles/#{current_user.id}'>Go Back </a>"
              
             else
                          if   params[:invoicing_info][:payment_medium] ==  "cash"  or   params[:invoicing_info][:payment_medium] ==  "cheque"
                                         session[:cart] ={}
                                       	 @invoice.accept_cash_or_cheque_payment(params[:invoicing_info][:payment_medium])                        
                	                      render :text=>"After Your Payment Is Done Admin  Will Validate You. The Invoice Is Sent To You By Email.   <a href='/admin/profiles/#{current_user.id}'>Go Back </a>"
                          else

                                         render :text=>"There Is Error In Payment    <a href='/admin/profiles/#{current_user.id}'>Go Back </a>  and try again"
                         end 
             end       
               create_pdf(@invoice.id,@invoice.number,@invoice.sent_at.strftime("%d %b %Y"),@invoice.client.profile.full_address_for_invoice,@invoice.client.profile.full_name_for_invoice,@order.title,@invoice.final_amount.to_i,nil)
         	   		  email= UserMailer.create_send_invoice(@invoice,@current_user)
	                    UserMailer.deliver(email)        	
  end
  
  
  
  def  make_the_payment_exhibition
                    session[:purchasable] = nil
                    @invoice = Invoice.find(params[:invoice_id])
                	if params[:invoicing_info][:payment_medium] ==  "cash"  or   params[:invoicing_info][:payment_medium] ==  "cheque"
           	                   	@invoice.accept_cash_or_cheque_payment(params[:invoicing_info][:payment_medium]) 
           	        elsif params[:invoicing_info][:payment_medium] == "paypal"
                                @invoice.validating("paypal")
                    else
                                   @invoice.validating
                    end     	
  end

    #actual payment is done in above method onlyhere the invoice processing is done
    def  make_the_payment
              session[:purchasable] = nil
              if  @order and @order.invoices.last
              	@invoice = @order.generate_invoice_extra_entry(@current_user, params[:invoicing_info])
              
              else
              @invoice = @order.generate_invoice(@current_user, params[:invoicing_info]) 
              end 	
           	if params[:invoicing_info][:payment_medium] ==  "cash"  or   params[:invoicing_info][:payment_medium] ==  "cheque"
           	
                   	@invoice.accept_cash_or_cheque_payment(params[:invoicing_info][:payment_medium]) 
            elsif params[:invoicing_info][:payment_medium] == "paypal"
                    @invoice.validating("paypal")
             else
                   @invoice.validating
             end     	
             @current_object.invoice = @invoice
             @current_object.save
         	invoice = Invoice.find(:last,:conditions=>["client_id = ? and purchasable_id = ?",@current_user.id,@order.id])
         	if @order.instance_of? CompetitionsUser
                  create_pdf(invoice.id,invoice.number,invoice.sent_at.strftime("%d %b %Y"),invoice.client.profile.full_address_for_invoice,invoice.client.profile.full_name_for_invoice,@order.competition.title,invoice.final_amount.to_i,@order.competition.timing.note)
            elsif  @order.instance_of? ExhibitionsUser
                  create_pdf(invoice.id,invoice.number,invoice.sent_at.strftime("%d %b %Y"),invoice.client.profile.full_address_for_invoice,invoice.client.profile.full_name_for_invoice,@order.exhibition.title,invoice.final_amount.to_i,@order.exhibition.timing.note)
            end
           	       #QueuedMail.add('UserMailer', 'send_invoice',[@invoice,@current_user], 0, send_now=true)	
   	     	    		 QueuedMail.create(:mailer => 'UserMailer', :mailer_method => 'send_invoice',:args => [@current_user.profile.email_address,"invoice#{invoice.id}","An Invoice Is Send To Your Email For Your Payment"],:priority => 0,:tomail=>@current_user.profile.email_address,:frommail=>"test@pragtech.co.in")
			      	    email= UserMailer.create_send_invoice(invoice,@current_user)
	                   UserMailer.deliver(email)
	                       
            if  @invoice.purchasable_type == "Order"
	                session[:cart]=nil
	        end
    end
    
    

end
