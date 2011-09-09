class Admin::InvoicesController < Admin::ApplicationController

	# GET /Invoices
  # GET /Invoices.xml
  def index
		if @current_user.has_system_role('admin')
			@current_objects = Invoice.find(:all)
		else
			@current_objects = Invoice.find(:all, :conditions => { :client_id => @current_user.id })
		end
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @current_objects }
    end
  end

  def pay_for_invoice
    @credit_card = CreditCard.new	
    render :partial => 'pay_for_invoice', :layout => false
  end
  
  
  def create_the_payment
    payment = Payment.find(:first,:conditions=>["state = 'online_validated' and invoice_id = #{params[:invoiceid]}"])
    invoice = Invoice.find(params[:invoiceid])
    if payment.blank?
           
         payment=Payment.new
         
         invoice=Invoice.find(params[:invoiceid])
         payment.invoice_id = params[:invoiceid]
         payment.user_id = invoice.client_id
         payment.amount_in_cents = (invoice.final_amount.to_i*100)
        
         
         if params[:invoicing_info][:payment_medium] == "online"
                payment.common_wealth_bank_process((invoice.final_amount.to_i*100),params)
         end
         if params[:invoicing_info][:payment_medium] == "paypal"
            session[:paypal_amount] = invoice.final_amount.to_i*100
            session[:invoice_id] = params[:invoiceid]
            session[:payment_id] = payment.id
            set_the_token
            render :update do |page|
                page["modal_space_answer"].hide                                     
                page["paypal_form"].replace_html :partial=>"paypal_form",:locals=>{:token =>@token,:amt=>(session[:paypal_amount])}
                page.call 'submit_my_form'
              end
            return
         end
         if payment.state == "online_validated"
                payment.save
                invoice.state = "validated"
                invoice.payment_medium = "online"
                invoice.purchasable_type = "Invoice"
                invoice.save
              render :text=>"Your Payment Is Done"
         else
              render :text=>"Your Payment Is Not Done Please Check The Fields Properly"
         end
    else
        render :text=>"Your Payment Is Already Done"  
    end
  end
  
  
   def set_the_token
    username= "pathak_1259733727_biz_api1.gmail.com"
    password = "1259733733"
    signature= "A.gsseBoaG2XQonqoXpE4WUr4VafArVDPTPSg6gSo7rEoyqCTsE-yxWp"
    paypal = Paypal.new(username, password, signature)
    logger.info "there is problem in total"
    logger.info session[:paypal_amount].to_i
    logger.info session[:paypal_amount].to_i/100
    response = paypal.do_set_express_checkout(
      return_url="http://" + request.host_with_port + "/paypal_return_invoice",
      cancel_url="http://" + request.host_with_port + "/paypal_cancel_invoice",
      amount=session[:paypal_amount].to_i/100
    )
    logger.info response.to_s
    logger.info "this is paypal response"
    @token = (response.ack == 'Success') ? response['TOKEN'] : ''
    session[:token] = @token
  end 
  
def  paypal_return_invoice
  username= "pathak_1259733727_biz_api1.gmail.com"
  password = "1259733733"
  signature= "A.gsseBoaG2XQonqoXpE4WUr4VafArVDPTPSg6gSo7rEoyqCTsE-yxWp"
  paypal = Paypal.new(username, password, signature)
  response = paypal.do_get_express_checkout_details(session[:token])
  logger.info response.to_s
  logger.info "this is paypal response"
  if response.ack == "Success"
     response = paypal.do_express_checkout_payment(token=session[:token],
     payment_action = 'Sale',
     payer_id=response.payerid,
     amount=session[:paypal_amount].to_i/100)#end of do express checkout method
   
   invoice=Invoice.find(session[:invoice_id])
   payment=Payment.new
   invoice=Invoice.find(session[:invoice_id])
   payment.invoice_id = invoice.id
   payment.user_id = invoice.client_id
   payment.amount_in_cents = (invoice.final_amount.to_i*100)
   payment.state = 'online_validated'
   invoice.state = "validated"
   invoice.payment_medium = "online"
   invoice.purchasable_type = "Invoice"
   payment.save
   invoice.save
   flash[:notice] = "your payment is done"
  end    
   session[:paypal_amount] = nil
   session[:invoice_id] = nil
   session[:payment_id] = nil
  #redirect_to :action=>"index" 
  render :text=>"your payment is done"
end
  
  def paypal_cancel_invoice
    flash[:notice] = "You have cancelled the payment"
     session[:paypal_amount] = nil
     session[:invoice_id] = nil
     session[:payment_id] = nil
    #redirect_to :action=>"index"
    render :text=>"You have cancelled the payment"
  end

  # GET /Invoices/1
  # GET /Invoices/1.xml
  #here i need to check if the invoice is of exhibition type then i need to find both invoices and need to show there details.
  def show
    @current_object = Invoice.find(params[:id])
    @firstinv = nil
    @secinv = nil
    if @current_object.purchasable_type == 'ExhibitionsUser'
       @firstinv =   Invoice.find(:first,:conditions=>["purchasable_id = ? and purchasable_type = ?  and client_id = ?",@current_object.purchasable_id,'ExhibitionsUser',@current_object.client_id] )
       @secinv =   Invoice.find(:last,:conditions=>["purchasable_id = ? and purchasable_type = ?  and client_id = ?",@current_object.purchasable_id,'ExhibitionsUser',@current_object.client_id] )
    end
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @current_object }
			format.pdf { render :layout => false, :file => "#{RAILS_ROOT}/public/pdf_invoice/#{@current_object.id}invoice.pdf", :type => "application/pdf" }
    end
  end

  # GET /Invoices/new
  # GET /Invoices/new.xml
  def new
    @current_object = Invoice.new
    
   # @profile = Profile.find(params[:id])
    
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @current_object }
    end
  end

  # GET /Invoices/1/edit
  def edit
    @current_object = Invoice.find(params[:id])
    @profile = Profile.find(@current_object.client.id)
		respond_to do |format|
      format.html # edit.html.erb
      format.xml  { render :xml => @current_object }
    end
  end

  # POST /Invoices
  # POST /Invoices.xml
  def create
    @current_object = Invoice.new(params[:invoice])
		@current_object.final_amount ||= @current_object.original_amount
		@current_object.state = 'created'
    @current_object.number = rand(123456789)
		@current_object.creator_id = @current_user.id
    @current_object.purchasable_type = "Invoice"    
    
    respond_to do |format|
      if @current_object.save
       create_pdf(@current_object.id.to_s,@current_object.number.to_s,@current_object.created_at.strftime("%d %b %Y"),@current_object.client.profile.full_address_for_invoice ,@current_object.client.profile.full_name ,@current_object.title,@current_object.final_amount,@current_object.note,@current_object.final_amount,paid="",exhibitionpdf=false,finish_date=Time.now.strftime("%d %b %Y"),deposit_required="")#{invoice.sent_at.strftime("%d %b %Y")}   #{invoice.user.profile.full_address}
    
        flash[:notice] = 'Invoice was successfully created.'
        format.html { redirect_to admin_invoice_url(@current_object) }
        format.xml  { render :xml => @current_object, :status => :created, :location => @current_object }
      else
				raise @current_object.errors.inspect
				flash[:error] = 'Invoice was not created.'
        format.html { render :action => "new" }
        format.xml  { render :xml => @current_object.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /Invoices/1
  # PUT /Invoices/1.xml
  def update
    @current_object = Invoice.find(params[:id])
    respond_to do |format|
      if @current_object.update_attributes(params[:invoice])
          create_pdf(@current_object.id.to_s,@current_object.number.to_s,@current_object.created_at.strftime("%d %b %Y"),@current_object.client.profile.full_address_for_invoice ,@current_object.client.profile.full_name ,@current_object.title,@current_object.final_amount,@current_object.note,@current_object.final_amount,paid="",exhibitionpdf=false,finish_date=Time.now.strftime("%d %b %Y"),deposit_required="")#{invoice.sent_at.strftime("%d %b %Y")}   #{invoice.user.profile.full_address}
 
        flash[:notice] = 'Invoice was successfully updated.'
        format.html { redirect_to admin_invoice_url(@current_object) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @current_object.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /Invoices/1
  # DELETE /Invoices/1.xml
  def destroy
    @current_object = Invoice.find(params[:id])
    @current_object.destroy
    respond_to do |format|
      format.html { redirect_to(admin_invoices_url) }
      format.xml  { head :ok }
    end
  end

	def update_state
		@current_object = Invoice.find(params[:id])
		if params[:state] == 'sent'
			@current_object.sending_to_client
		end
		if params[:state] == 'validated' && @current_user.has_system_role('admin')
			@current_object.validating
		end
    
		#redirect_to admin_invoice_url(@current_object)
     redirect_to :back
	end
  
  
  def open_update_state
      @invoice = Invoice.find(params[:id])
      @sendusermail = @invoice.client
      @frommail = Frommail.find(:all)
  end
  
  def create_sent_mail
    invoice = Invoice.find(params[:invoiceid])
    invoice.note = params[:message][:note]
    invoice.save
    if invoice.purchasable_type == 'Invoice'
        create_pdf(invoice.id.to_s,invoice.number.to_s,invoice.created_at.strftime("%d %b %Y"),invoice.client.profile.full_address_for_invoice ,invoice.client.profile.full_name ,invoice.title,invoice.final_amount,invoice.note,invoice.final_amount,paid="",exhibitionpdf=false,finish_date=Time.now.strftime("%d %b %Y"),deposit_required="")#{invoice.sent_at.strftime("%d %b %Y")}   #{invoice.user.profile.full_address}
        render :text=>"your pdf has been sent"
    end
    if invoice.purchasable_type == 'CompetitionsUser'
      compuser = CompetitionsUser.find(invoice.purchasable_id)
     create_pdf(invoice.id,invoice.number,invoice.sent_at.strftime("%d %b %Y"),invoice.client.profile.full_address_for_invoice,invoice.client.profile.full_name_for_invoice,compuser.competition.title,invoice.final_amount.to_i,invoice.note,"",invoice.final_amount.to_i)
    render :text=>"your pdf has been sent"
    end
    if invoice.purchasable_type == 'ExhibitionsUser'
      invoiceall = Invoice.find(:all,:conditions => "purchasable_id = #{invoice.purchasable_id} and purchasable_type = 'ExhibitionsUser' and client_id = #{invoice.client_id}")
      exhuser = ExhibitionsUser.find(invoice.purchasable_id)
      if invoiceall.first == invoice
         alreadypaidamt = exhuser.price - invoiceall.last.final_amount
         create_pdf(invoice.id,invoice.number,exhuser.exhibition.timing.starting_date.strftime("%d %b %Y"),invoice.client.profile.full_address_for_invoice,invoice.client.profile.full_name_for_invoice,exhuser.exhibition.title,exhuser.price.to_i,invoice.note,exhuser.price.to_i,0,true,exhuser.exhibition.timing.ending_date.strftime("%d %b %Y"),invoice.final_amount.to_i)
      else
         create_pdf(invoice.id,invoice.number,exhuser.exhibition.timing.starting_date.strftime("%d %b %Y"),invoice.client.profile.full_address_for_invoice,invoice.client.profile.full_name_for_invoice,exhuser.exhibition.title,exhuser.price.to_i,invoice.note,exhuser.price - alreadypaidamt,alreadypaidamt,true,exhuser.exhibition.timing.ending_date,"")
      end
      render :text=>"your pdf has been sent"
    end
    if invoice.purchasable_type == 'Order'
        create_pdf(invoice.id.to_s,invoice.number.to_s,invoice.created_at.strftime("%d %b %Y"),invoice.client.profile.full_address_for_invoice ,invoice.client.profile.full_name ,invoice.title,invoice.final_amount,invoice.note,invoice.final_amount,paid="",exhibitionpdf=false,finish_date=Time.now.strftime("%d %b %Y"),deposit_required="")#{invoice.sent_at.strftime("%d %b %Y")}   #{invoice.user.profile.full_address}
        render :text=>"your pdf has been sent"
    end    
    
    @message = current_user.sent_messages.build(params[:message])
    @message.prepare_copies(params[:user][:email])
    @message.body =  @message.body + "<br/><font color='#FF0080'>" + params[:signature].to_s+"</font>"
    @message.save
    email = UserMailer.create_send_invoice_forchangenote(invoice.client,invoice,params[:signature],params[:message][:body],params[:message][:subject])
    UserMailer.deliver(email)
    
 end

  
  

  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
	
  
  
  
  
  
  
  
  
  def invoicing
	  if  params[:show_layout] == "true"
	  layout =  true   
	  else
	  layout =  false  	 
	  end
		@order = params[:purchasable_type].classify.constantize.find(params[:purchasable_id])
        total_amount = 0
		@order.invoices.each {|x| total_amount = total_amount + x.final_amount}
		if  @order.instance_of? CompetitionsUser
		        if total_amount  == @order.find_price(@order.competition.id) 
			        flash[:notice] = 'Your Payment Is Done No Due Is Remaining'
			        render :text => @template.blank_main_div(:title => 'System error', :hsize => 'sixH', :modal => true), :layout =>  layout
			
		        elsif total_amount  < @order.find_price(@order.competition.id) 
			        session[:purchasable] = @order
			        @credit_card = CreditCard.new
			        render :partial => 'admin/invoices/invoicing', :layout =>layout
		        else
			        flash[:error] = 'There is error on server please try again'
			        render :text => @template.blank_main_div(:title => 'System error', :hsize => 'sixH', :modal => true), :layout =>  layout
		        end
		else
		        if @order.invoices.first
			flash[:error] = 'Invoice already generated, refresh the page with F5'
			
			render :text => @template.blank_main_div(:title => 'System error', :hsize => 'sixH', :modal => true), :layout =>  layout
			
		else
			session[:purchasable] = @order
			@credit_card = CreditCard.new
			render :partial => 'admin/invoices/invoicing', :layout =>layout
			
		end
		end
	end

	
	def generate_invoice
		#raise params.inspect
		@order = session[:purchasable]
		p"==============================#{session[:purchasable].inspect}"
		if @order and @order.invoices.first
			flash[:error] = "Invoice already generated, refresh the page with F5"
			render :text => @template.blank_main_div(:title => 'System error', :hsize => 'sixH', :modal => true), :layout => false
		else
			# TODO check the invoicing params
			if params[:invoicing_info]
				session[:purchasable] = nil
   		        # @invoice = @order.generate_invoice(@current_user, params[:invoicing_info])
				flash[:notice] = "Invoice created !!!"
				render :partial => 'admin/invoices/invoice_show', :layout => false, :locals => { :current_object => @invoice, :is_modal => true }
			else
				flash[:error] = "Error creating invoice !!!"
				render :partial => 'admin/invoices/invoicing', :layout => false
			end
		end
#		if @invoice.payment_medium == 'online'
#			#redirect_to new_admin_payment_url(:iid => @invoice.id)
#			render :partial => 'admin/payments/new', :layout => false
#		else
#			redirect_to admin_invoice_url(@invoice)
#		end
	end

	
 
  
  
  

end
