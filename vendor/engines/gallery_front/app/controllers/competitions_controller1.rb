 class CompetitionsController < ApplicationController
	layout "front"
  require "prawn"
  require "fastercsv" 
  require "rubygems"
  require "net/https"
  require "uri"
  require "ruby-paypal"
  
    
  def show
    @competitions = Competition.all.sort {|x,y| x.title <=> y.title }
		if params[:competition_id]
			@competition = Competition.find(params[:competition_id])
	 	else
			@competition = @competitions.first
		end
		if logged_in?
		  if params[:competition_id]
        @competitionuser = CompetitionsUser.find_by_user_id_and_competition_id(current_user.id,params[:competition_id])
        @competitionusers = CompetitionsUser.find_all_by_competition_id(params[:competition_id])
    	else
        @competitionuser = CompetitionsUser.find_by_user_id_and_competition_id(current_user.id,@competition.id)  if @competition
        @competitionusers = CompetitionsUser.find_all_by_competition_id(@competition.id) if @competition
    	end
    else
      if params[:competition_id]
        @competitionuser = CompetitionsUser.find_by_competition_id(params[:competition_id])
    	else
        @competitionuser = CompetitionsUser.find_by_competition_id(@competition.id) if @competition
    	end
    end  
    columnnameandheader = Columnnameandheader.find(:all,:conditions=>["idoffieldwithtablename = ?",@competition.id.to_s+"competition"])  if @competition
    @oldlabelvalue={}
    if columnnameandheader
        columnnameandheader.each do |x|   
          @oldlabelvalue[x.column_name] = x.column_header
        end
    end   
    
    
		if @competition
			# TODO publish rules ...
			if @competition.state == 'final_published'
        @winnerlist = []
        competitionuser = CompetitionsUser.find(:all,:include=>["artworks_competitions"],:conditions=>["competition_id = ?   ",@competition.id])
        @competitionuser  = []
        competitionuser.each do |ac| 
          ac.artworks_competitions.each do |x|  
            
            if x.state == "selected"
              @competitionuser  << x.competitions_user
            end
              if x.state == "winner"
              @winnerlist  << x
            end
          end 
        end
        #@artworks = @competition.artworks_competitions.all(:include => [:artwork], :order => "mark DESC").map{ |e| e.artwork }
			elsif @competition.state == 'results_publish'
				#@artworks = @competition.artworks_competitions.all(:include => [:artwork], :conditions => { :state => 'selected' }).map{ |e| e.artwork }
        competitionuser = CompetitionsUser.find(:all,:include=>["artworks_competitions"],:conditions=>["competition_id = ?   ",@competition.id])
              
        @competitionuser  = []
        @winnerlist = []
        competitionuser.each do |ac| 
          ac.artworks_competitions.each do |x|  
              if x.state == "winner"
              @winnerlist  << x
            end
            if x.state == "selected"
              @competitionuser  << x.competitions_user
            end
          end 
        end
            
			else
				#@artworks = @competition.artworks
        @competitionuser = CompetitionsUser.find(:all,:conditions=>["competition_id = ? ",@competition.id])
			end
		end
  	if  logged_in? 
			@competitionuser = CompetitionsUser.find(:all,:conditions=>["competition_id = ? and user_id     = ?",@competition.id,current_user.id]) if @competition
    end  
    @competitionuser.uniq! if @competitionuser
 
  
  
  end
	def create_subscribe_competition
		@competitionuser = CompetitionsUser.find_by_user_id_and_competition_id(current_user.id,params[:competion_id])
		if  @competitionuser.blank?
      size_array_send = ['fworksize=','sworksize=','tworksize=','foworksize=','fiworksize=','siworksize=','seworksize=','eworksize=','nworksize=','teworksize=']
      size_array = ['fworksize','sworksize','tworksize','foworksize','fiworksize','siworksize','seworksize','eworksize','nworksize','teworksize']
      if  params[:competitions_user][:payment_type]	  == "Credit Card"
        if  params[:competitions_user][:card_name].blank? or  params[:competitions_user][:card_number1].blank? or params[:competitions_user][:card_number2].blank? or params[:competitions_user][:card_number3].blank?  or params[:competitions_user][:card_number4].blank?   or params[:competitions_user][:varification_code].blank? or  params[:competitions_user][:exp_date1].blank? or  params[:competitions_user][:exp_date2].blank?  
          flash[:notice] = "Please Enter The Credit Card Details"
          redirect_to :back
          return
        end 
      end 
      @competitionuser = CompetitionsUser.new(params[:competitions_user])
      @competitionuser.email = params[:competitions_user][:email]
      @competitionuser.name = params[:competitions_user][:name]
      @competitionuser.suburb = params[:competitions_user][:suburb]
      @competitionuser.address = params[:competitions_user][:address]
      @competitionuser.post_code = params[:competitions_user][:post_code]
      @competitionuser.here_prize = params[:competitions_user][:here_prize]
      @competitionuser.others = params[:competitions_user][:others]
      @competitionuser.total_entry = params[:competitions_user][:total_entry]
      @competitionuser.payment_type = params[:competitions_user][:payment_type]
      @competitionuser.card_name = params[:competitions_user][:card_name]
      @competitionuser.biography = params[:competitions_user][:biography]
      @competitionuser.return_of_artwork = params[:competitions_user][:return_of_artwork]
      @competitionuser.bank_account = params[:competitions_user][:bank_account]
      @competitionuser.bsb_no = params[:competitions_user][:bsb_no]
      @competitionuser.varification_code = params[:competitions_user][:varification_code]
      @competitionuser.card_number = params[:competitions_user][:card_number1] + params[:competitions_user][:card_number2] + params[:competitions_user][:card_number3] + params[:competitions_user]["card_number4"]	
      i=0
      size_array_send.each do |size|
        @competitionuser.send(size.to_sym,params[:competitions_user][size_array[i]+"1"] + params[:competitions_user][size_array[i]+"2"] + params[:competitions_user][size_array[i]+"3"])
        i=i+1
      end
      title_array = ['fworktitle=','sworktitle=','tworktitle=','foworktitle=','fiworktitle=','siworktitle=','seworktitle=','eworktitle=','nworktitle=','teworktitle=']
      i=0
      title_array.each do |title|
        @competitionuser.send(title.to_sym,params[:competitions_user][title[0..title.length-2]])
        i=i+1
      end
      medium_array = ['fworkmedium=','sworkmedium=','tworkmedium=','foworkmedium=','fiworkmedium=','siworkmedium=','seworkmedium=','eworkmedium=','nworkmedium=','teworkmedium=']
			i=0
			medium_array.each do |medium|
        @competitionuser.send(medium.to_sym,params[:competitions_user][medium[0..medium.length-2]])
        i=i+1
			end
			price_array = ['fworkprice=','sworkprice=','tworkprice=','foworkprice=','fiworkprice=','siworkprice=','seworkprice=','eworkprice=','nworkprice=','teworkprice=']
			i=0
			price_array.each do |price|
        @competitionuser.send(price.to_sym,params[:competitions_user][price[0..price.length-2]])
        i=i+1
			end
			@competitionuser.exp_date = params[:competitions_user][:exp_date1] + params[:competitions_user][:exp_date2]
			@competitionuser.user_id = current_user.id
			@competitionuser.competition_id = params[:competion_id]
			@competitionuser.price = 0
			@competitionuser.save_image(params[:competitions_user])
			@competitionuser.state =  "accepted" 
			@competitionuser.save
      flash[:notice] = "You Are Added As Competition User"
			@current_object = @competitionuser#Competition.find(params[:competionid])
		else
      @current_object = @competitionuser	
		end	
		render	:layout =>"gallery_promoting"  
	end	
	def confirm_competition_subscription_details
		@competitionuser = CompetitionsUser.find(params[:id])
		@competitionuser.confirm = true
		@competitionuser.state = 'accepted'
		@competitionuser.save
	  #  invoice = Invoice.find(:first,:conditions=>["client_id = ? and purchasable_id = ?",@competitionuser.user_id,@competitionuser.id])
    #	create_pdf(invoice.id,invoice.number,invoice.sent_at.strftime("%d %b %Y"),invoice.client.profile.full_address_for_invoice,invoice.client.profile.full_name,@competitionuser.competition.title,invoice.final_amount)#the reason for comment is same as above as everything is done after payment is done
    #here the artworks competition is get added by default it wiil be as same as users no. of entry field when he subscribe to competition
    @competitionuser.submit_artwork
    #Notifier.deliver_send_invoice(invoice,@competitionuser.user)
		#here need to check the invoice amount if it is already created and the amount is more then user should pay that much extra amount and vice a versa
		#QueuedMail.add('UserMailer', 'send_invoice',[invoice,@competitionuser.user], 0, true)	
    @order = @competitionuser
		@credit_card = CreditCard.new	
		session[:purchasable] = @competitionuser
    #flash[:notice] = "Thanks For Entering A Competition"
		#redirect_to "/admin"
		#render	:layout =>"gallery_promoting"  
		if  @competitionuser.total_entry.to_i == 0
      if request.xhr?
        render :update do |page|
          page.redirect_to "/admin/competitions/#{@competitionuser.competition.id}"
        end
      end
		end
    total_amount = 0
    @competitionuser.invoices.each {|x| total_amount = total_amount + x.final_amount}
    if  total_amount  < @order.find_price(@order.competition.id) 
		else
      @competitionuser.state = "validated"
      @competitionuser.save
      render :update do |page|
        page.redirect_to "/admin/competitions/#{@competitionuser.competition.id}"
      end
		end
	end	
	
	def edit_competition_subscription_details
		@competitions_user = CompetitionsUser.find(params[:id])
		@competitions_user.confirm = false
		@competitions_user.state ="accepted"
		@competitions_user.save
		@current_object =  @competitions_user
		render	:layout =>"gallery_promoting" 
	end
	
	def update_subscribe_competition
    if  params[:competitions_user][:payment_type]	  == "Credit Card"
      if  params[:competitions_user][:card_name].blank? or  params[:competitions_user][:card_number1].blank? or params[:competitions_user][:card_number2].blank? or params[:competitions_user][:card_number3].blank?  or params[:competitions_user][:card_number4].blank? or params[:competitions_user][:varification_code].blank? or  params[:competitions_user][:exp_date1].blank? or  params[:competitions_user][:exp_date2].blank?
        flash[:notice] = "Please Enter The Credit Card Details"
        redirect_to :back
        return
      end 
    end 
    #  if  params[:competitions_user][:fworktitle].blank? or  params[:competitions_user][:fworkmedium].blank? or params[:competitions_user][:fworksize1].blank? or  params[:competitions_user][:fworksize2].blank? or  params[:competitions_user][:fworksize3].blank? or  params[:competitions_user][:fworkprice].blank?  
		#	      flash[:notice]="Please Enter Fields Mark With * "
		#	      redirect_to :back
		#	      return
    #   end
   	         
    size_array_send = ['fworksize=','sworksize=','tworksize=','foworksize=','fiworksize=','siworksize=','seworksize=','eworksize=','nworksize=','teworksize=']
    size_array = ['fworksize','sworksize','tworksize','foworksize','fiworksize','siworksize','seworksize','eworksize','nworksize','teworksize']	   
		#return_for_size = false;      
		#      for entry in 1...params[:competitions_user][:total_entry].to_i
		#              
		#              for  i in 1..3
		#                  if(params[:competitions_user][size_array[entry]+i.to_s].blank?)
		#                  return_for_size = true;
		#                  end
		#              end  
		              
		#      end
		# if(return_for_size)    
		#     flash[:notice] = "Please Enter The Size Field Properly"
    #     redirect_to :back
    #    return
    #end
		    
    @competitions_user = CompetitionsUser.find(params[:id])
    i=0
    size_array_send.each do |size|
      @competitions_user.send(size.to_sym,params[:competitions_user][size_array[i]+"1"] + params[:competitions_user][size_array[i]+"2"] + params[:competitions_user][size_array[i]+"3"])
      i=i+1
    end
    title_array = ['fworktitle=','sworktitle=','tworktitle=','foworktitle=','fiworktitle=','siworktitle=','seworktitle=','eworktitle=','nworktitle=','teworktitle=']
    i=0
    title_array.each do |title|
      @competitions_user.send(title.to_sym,params[:competitions_user][title[0..title.length-2]])
      i=i+1
    end
    medium_array = ['fworkmedium=','sworkmedium=','tworkmedium=','foworkmedium=','fiworkmedium=','siworkmedium=','seworkmedium=','eworkmedium=','nworkmedium=','teworkmedium=']
    i=0
    medium_array.each do |medium|
			@competitions_user.send(medium.to_sym,params[:competitions_user][medium[0..medium.length-2]])
			i=i+1
    end
    price_array = ['fworkprice=','sworkprice=','tworkprice=','foworkprice=','fiworkprice=','siworkprice=','seworkprice=','eworkprice=','nworkprice=','teworkprice=']
    i=0
    price_array.each do |price|
			@competitions_user.send(price.to_sym,params[:competitions_user][price[0..price.length-2]])
			i=i+1
    end
		@competitions_user.update_attributes(params[:competitions_user])
		@competitions_user.card_number = params[:competitions_user][:card_number1] + params[:competitions_user][:card_number2] + params[:competitions_user][:card_number3] + params[:competitions_user][:card_number4]	
		@competitions_user.exp_date = params[:competitions_user][:exp_date1] + params[:competitions_user][:exp_date2]
		@competitions_user.total_entry = params[:competitions_user][:total_entry]
		@competitions_user.save_image(params[:competitions_user])
		@competitions_user.bsb_no = params[:competitions_user][:bsb_no]
		@competitions_user.competition_id = params[:competion_id]
    @competitions_user.email = params[:competitions_user][:email]
    @competitions_user.name = params[:competitions_user][:name]
		@competitions_user.suburb = params[:competitions_user][:suburb]
		@competitions_user.address = params[:competitions_user][:address]
		@competitions_user.post_code = params[:competitions_user][:post_code]
		@competitions_user.here_prize = params[:competitions_user][:here_prize]
		@competitions_user.others = params[:competitions_user][:others]
		@competitions_user.payment_type = params[:competitions_user][:payment_type]
		@competitions_user.card_name = params[:competitions_user][:card_name]
		@competitions_user.biography = params[:competitions_user][:biography]
		@competitions_user.return_of_artwork = params[:competitions_user][:return_of_artwork]
		@competitions_user.bank_account = params[:competitions_user][:bank_account]
		@competitions_user.varification_code = params[:competitions_user][:varification_code]
		@competitions_user.save
		#@competitions_user.generate_invoice_update(@competitions_user.user_id,@competitions_user.id)
		#Notifier.deliver_subscription_detail_mail("mark@bsgart.com.au",current_user.email,"",current_user.profile.first_name + " " + current_user.profile.last_name ,@competitionuser.competition.title,@competitionuser.competition.submission_deadline)
   	#invoice = Invoice.find(:first,:conditions=>["client_id = ? and purchasable_id = ?",@competitions_user.user_id,@competitions_user.id])
		#create_pdf(invoice.id,invoice.number,invoice.sent_at.strftime("%d %b %Y"),invoice.client.profile.full_address_for_invoice,invoice.client.profile.full_name,@competitions_user.competition.title,invoice.final_amount)
    #Notifier.deliver_send_invoice(invoice,@competitionuser.user)
		#QueuedMail.add('UserMailer', 'send_invoice',[invoice,@competitions_user.user], 0, true)	
    #email= UserMailer.create_send_invoice(invoice,@competitions_user.user)
    #UserMailer.deliver(email)
    flash[:notice]="You Have Succeffully Updated Competition subscription"
		redirect_to ("/admin/competitions/create_subscribe_competition/?competion_id=#{@competitions_user.competition_id}")
	end	
	
	####################################the below method will be the ajax call from front page 
	#here after the user click on click here to competition the form will get opened. after the submission of that form
	# the following method get called so i need the card detail 
  def create_subscribe_competition_front
    @competitionuser = CompetitionsUser.find_by_user_id_and_competition_id(current_user.id,params[:id])
    @competition = Competition.find(params[:id])
    if  @competitionuser.blank?
      #this array might be used later
      @competitionuser = CompetitionsUser.new()
      @competitionuser.email = current_user.email
      @competitionuser.name = current_user.profile.first_name + " " + current_user.profile.last_name
      @competitionuser.suburb = current_user.profile.suburb
      @competitionuser.address = current_user.profile.address
      @competitionuser.post_code = current_user.profile.zip_code
      @competitionuser.user_id = current_user.id
      @competitionuser.competition_id = params[:id]
      @competitionuser.price = 0
      @competitionuser.state =  "accepted" 
      @competitionuser.save
      @current_object = @competitionuser#Competition.find(params[:competionid])
    else
      @current_object = @competitionuser	
    end	
	  ###############################################this is copy of confirm competition subscription details
    @competitionuser.confirm = true
    @competitionuser.state = 'accepted'
    @competitionuser.save
    @order = @competitionuser
    @credit_card = CreditCard.find_by_user_id(current_user.id)
    if @credit_card.blank?
      @credit_card = CreditCard.new	
    end
    session[:purchasable] = @competitionuser
    render :update do |page|
      page["enterintocompetitionfront"].replace_html :partial=>"enter_compitition_payment",:locals=>  {:order=>@order,:credit_card=>@credit_card,:competition=>@competition,:order_id=>@competitionuser.id}
      page["enterintocompetition"].show
      page["list_show"].hide
      page["buylist"].hide
    end
  end  
  
  #this will render the login page when click here all other things will be hidden and whereever the hidden is written i will add this there
  #the form will contain the login form and redirect after login is done on the same page else show the error
  #i have created the partial to show the login page.the errors will be shown on the top of form.when the competition show is get displayed ]]
  #without a login at that time only the pictures are shown. the login form will be same as sessions /login
  def create_subscribe_competition_front_login
    
   session[:compredirecid] = params[:id]
    render :update do |page|
      page["buylist"].hide
      page["loginform"].replace_html :partial=>"create_subscribe_competition_front_login"
      page["iteam_imagelogin"].show
    end
  end
 
   #this will render the registration page. this will open the registratin form which need to be in same size and errors will be shown in one 
   #more div 
  def create_subscribe_competition_front_register
    		@current_object = User.new
		@current_object.build_profile if @current_object.profile.nil?
     session[:compredirecid] = params[:id]
    render :update do |page|
      page["buylist"].hide
      page["registerform"].replace_html :partial=>"create_subscribe_competition_front_register"
      page["iteam_imageregister"].show
    end
  end  
  
   
  def  create_the_payment
    creditcardno = ""
    if ((params[:invoicing_info][:payment_medium] ==  "visa") or (params[:invoicing_info][:payment_medium] ==  "paypal") or (params[:invoicing_info][:payment_medium] ==  "master card")  )         
      credit_card = CreditCard.find_by_user_id(current_user.id)
      if credit_card.blank?
        credit_card = CreditCard.new()
      end
      credit_card.number = params[:credit_card][:number0]+params[:credit_card][:number1]+params[:credit_card][:number2]+params[:credit_card][:number3]+params[:credit_card][:number4]+params[:credit_card][:number5]+params[:credit_card][:number6]+params[:credit_card][:number7]+params[:credit_card][:number8]+params[:credit_card][:number9]+params[:credit_card][:number10]+params[:credit_card][:number11]+params[:credit_card][:number12]+params[:credit_card][:number13]+params[:credit_card][:number14]+params[:credit_card][:number15]
      credit_card.user_id = current_user.id
      credit_card.expiring_date = Date.civil(params[:credit_card]["expiring_date(1i)"].to_i,params[:credit_card]["expiring_date(2i)"].to_i,params[:credit_card]["expiring_date(3i)"].to_i).strftime("%y-%m-%d")       
      credit_card.first_name = params[:credit_card][:first_name]
      credit_card.last_name = params[:credit_card][:last_name]
      credit_card.verification_value = params[:credit_card][:verification_value]
    
      credit_card.save!
      
    
      creditcardno = credit_card.number
    else
    end 
     
    #######################################this is im copying here is something from payment controller create method
    if params[:order_id]
      @order = CompetitionsUser.find(params[:order_id])
      current_user.profile.biography = params[:biography]
      current_user.profile.save
    else  
      @order = session[:purchasable]  
    end  
    session[:order] = @order
    session[:invoice_id] = params[:invoice_id]
    #@order.total_entry = params[:competitions_user][:total_entry]
    #@order.save
    if  params[:competitions_user][:total_entry] == "0"
      render :update do |page|
              page["modal_space_answer"].replace_html "Please Select The Entry"  
              page["modal_space_answer"].show
              page["show_ajax_request"].hide
      end        
      
      return
    end  
    @current_object = Payment.new(params[:payment])		#@invoice = session[:invoice]		
    if     @order.instance_of? ExhibitionsUser
      @current_object.amount_in_cents =params[:invoice_amount].to_i*100
    elsif  @order.instance_of? CompetitionsUser
      @current_object.amount_in_cents = (@order.find_price_total_entry(@order.competition.id,params[:competitions_user][:total_entry].to_i) ) * 100
    else 
    end
    session[:total_entry] = params[:competitions_user][:total_entry]
    session[:current_object] = @current_object
    @current_object.user = @current_user		#@current_object.invoice = @invoice
    if  @order.instance_of? ExhibitionsUser
      if params[:invoicing_info][:payment_medium] ==  "visa" or params[:invoicing_info][:payment_medium] ==  "master card" 
        @current_object.common_wealth_bank_process((params[:invoice_amount].to_i*100),params)
      elsif  params[:invoicing_info][:payment_medium] ==  "cash"  or   params[:invoicing_info][:payment_medium] ==  "cheque" or params[:invoicing_info][:payment_medium] ==  "direct deposit"
	                       
      elsif  params[:invoicing_info][:payment_medium] ==  "paypal"  
        @current_object.make_paypal_payment((params[:invoice_amount].to_i),params) 
      end
    elsif    @order.instance_of? CompetitionsUser
      if @order.invoices.last   
        total_amount = 0
        @order.invoices.each {|x| total_amount = total_amount + x.final_amount}
        if  total_amount  < @order.find_price_total_entry(@order.competition.id,params[:competitions_user][:total_entry].to_i) 
          more_amount = (@order.find_price_total_entry(@order.competition.id,params[:competitions_user][:total_entry].to_i) ) -  total_amount
          @current_object.amount_in_cents = more_amount * 100
          if params[:invoicing_info][:payment_medium] ==  "visa" or params[:invoicing_info][:payment_medium] ==  "master card"  
            @current_object.common_wealth_bank_process((more_amount * 100),params,creditcardno)
              
            if @current_object.state == "online_validated"
              @order.total_entry = params[:competitions_user][:total_entry]
              @order.save              
            end
          elsif  params[:invoicing_info][:payment_medium] ==  "cash"  or   params[:invoicing_info][:payment_medium] ==  "cheque"  or  params[:invoicing_info][:payment_medium] ==  "direct deposit"
            @order.total_entry = params[:competitions_user][:total_entry]
            @order.save              
          elsif  params[:invoicing_info][:payment_medium] ==  "paypal"  
            session[:paypal_amount] = (more_amount * 100)
            set_the_token#from here i need to redirect him to paypal after getting the token
            session[:competition_id] = @order.competition.id
            session[:current_object_id] = @current_object
            render :update do |page|
              page["modal_space_answer"].hide                                     
              page["paypal_form"].replace_html :partial=>"paypal_form",:locals=>{:token =>@token,:amt=>(more_amount * 100)}
              page.call 'submit_my_form'
            end
            return
            #@current_object.make_paypal_payment((more_amount * 100),params) 
          end
        else
        
           render :update do |page|
             page["modal_space_answer"].replace_html  :text=>"You Did not changed the entry field or if  you decremented it then send email to admin  "                                     
             page["show_ajax_request"].hide
             page["modal_space_answer"].show
          end
          return
        end   
      else
        if params[:invoicing_info][:payment_medium] ==   "visa" or params[:invoicing_info][:payment_medium] ==  "master card" 
          @current_object.common_wealth_bank_process(((@order.find_price_total_entry(@order.competition.id,params[:competitions_user][:total_entry].to_i) ) * 100),params,creditcardno)#payment is done if invoice is not yet  created. for competition user
          if @current_object.state == "online_validated"
            @order.total_entry = params[:competitions_user][:total_entry]
            @order.save              
          end
                                           
        elsif  params[:invoicing_info][:payment_medium] ==  "cash"  or   params[:invoicing_info][:payment_medium] ==  "cheque" or  params[:invoicing_info][:payment_medium] ==  "direct deposit"
          @order.total_entry = params[:competitions_user][:total_entry]
          @order.save              
        elsif  params[:invoicing_info][:payment_medium] ==  "paypal"  
          session[:paypal_amount]=((@order.find_price_total_entry(@order.competition.id,params[:competitions_user][:total_entry].to_i)) * 100)
          set_the_token#from here i need to redirect him to paypal after getting the token
          session[:competition_id] = @order.competition.id
          session[:current_object_id] = @current_object
          render :update do |page|
            page["modal_space_answer"].hide                                     
            page["paypal_form"].replace_html :partial=>"paypal_form",:locals=>{:token =>@token,:amt=>((@order.find_price_total_entry(@order.competition.id,params[:competitions_user][:total_entry].to_i)) * 100)}
            page.call 'submit_my_form'
          end
          return
          #@current_object.make_paypal_payment(((@order.find_price(@order.competition.id) ) * 100),params) 
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
          if  total_amount  < @order.find_price_total_entry(@order.competition.id,params[:competitions_user][:total_entry].to_i) 
            make_the_payment
            #flash[:notice] = "Your Extra Selected Entry Payment Is Done <a href='/admin/competitions/#{@order.competition.id}'>Go Back To see the competition</a>"
            #render :partial=>"extra_payment_done",:locals=>{:competition=>@order.competition,:order=>@order} 
            add_the_artwork_intopaymentdiv
            return        
          else
            #                  flash[:error] = "Your Payment Is Already Done Please Go To Home Page  <a href='/admin/competitions/#{@order.competition.id}'>Go Back To see the competition</a>"
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
        if   params[:invoicing_info][:payment_medium] ==  "cash"  or   params[:invoicing_info][:payment_medium] ==  "cheque" or  params[:invoicing_info][:payment_medium] ==   "direct deposit"
          render :text=>"After Your Payment Is Done Admin  Will Validate You. After That Your Artwork Will Be Selected.   <a href='/admin/exhibitions/#{@order.exhibition.id}'>Select Artwork</a>"
        else
          invoice = Invoice.find(:last,:conditions=>["purchasable_type = ? and  client_id = ? and purchasable_id = ?","ExhibitionsUser" , @order.user,@order.id])
          if  invoice.state == "created"
              note = "no note created"
              note = @order.exhibition.timing.note if @order.exhibition.timing
            create_pdf(invoice.id,invoice.number,invoice.sent_at.strftime("%d %b %Y"),invoice.client.profile.full_address_for_invoice,invoice.client.profile.full_name_for_invoice,@order.exhibition.title,invoice.final_amount.to_i,note)
            QueuedMail.add( 'UserMailer',  'send_invoice_exhibition', [@current_object.user.profile.email_address,"invoice#{invoice.id}","Your Exhibition Payment Is Done And An Invoice Is Sent to Your Email.",invoice, @current_object.user],0,true,@current_object.user.profile.email_address,"test@pragtech.co.in") 
          end    
          render :text=>"Your Payment Is Done Now Upload And Then Select The Artworks  <a href='/admin/exhibitions/#{@order.exhibition.id}'>Select Artwork</a>"
        end            
      elsif  @order.instance_of? CompetitionsUser
        if   params[:invoicing_info][:payment_medium] ==  "cash"  or   params[:invoicing_info][:payment_medium] ==  "cheque"  or  params[:invoicing_info][:payment_medium] ==   "direct deposit"
          #render :text=>"After Your Payment Is Done Admin  Will Validate You. After That Your Artwork Will Be Selected.  Please Make The Payment Before #{@order.submission_date} <a href='/admin/competitions/#{@order.competition.id}'>Go Back To see the competition</a>"

          render :partial=> "cash_cheque_response",:locals=>{:competition_id=>@order.competition.id,:artwork_count=>0,:order_id=>@order.id,:total_entry=>@order.total_entry}
                                   
        else
                                  
          #session[:total_entry] = @order.total_entry
          #render :update do |page|
          # session[:store_for_submitting_the_artwork] = @order.id
          #page["show_me_the_error"].replace_html :partial=>"add_artwork_link",:locals=>{:competition_id=>@order.competition.id,:artwork_count=>0,:order_id=>@order.id}
                                      
          #end
  
          #render :partial=>"add_artwork_link",:locals=>{:competition_id=>@order.competition.id,:artwork_count=>0,:order_id=>@order.id}
          #instead of this the response is a div which shows the upload artwork div
          add_the_artwork_intopaymentdiv
          #render :text=>"Your Payment Is Done . The Invoice Is Sent To You By Email.   <a href='/admin/competitions/#{@order.competition.id}'>Go Back To see the competition</a>"
      	                              
        end     	       
      end
    else
      if params[:invoicing_info][:payment_medium] ==  "cash"  or   params[:invoicing_info][:payment_medium] ==  "cheque"  or params[:invoicing_info][:payment_medium] ==   "direct deposit"
        if  @order.instance_of? CompetitionsUser
          make_the_payment
        else
          make_the_payment_exhibition
          invoice = Invoice.find(:last,:conditions=>["purchasable_type = ? and  client_id = ? and purchasable_id = ?","ExhibitionsUser" , @order.user,@order.id])
          if  invoice.state == "created"
            note = "no note is created"
            note = @order.exhibition.timing.note if @order.exhibition.timing
            create_pdf(invoice.id,invoice.number,invoice.sent_at.strftime("%d %b %Y"),invoice.client.profile.full_address_for_invoice,invoice.client.profile.full_name_for_invoice,@order.exhibition.title,invoice.final_amount.to_i,note)
            QueuedMail.add('UserMailer', 'send_invoice_exhibition', [invoice, @order.user], 0, true)
          end       
        end      
        if  @order.instance_of? CompetitionsUser   
          #  render :text=>"After Your Payment Is Done Admin  Will Validate You. After That Your Artwork Will Be Selected.  Please Make The Payment Before #{@order.competition.submission_deadline} <a href='/admin/competitions/#{@order.competition.id}'>Go Back To see the competition</a>"
          # render :partial=> "cash_cheque_response",:locals=>{:competition_id=>@order.competition.id,:artwork_count=>0,:order=>@order,:total_entry=>@order.total_entry}
          add_the_artwork_intopaymentdiv
         
          return                  
        else
          render :text=>"After Your Payment Is Done Admin  Will Validate You. After That Your Artwork Will Be Selected.  <a href='admin/exhibitions/#{@order.exhibition.id}'>Select Artwork</a>"
        end            	       
        return
      end
	    #flash[:error] = 'Error during the payment save  '+@current_object.state.to_s
        render :update do |page|
             page["modal_space_answer"].replace_html  :text=>'Your payment has not been successful. Please check your details and try again '                                     
             page["show_ajax_request"].hide
             page["modal_space_answer"].show
          end
       
    end
  end  
 
   
  #this method is for adding the artork from front


  def add_the_artwork
    title_array = ['fworktitle','sworktitle','tworktitle','foworktitle','fiworktitle','siworktitle','seworktitle','eworktitle','nworktitle','teworktitle']
    order = CompetitionsUser.find(params[:order_id]) 
    i=0
    for title in title_array
      if (order.send (title_array[i].to_sym)).blank?
        break
      end  
      i=i+1    
    end 
    render :update do |page|
      if order.total_entry.to_i > i  
        page["add_the_artwork0"].replace_html :partial=>"add_the_artwork",:locals=>{:competition_id => params[:competition_id],:order_id=>order.id,:messageforimageuploaded=>nil,:i=>i,:total_entry=>order.total_entry.to_i}
        page["enterartworkcompetition"].show
        page["add_the_artwork0"].show
        page["iteam_image0"].show
      else  
        page.alert("Your Limit Is Over")
        page["messageforimageuploaded"].replace_html "Your Limit Is Over Can Not Save The Image"
      end  
    end
  end  

  def add_the_artwork_intopaymentdiv
    title_array = ['fworktitle','sworktitle','tworktitle','foworktitle','fiworktitle','siworktitle','seworktitle','eworktitle','nworktitle','teworktitle']
    i=0
    for title in title_array
      if (@order.send (title_array[i].to_sym)).blank?
        break
      end  
      i=i+1    
    end 
  
    if params[:invoicing_info][:payment_medium] ==  "cash"  
      messageforimageuploaded  = "After Your Payment Is Done Admin Will Validate You"
    end   
    if params[:invoicing_info][:payment_medium] ==  "cheque" 
      messageforimageuploaded  = "After Your Payment Is Done Admin Will Validate You"
    end
    if params[:invoicing_info][:payment_medium] ==   "direct deposit"
      messageforimageuploaded  = "After Your Payment Is Done Admin Will Validate You"
    end
    if params[:invoicing_info][:payment_medium] ==  "visa" or params[:invoicing_info][:payment_medium] ==  "master card"
      messageforimageuploaded="Your Payment Is Done Please Upload Artwok"
    end
    
    
    

    render :update do |page|
      if @order.total_entry.to_i > i  
       # page.alert("Thank you for entering the 2011 Small Works Prize. An invoice has been emailed to you");
        page["add_the_artwork#{i}"].replace_html :partial=>"add_the_artwork",:locals=>{:competition_id => @order.competition_id,:order_id=>@order.id,:messageforimageuploaded=>messageforimageuploaded,:i=>i,:total_entry=>@order.total_entry.to_i}
        page["pleaseaccepttermsandcondition"].hide
        page["pleaseaccepttccheckbox"].hide
        page["show_ajax_request"].hide
        page["list_show"].show
        page["iteam_image#{i}"].show
        page["add_the_artwork#{i}"].show
        page["add_the_artwork#{i}"].focus
        page["modal_space_answer"].hide
        
        for j in i+1..20
          page["iteam_image#{j}"].hide
        end
        
      else  
        page.alert("Your Limit Is Over")
        page["messageforimageuploaded"].replace_html "Your Limit Is Over Can Not Save The Image"
      end  
    end
  end  





  def  add_the_artwork_to_competition
    size_array = ['fworksize=','sworksize=','tworksize=','foworksize=','fiworksize=','siworksize=','seworksize=','eworksize=','nworksize=','teworksize=']
    title_array = ['fworktitle=','sworktitle=','tworktitle=','foworktitle=','fiworktitle=','siworktitle=','seworktitle=','eworktitle=','nworktitle=','teworktitle=']
    medium_array = ['fworkmedium=','sworkmedium=','tworkmedium=','foworkmedium=','fiworkmedium=','siworkmedium=','seworkmedium=','eworkmedium=','nworkmedium=','teworkmedium=']
    price_array = ['fworkprice=','sworkprice=','tworkprice=','foworkprice=','fiworkprice=','siworkprice=','seworkprice=','eworkprice=','nworkprice=','teworkprice=']
 		if params[:competitionuserid]
 		  @order = CompetitionsUser.find(params[:competitionuserid]) 		 
  	else  
      # @order = CompetitionsUser.find(session[:store_for_submitting_the_artwork]) 		 
   	end  
    if  @order.instance_of? CompetitionsUser
      i=1
      title_array.each do |title|
        @order.send(title.to_sym,params[:competitions_user][i.to_s+"worktitle"])
        i=i+1
      end
      i=1
      medium_array.each do |med|
        @order.send(med.to_sym,params[:competitions_user][i.to_s+"workmedium"])
        i=i+1
      end  
      i=1
      price_array.each do |med|
        @order.send(med.to_sym,params[:competitions_user][i.to_s+"workprice"])
        i=i+1
      end  
      i=1
      size_array.each do |siz|
        totalsize = params[:competitions_user][i.to_s+"worksize1"].to_s+"x"+params[:competitions_user][i.to_s+"worksize2"].to_s+"x"+params[:competitions_user][i.to_s+"worksize3"].to_s
        @order.send(siz.to_sym,totalsize)
        i=i+1
      end  
       
      @order.save_image(params[:competitions_user])
      @order.submit_artwork
      @order.save
    end
    
    #render :update do |page|
    #  page.redirect_to "/"
    #  page.alert("your artwork is submited")
    #end
    flash[:notice]="Your Artwork Is Uploaded"
    

    
    redirect_to "/"
    
    
    
  end  


  def upload_the_artwork_to_competition
    size_array = ['fworksize=','sworksize=','tworksize=','foworksize=','fiworksize=','siworksize=','seworksize=','eworksize=','nworksize=','teworksize=']
    title_array_send = ['fworktitle=','sworktitle=','tworktitle=','foworktitle=','fiworktitle=','siworktitle=','seworktitle=','eworktitle=','nworktitle=','teworktitle=']
    medium_array = ['fworkmedium=','sworkmedium=','tworkmedium=','foworkmedium=','fiworkmedium=','siworkmedium=','seworkmedium=','eworkmedium=','nworkmedium=','teworkmedium=']
    price_array = ['fworkprice=','sworkprice=','tworkprice=','foworkprice=','fiworkprice=','siworkprice=','seworkprice=','eworkprice=','nworkprice=','teworkprice=']
    editionnamearray=['fworkedname=','sworkedname=','tworkedname=','foworkedname=','fiworkedname=','siworkedname=','seworkedname=','eiworkedname=','niworkedname=','teworkedname=']
    editionnumberarray=['fworkednumber=','sworkednumber=','tworkednumber=','foworkednumber=','fiworkednumber=','siworkednumber=','seworkednumber=','eiworkednumber=','niworkednumber=','teworkednumber=']
    title_message_array = ['First Work','Second Work',' Third Work','Fourth Work','Fifth Work','Sixth Work','Seventh Work','Eight Work','Ninth Work','Tenth Work']

    order = CompetitionsUser.find(params[:order_id])
    i=0
    title_array = ['fworktitle','sworktitle','tworktitle','foworktitle','fiworktitle','siworktitle','seworktitle','eworktitle','nworktitle','teworktitle']
    for title in title_array
      if (order.send (title_array[i].to_sym)).blank?
        break
      end  
      i=i+1    
    end  
  
    if order.total_entry.to_i > i
      
      
      order.send(title_array_send[i].to_sym,params[:competitions_user]["worktitle"])
      order.send(medium_array[i].to_sym,params[:competitions_user]["workmedium"]) 
      order.send(price_array[i].to_sym,params[:competitions_user]["workprice"])
      order.send(editionnamearray[i].to_sym,params[:competitions_user]["editionname"])
      order.send(editionnumberarray[i].to_sym,params[:competitions_user]["editionnumber"])
      
      totalsize = params[:competitions_user]["worksize1"].to_s+"x"+params[:competitions_user]["worksize2"].to_s+"x"+params[:competitions_user]["worksize3"].to_s
      order.send(size_array[i],totalsize)
      order.save_image(params[:competitions_user],i)
      order.submit_artwork(params[:competitions_user],i)
      order.save
      
      
    end 
   # i=i+1#this is because the artwork will be shown in next "add_the_artwork#{i}"
   
    responds_to_parent do
      render :update do |page|
        if order.total_entry.to_i > i
          
          
		      page["add_the_artwork#{i+1}"].replace_html :partial=>"add_the_artwork",:locals=>{:competition_id => params[:competition_id],:order_id=>order.id,:messageforimageuploaded=>"Your #{title_message_array[i]} Is Saved",:i=>i+1,:total_entry=>order.total_entry.to_i,:com_id=>order.competition.id}
          
		      #page["click_to_browse_images"].replace_html :partial=>"click_to_browse_images" ,:locals=>{:competition_id=>order.competition_id,:order_id=>order.id}
		      #page["click_to_browse_images"].show
          page["list_show"].show
          page["iteam_image#{i+1}"].show
          page["add_the_artwork#{i+1}"].show
          page["show_ajax_request#{i}"].hide
        else  
          page["show_ajax_request#{i-1}"].hide  
          page.alert("Your Limit Is Over.Click Browse Image For Updating The Image");
          page["messageforimageuploaded"].replace_html "Artwork Can Not Be Save "
        end  
      end
    end      
  end  
   
  def upload_the_biography

    current_user.profile.biography = params[:biography]
    current_user.profile.save
    order = CompetitionsUser.find(params[:order_id])
    render :update do |page|
        page["add_the_artwork#{params[:total_entry].to_i+1}"].replace_html order.competition.notes
        page["pleaseaccepttermsandcondition"].hide
        page["pleaseaccepttccheckbox"].hide
        page["show_ajax_request"].hide
        page["list_show"].show
        page["iteam_image#{params[:total_entry].to_i+1}"].show
        page["add_the_artwork#{params[:total_entry].to_i+1}"].show
        page["show_ajax_request#{params[:total_entry].to_i}"].hide
    end
  end
   
  def edit_upload_the_artwork_to_competition
    image_array = ['fworkimage','sworkimage','tworkimage','foworkimage','fiworkimage','siworkimage','seworkimage','eworkimage','nworkimage','teworkimage']	
    size_array_send = ['fworksize=','sworksize=','tworksize=','foworksize=','fiworksize=','siworksize=','seworksize=','eworksize=','nworksize=','teworksize=']
    size_array = ['fworksize','sworksize','tworksize','foworksize','fiworksize','siworksize','seworksize','eworksize','nworksize','teworksize']
    medium_array = ['fworkmedium','sworkmedium','tworkmedium','foworkmedium','fiworkmedium','siworkmedium','seworkmedium','eworkmedium','nworkmedium','teworkmedium']
    medium_array_send = ['fworkmedium=','sworkmedium=','tworkmedium=','foworkmedium=','fiworkmedium=','siworkmedium=','seworkmedium=','eworkmedium=','nworkmedium=','teworkmedium=']
 	  title_array_send = ['fworktitle=','sworktitle=','tworktitle=','foworktitle=','fiworktitle=','siworktitle=','seworktitle=','eworktitle=','nworktitle=','teworktitle=']
    price_array_send = ['fworkprice=','sworkprice=','tworkprice=','foworkprice=','fiworkprice=','siworkprice=','seworkprice=','eworkprice=','nworkprice=','teworkprice=']
    price_array = ['fworkprice','sworkprice','tworkprice','foworkprice','fiworkprice','siworkprice','seworkprice','eworkprice','nworkprice','teworkprice']
 	  editionnamearray = ['fworkedname=','sworkedname=','tworkedname=','foworkedname=','fiworkedname=','siworkedname=','seworkedname=','eiworkedname=','niworkedname=','teworkedname=']
    editionnumberarray = ['fworkednumber=','sworkednumber=','tworkednumber=','foworkednumber=','fiworkednumber=','siworkednumber=','seworkednumber=','eiworkednumber=','niworkednumber=','teworkednumber=']
    editionnamearrayv = ['fworkedname','sworkedname','tworkedname','foworkedname','fiworkedname','siworkedname','seworkedname','eiworkedname','niworkedname','teworkedname']
    editionnumberarrayv = ['fworkednumber','sworkednumber','tworkednumber','foworkednumber','fiworkednumber','siworkednumber','seworkednumber','eiworkednumber','niworkednumber','teworkednumber']
    
    order = CompetitionsUser.find(params[:competitionuserid])
    i=0
    title_array = ['fworktitle','sworktitle','tworktitle','foworktitle','fiworktitle','siworktitle','seworktitle','eworktitle','nworktitle','teworktitle']
    i = title_array.index params[:titleforupdate]
    order.send(title_array_send[i].to_sym,params[:competitions_user]["worktitle"])
    order.send(medium_array_send[i].to_sym,params[:competitions_user]["workmedium"]) 
    order.send(price_array_send[i].to_sym,params[:competitions_user]["workprice"]) 
    order.send(editionnamearray[i].to_sym,params[:competitions_user]["editionname"]) 
    order.send(editionnumberarray[i].to_sym,params[:competitions_user]["editionnumber"]) 
    totalsize = params[:competitions_user]["worksize1"].to_s+"x"+params[:competitions_user]["worksize2"].to_s+"x"+params[:competitions_user]["worksize3"].to_s
    order.send(size_array_send[i],totalsize)
    order.save_image(params[:competitions_user],i)
    order.submit_artwork(params[:competitions_user],i)
    order.save
    updateimagearray=[]
    updateimagearray << order.send(title_array[i].to_sym)
    updateimagearray << order.send(medium_array[i].to_sym)
    updateimagearray << order.send(size_array[i].to_sym)
    updateimagearray << order.send(image_array[i])
    updateimagearray << order.send(price_array[i].to_sym)
    updateimagearray << order.send(editionnamearrayv[i].to_sym)
    updateimagearray << order.send(editionnumberarrayv[i].to_sym)
    updateimagearray << title_array[i]
    responds_to_parent do
      render :update do |page|
        page["editartwork"+params[:titleforupdate]].replace_html :partial=>"editcompartwork",:locals=>{:competitionuser => params[:competitionuserid],:order_id=>order.id,:messageforimageuploaded=>"Your Artwork Is Changed",:updateimagearray=>updateimagearray}
      end  
    end  
  end  
   
   

  #############################################this is im copying is basically for the methods called in payment create method and which is i copied at above

  def  make_order_payment
    session[:purchasable] = nil
    @current_object.amount_in_cents =  @order.total_amount*100
    @invoice = @order.generate_invoice(@current_user, params[:invoicing_info]) 
    if params[:invoicing_info][:payment_medium] ==   "visa" or params[:invoicing_info][:payment_medium] ==  "master card" 
      @current_object.common_wealth_bank_process(@order.total_amount*100,params)
    elsif  params[:invoicing_info][:payment_medium] ==  "cash"  or   params[:invoicing_info][:payment_medium] ==  "cheque" or  params[:invoicing_info][:payment_medium] ==  "direct deposit"
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
      if   params[:invoicing_info][:payment_medium] ==  "cash"  or   params[:invoicing_info][:payment_medium] ==  "cheque" or  params[:invoicing_info][:payment_medium] ==  "direct deposit"
        session[:cart] ={}
        @invoice.accept_cash_or_cheque_or_bank_payment(params[:invoicing_info][:payment_medium])                        
        render :text=>"After Your Payment Is Done Admin  Will Validate You. The Invoice Is Sent To You By Email.   "
      else

        render :text=>"There Is Error In Payment    Please Try Again"
      end 
    end  
    note = "no note created"
    create_pdf(@invoice.id,@invoice.number,@invoice.sent_at.strftime("%d %b %Y"),@invoice.client.profile.full_address_for_invoice,@invoice.client.profile.full_name_for_invoice,@order.title,@invoice.final_amount.to_i,nil)
    begin
      email= UserMailer.create_send_invoice(@invoice,@current_user)
      UserMailer.deliver(email)        	
    rescue
    end
  end
  
  
  
  def  make_the_payment_exhibition
    session[:purchasable] = nil
    @invoice = Invoice.find(params[:invoice_id])
    if params[:invoicing_info][:payment_medium] ==  "cash"  or   params[:invoicing_info][:payment_medium] ==  "cheque" or  params[:invoicing_info][:payment_medium] ==  "direct deposit"
      @invoice.accept_cash_or_cheque_or_bank_payment(params[:invoicing_info][:payment_medium]) 
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

    if params[:invoicing_info][:payment_medium] ==  "cash"  or   params[:invoicing_info][:payment_medium] ==  "cheque" or  params[:invoicing_info][:payment_medium] ==  "direct deposit"
      @invoice.accept_cash_or_cheque_or_bank_payment(params[:invoicing_info][:payment_medium]) 
    elsif params[:invoicing_info][:payment_medium] == "paypal"
      @invoice.validating("paypal")
    else
      @invoice.validating
    end     	
    @current_object.invoice = @invoice
    @current_object.save
    invoice = Invoice.find(:last,:conditions=>["client_id = ? and purchasable_id = ?",@current_user.id,@order.id])
    if @order.instance_of? CompetitionsUser
      note = "no notes created"
      note = @order.competition.timing.note if @order.competition.timing
      start_date = @order.competition.timing.starting_date.strftime("%d %b %Y")
      end_date = @order.competition.timing.ending_date.strftime("%d %b %Y")
      if params[:invoicing_info][:payment_medium] ==  "cash" or   params[:invoicing_info][:payment_medium] ==  "cheque" or    params[:invoicing_info][:payment_medium] ==  "direct deposit"
          create_pdf(invoice.id,invoice.number,start_date,invoice.client.profile.full_address_for_invoice,invoice.client.profile.full_name_for_invoice,@order.competition.title,invoice.final_amount.to_i,note,invoice.final_amount.to_i,0,false,end_date)
      else
          create_pdf(invoice.id,invoice.number,invoice.sent_at.strftime("%d %b %Y"),invoice.client.profile.full_address_for_invoice,invoice.client.profile.full_name_for_invoice,@order.competition.title,invoice.final_amount.to_i,note,"",invoice.final_amount.to_i,false,end_date)
      end
    elsif  @order.instance_of? ExhibitionsUser
      note = "no notes created"
      note = @order.exhibition.timing.note if @order.exhibition.timing
      create_pdf(invoice.id,invoice.number,invoice.sent_at.strftime("%d %b %Y"),invoice.client.profile.full_address_for_invoice,invoice.client.profile.full_name_for_invoice,@order.exhibition.title,invoice.final_amount.to_i,note)
    end
    #QueuedMail.add('UserMailer', 'send_invoice',[@invoice,@current_user], 0, send_now=true)	
    #QueuedMail.create(:mailer => 'UserMailer', :mailer_method => 'send_invoice',:args => [@current_user.profile.email_address,"invoice#{invoice.id}","An Invoice Is Send To Your Email For Your Payment"],:priority => 0,:tomail=>@current_user.profile.email_address,:frommail=>"test@pragtech.co.in")
    begin
    email= UserMailer.create_send_invoice(invoice,@current_user)
    UserMailer.deliver(email)
    rescue
    end
    session[:total_entry] = nil                     
    if  @invoice.purchasable_type == "Order"
      session[:cart]=nil
    end
  end
    

  def create_subscribe_competition_front_edit
    @credit_card = CreditCard.find_by_user_id(current_user.id)
    #im writing this because some old people in database may not have credit card
    if @credit_card.blank?
      @credit_card = CreditCard.new
    end		
    @competition = Competition.find(params[:id])
    @order = CompetitionsUser.find(params[:order_id])
    if request.xhr?
      render :update do |page|
        page["enterintocompetitionfront"].replace_html :partial=>"edit_compitition_payment",:locals=>  {:order=>@order,:credit_card=>@credit_card,:competition=>@competition}
        page["enterintocompetition"].show
        page["list_show"].hide
        page["buylist"].hide
      end
    end   
  end  

   #according to the status of the competition the alert message will be shown to user. if it is open then the message will be shown.if it is 
   #if it is final published then different message is shown and if it is result publich then different message is shown
  def edit_images_front
    image_array = ['fworkimage','sworkimage','tworkimage','foworkimage','fiworkimage','siworkimage','seworkimage','eworkimage','nworkimage','teworkimage']	
    title_array = ['fworktitle','sworktitle','tworktitle','foworktitle','fiworktitle','siworktitle','seworktitle','eworktitle','nworktitle','teworktitle'] 
    medium_array = ['fworkmedium','sworkmedium','tworkmedium','foworkmedium','fiworkmedium','siworkmedium','seworkmedium','eworkmedium','nworkmedium','teworkmedium']
    size_array = ['fworksize','sworksize','tworksize','foworksize','fiworksize','siworksize','seworksize','eworksize','nworksize','teworksize']
    price_array = ['fworkprice','sworkprice','tworkprice','foworkprice','fiworkprice','siworkprice','seworkprice','eworkprice','nworkprice','teworkprice']
    editionnamearray = ['fworkedname','sworkedname','tworkedname','foworkedname','fiworkedname','siworkedname','seworkedname','eiworkedname','niworkedname','teworkedname']
    editionnumberarray = ['fworkednumber','sworkednumber','tworkednumber','foworkednumber','fiworkednumber','siworkednumber','seworkednumber','eiworkednumber','niworkednumber','teworkednumber']
    @competition = Competition.find(params[:id])
    @competitions_user = CompetitionsUser.find(params[:order_id])
    @image_array = []
    i=0;
    add_art_cnt = 0
    counttodisplayviwform=0
    for eachimage in image_array
      #first i will append the title
      if  !@competitions_user.send(eachimage.to_sym).blank? 
        image_arrayi=[]
        image_arrayi << @competitions_user.send(title_array[i].to_sym)
        image_arrayi << @competitions_user.send(medium_array[i].to_sym)
        image_arrayi << @competitions_user.send(size_array[i].to_sym)
        image_arrayi << @competitions_user.send(eachimage.to_sym)
        #if !@competitions_user.send(eachimage.to_sym).blank?
        #    add_art_cnt = add_art_cnt +1
        #end  
        image_arrayi << @competitions_user.send(price_array[i].to_sym)
        image_arrayi << @competitions_user.send(editionnamearray[i].to_sym)
        image_arrayi << @competitions_user.send(editionnumberarray[i].to_sym)
        image_arrayi << title_array[i]
        @image_array << image_arrayi
        counttodisplayviwform = counttodisplayviwform + 1
      else
        image_arrayi=[]
        image_arrayi << @competitions_user.send(title_array[i].to_sym)
        image_arrayi << @competitions_user.send(medium_array[i].to_sym)
        image_arrayi << @competitions_user.send(size_array[i].to_sym)
        image_arrayi << @competitions_user.send(eachimage.to_sym)
        image_arrayi << @competitions_user.send(price_array[i].to_sym)
        image_arrayi << @competitions_user.send(editionnamearray[i].to_sym)
        image_arrayi << @competitions_user.send(editionnumberarray[i].to_sym)
        image_arrayi << title_array[i]
        @image_array << image_arrayi
      end  
      i=i+1
    end  
    i=0
   
    render :update do |page|
      if ((@competitions_user.total_entry == nil) or (@competitions_user.total_entry == 0))
        page.alert("Please Pay For One Entry")
      else  
        for updateimage in @image_array 
          if @image_array[counttodisplayviwform] == updateimage 
            page["add_the_artwork"+((@image_array.index  updateimage)  ).to_s].replace_html  :partial=>"edit_the_artwork",:locals=>{:competition_id => @competition.id,:artwork_count=>((@image_array.index  updateimage) +  1),:updateimagearray=>updateimage,:competitionuser=>@competitions_user.id,:add_artwork_link_show=>true,:messageforimageuploaded=>nil}                  
          else  
            page["add_the_artwork"+((@image_array.index updateimage) ).to_s].replace_html 	:partial=>"edit_the_artwork",:locals=>{:competition_id => @competition.id,:artwork_count=>((@image_array.index  updateimage) +   1),:updateimagearray=>updateimage,:competitionuser=>@competitions_user.id,:add_artwork_link_show=>false,:messageforimageuploaded=>nil}
          end                   
          page["enterartworkcompetition"].show
          page["enterintocompetition"].hide
          page["buylist"].hide
          page["list_show"].show
          page["add_the_artwork"+((@image_array.index updateimage) ).to_s].show
          page["iteam_image"+((@image_array.index updateimage) ).to_s].show
          i=i+1
          break if @competitions_user.total_entry.to_i == i
        end
        #currently im hiding here the biography and thanku notes if they are shown but this need to be tested. and need to create some extra  add_the_artwork div
        #after the flow is approved for salving the error
        page["iteam_image"+(@competitions_user.total_entry.to_i).to_s].hide
        page["iteam_image"+(@competitions_user.total_entry.to_i+1).to_s].hide
      end                    
    end 
  end  

 def show_buy_competition_artwork
      competitionuser = CompetitionsUser.find(:all,:include=>["artworks_competitions"],:conditions=>["competition_id = ?   ",params[:id]])
      @competitionuser  = []
      @winnerlist = []
      competitionuser.each do |ac| 
          ac.artworks_competitions.each do |x|  
              if x.state == "winner"
                @competitionuser  << x
              end
              if x.state == "selected"
                @competitionuser  << x.competitions_user
              end
          end 
      end  
  
   render :update do |page|
      if(@competitionuser.blank?)   
        page.alert("No Artworks Available To Buy For This Competition");
      else
        page["list_show"].hide
        page["enterintocompetition"].hide
        page["buylist"].show
      end
      
        
      end
    
 end



          

  def edit_exhibition_image
    @artworkexhibition = Artwork.find(:all,:conditions=>["user_id = ? and exhibition_id = ?",current_user.id,params[:id]])
    exibuser = ExhibitionsUser.find(:first,:conditions=>["user_id = ? and exhibition_id = ?",current_user.id,params[:id]])
    i=0
    if  @artworkexhibition.blank?
      render :update do |page|
        for k in 1..9
          page["add_the_artwork0"+k.to_s].replace_html ""
          page["iteam_image"+k.to_s].hide     
        end
        page["add_the_artwork0"].replace_html :partial=>"add_the_artwork_exhibition",:locals=>{:exhibition_user_id => exibuser.id,:artwork_count=>1,:exhibition_id=>params[:id],:messageforimageuploaded=>nil}
        page["enterartworkcompetition"].show
        page["add_the_artwork0"].show
        page["iteam_image0"].show   
        page["iteam_image_uploaded"].hide   
        page["description_competition_ex_py1"].hide  
        page["description_competition_ex_py"].hide  
      end
    else 
      render :update do |page|
        page["description_competition_ex_py1"].hide  
        page["description_competition_ex_py"].hide  
        for updateimage in @artworkexhibition
          page["add_the_artwork"+i.to_s].replace_html ""
          page["add_the_artwork"+i.to_s].replace_html :partial=>"edit_the_artwork_exhibition",:locals=>{:updateimage=>updateimage,:messageforimageuploaded=>nil}
          page["enterartworkcompetition"].show
          page["add_the_artwork"+i.to_s].show
          page["iteam_image"+i.to_s].show
          i=i+1
        end  
        while i < 10
          page["add_the_artwork"+i.to_s].replace_html ""
          page["iteam_image"+i.to_s].hide
          i=i+1
        end  
        page["iteam_image_uploaded"].hide  
        page["useruploadedpic"].hide
      end
    end      
  end  







  def delete_old_competitionuserdata
    CompetitionsUser.delete_all("id>0")
    Invoice.delete_all("purchasable_type='CompetitionsUser'")
  end

  #this method is copy of above create_the_payment method this i have seperated for the sake of simplicity. actually the complete code is same but a minor difference
  def create_the_payment_exhibition
    if((params[:invoicing_info][:payment_medium] ==  "visa") or (params[:invoicing_info][:payment_medium] ==  "paypal") or (params[:invoicing_info][:payment_medium] ==  "master_card"))         
      credit_card = CreditCard.find_by_user_id(current_user.id)
      if credit_card.blank?
        credit_card = CreditCard.new()
      end
      credit_card.number = params[:credit_card][:number0]+params[:credit_card][:number1]+params[:credit_card][:number2]+params[:credit_card][:number3]+params[:credit_card][:number4]+params[:credit_card][:number5]+params[:credit_card][:number6]+params[:credit_card][:number7]+params[:credit_card][:number8]+params[:credit_card][:number9]+params[:credit_card][:number10]+params[:credit_card][:number11]+params[:credit_card][:number12]+params[:credit_card][:number13]+params[:credit_card][:number14]+params[:credit_card][:number15]
      credit_card.user_id = current_user.id
      credit_card.first_name = params[:credit_card][:first_name]
      credit_card.last_name = params[:credit_card][:last_name]
      credit_card.expiring_date = Date.civil(params[:credit_card]["expiring_date(1i)"].to_i,params[:credit_card]["expiring_date(2i)"].to_i,params[:credit_card]["expiring_date(3i)"].to_i).strftime("%y-%m-%d")       
      credit_card.save
    else
    end 
    creditcardnumber = params[:credit_card][:number0]+params[:credit_card][:number1]+params[:credit_card][:number2]+params[:credit_card][:number3]+params[:credit_card][:number4]+params[:credit_card][:number5]+params[:credit_card][:number6]+params[:credit_card][:number7]+params[:credit_card][:number8]+params[:credit_card][:number9]+params[:credit_card][:number10]+params[:credit_card][:number11]+params[:credit_card][:number12]+params[:credit_card][:number13]+params[:credit_card][:number14]+params[:credit_card][:number15]
    #######################################this is im copying here is something from payment controller create method
    @order = session[:purchasable]  
    if @order.blank?
      render :text =>"Please Refresh The Page And Try Again"
      return
    else  
      @order.save
      current_user.profile.biography = params[:biography]
      current_user.profile.save
    end
    @current_object = Payment.new(params[:payment])		#@invoice = session[:invoice]		
   
    if     @order.instance_of? ExhibitionsUser
      @current_object.amount_in_cents =params[:invoice_amount].to_i*100
    elsif  @order.instance_of? CompetitionsUser
      @current_object.amount_in_cents = (@order.find_price(@order.competition.id) ) * 100
    else 
    end
    @current_object.user = @current_user		#@current_object.invoice = @invoice
    if  @order.instance_of? ExhibitionsUser
      if params[:invoicing_info][:payment_medium] ==   "visa" or params[:invoicing_info][:payment_medium] ==  "master_card" 
        @current_object.common_wealth_bank_process((params[:invoice_amount].to_i*100),params,creditcardnumber)
   
      elsif  params[:invoicing_info][:payment_medium] ==  "cash"  or   params[:invoicing_info][:payment_medium] ==  "cheque" or  params[:invoicing_info][:payment_medium] ==  "direct deposit"
      elsif  params[:invoicing_info][:payment_medium] ==  "paypal"  
        #@current_object.make_paypal_payment((params[:invoice_amount].to_i),params) 
        session[:paypal_amount] = params[:invoice_amount].to_i*100
        set_the_token#from here i need to redirect him to paypal after getting the token
        session[:invoice_id] = params[:invoice_id]
        session[:order] = @order
        session[:exhibition_id] = @order.exhibition.id
        session[:current_object_id] = @current_object
        render :update do |page|
          page["modal_space_answer"].hide                                     
          page["paypal_form"].replace_html :partial=>"paypal_form",:locals=>{:token =>@token,:amt=>params[:invoice_amount].to_i}
          page.call 'submit_my_form'
        end
        return
      end
    elsif    @order.instance_of? CompetitionsUser
      if @order.invoices.last   
        total_amount = 0
        @order.invoices.each {|x| total_amount = total_amount + x.final_amount}
        if  total_amount  < @order.find_price(@order.competition.id) 
          more_amount = (@order.find_price(@order.competition.id) ) -  total_amount
          @current_object.amount_in_cents = more_amount * 100
          if params[:invoicing_info][:payment_medium] ==   "visa" or params[:invoicing_info][:payment_medium] ==  "master card" 
            @current_object.common_wealth_bank_process((more_amount * 100),params)
          elsif  params[:invoicing_info][:payment_medium] ==  "cash"  or   params[:invoicing_info][:payment_medium] ==  "cheque" or  params[:invoicing_info][:payment_medium] ==  "direct deposit"
          elsif  params[:invoicing_info][:payment_medium] ==  "paypal"  
            @current_object.make_paypal_payment((more_amount * 100),params) 
          end
        else
          render :text=>"You Did not changed the entry field or if  you decremented it then send email to admin  "
          return
        end   
      else
        if params[:invoicing_info][:payment_medium] ==   "visa" or params[:invoicing_info][:payment_medium] ==  "master card" 
          @current_object.common_wealth_bank_process(((@order.find_price(@order.competition.id) ) * 100),params)#payment is done if invoice is not yet  created. for competition user
        elsif  params[:invoicing_info][:payment_medium] ==  "cash"  or   params[:invoicing_info][:payment_medium] ==  "cheque" or  params[:invoicing_info][:payment_medium] ==  "direct deposit"
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
            render :partial=>"extra_payment_done",:locals=>{:competition=>@order.competition,:order=>@order} 
            return        
          else
            #                  flash[:error] = "Your Payment Is Already Done Please Go To Home Page  <a href='/admin/competitions/#{@order.competition.id}'>Go Back To see the competition</a>"
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
        
        if   params[:invoicing_info][:payment_medium] ==  "cash"  or   params[:invoicing_info][:payment_medium] ==  "cheque"  or    params[:invoicing_info][:payment_medium] ==  "direct deposit"
          render :text=>"After Your Payment Is Done Admin  Will Validate You. After That Your Artwork Will Be Selected.   <a href='/admin/exhibitions/#{@order.exhibition.id}'>Select Artwork</a>"
        else
          invoice = Invoice.find(:last,:conditions=>["purchasable_type = ? and  client_id = ? and purchasable_id = ?","ExhibitionsUser" , @order.user,@order.id])
          
          if  invoice.state == "created"
            alreadypaidamt = @order.price - invoice.final_amount
            note = "no notes created"
            note = @order.exhibition.timing.note if @order.exhibition.timing
            create_pdf(invoice.id,invoice.number,@order.exhibition.timing.starting_date.strftime("%d %b %Y"),invoice.client.profile.full_address_for_invoice,invoice.client.profile.full_name_for_invoice,@order.exhibition.title,@order.price.to_i,note,@order.price - alreadypaidamt,alreadypaidamt,true,@order.exhibition.timing.ending_date,"")
            QueuedMail.add('UserMailer','send_invoice_exhibition',[@current_object.user.profile.email_address,"invoice#{invoice.id}","Your Exhibition Payment Is Done And An Invoice Is Sent to Your Email.",invoice, @current_object.user],0,true,@current_object.user.profile.email_address,"test@pragtech.co.in") 
          end    
          
          #render :text=>"Your Payment Is Done Now Upload And Then Select The Artworks  <a href='/admin/exhibitions/#{@order.exhibition.id}'>Select Artwork</a>"
          #render :partial => "online_response_exhibition_payment",:locals=>{:exhibition_user_id=>@order.id,:artwork_count=>0}
	      add_exhibition_artwork_insamediv
			              
        end            
      elsif  @order.instance_of? CompetitionsUser
        if   params[:invoicing_info][:payment_medium] ==  "cash"  or   params[:invoicing_info][:payment_medium] ==  "cheque" or  params[:invoicing_info][:payment_medium] ==  "direct deposit"
          #render :text=>"After Your Payment Is Done Admin  Will Validate You. After That Your Artwork Will Be Selected.  Please Make The Payment Before #{@order.submission_date} <a href='/admin/competitions/#{@order.competition.id}'>Go Back To see the competition</a>"
          render :partial=> "cash_cheque_response",:locals=>{:competition_id=>@order.competition.id,:artwork_count=>0,:order_id=>@order.id,:total_entry=>@order.total_entry}
        else
          #session[:total_entry] = @order.total_entry
          #render :update do |page|
          # session[:store_for_submitting_the_artwork] = @order.id
          #page["show_me_the_error"].replace_html :partial=>"add_artwork_link",:locals=>{:competition_id=>@order.competition.id,:artwork_count=>0,:order_id=>@order.id}
          #end
          render :partial=>"add_artwork_link",:locals=>{:competition_id=>@order.competition.id,:artwork_count=>0,:order_id=>@order.id}
          #render :text=>"Your Payment Is Done . The Invoice Is Sent To You By Email.   <a href='/admin/competitions/#{@order.competition.id}'>Go Back To see the competition</a>"
        end     	       
      end
    else
      if params[:invoicing_info][:payment_medium] ==  "cash"  or   params[:invoicing_info][:payment_medium] ==  "cheque" or  params[:invoicing_info][:payment_medium] ==  "direct deposit"
        if  @order.instance_of? CompetitionsUser
          make_the_payment
        else
          make_the_payment_exhibition
          invoice = Invoice.find(:last,:conditions=>["purchasable_type = ? and  client_id = ? and purchasable_id = ?","ExhibitionsUser" , @order.user,@order.id])
          if  invoice.state == "created"
            note = "no notes created"
            note = @order.exhibition.timing.note if @order.exhibition.timing
            create_pdf(invoice.id,invoice.number,invoice.sent_at.strftime("%d %b %Y"),invoice.client.profile.full_address_for_invoice,invoice.client.profile.full_name_for_invoice,@order.exhibition.title,invoice.final_amount.to_i,note)
            QueuedMail.add('UserMailer', 'send_invoice_exhibition', [invoice, @order.user], 0, true)
          end       
        end      
        if  @order.instance_of? CompetitionsUser   
          #  render :text=>"After Your Payment Is Done Admin  Will Validate You. After That Your Artwork Will Be Selected.  Please Make The Payment Before #{@order.competition.submission_deadline} <a href='/admin/competitions/#{@order.competition.id}'>Go Back To see the competition</a>"
          render :partial=> "cash_cheque_response",:locals=>{:competition_id=>@order.competition.id,:artwork_count=>0,:order=>@order,:total_entry=>@order.total_entry}
          return                  
        else
          #exhibition cash_cheque_response
          # render :partial => "cash_cheque_response_exhibition",:locals=>{:exhibition_user_id=>@order.id,:artwork_count=>0}
          #instead of this response i need to give the option to add the artwork to user
          
          render :update do |page|
            page["add_the_artwork0"].replace_html :partial=>"add_the_artwork_exhibition",:locals=>{:exhibition_user_id => @order.id,:exhibition_id=>@order.exhibition.id,:messageforimageuploaded=>"After Your Payment Is Done Admin Will Validate You. Please Upload The Artwork"}
            page["description_competition_ex_py"].hide
            page["enterartworkcompetition"].show
            page["add_the_artwork0"].show
            page["iteam_image0"].show
            page["iteam_image_uploaded"].hide
            
          end
          #render :text=>"After Your Payment Is Done Admin  Will Validate You. After That Your Artwork Will Be Selected.  <a href='admin/exhibitions/#{@order.exhibition.id}'>Select Artwork</a>"
        end            	       
        return
      end
	            
      #flash[:error] = 'Error during the payment save  '+@current_object.state.to_s
	            
      #render :partial => 'new', :layout => false
      render :text=>"Your payment has not been successful. Please check your details and try again"
    end

  end  



  def  add_exhibition_artwork
    # order = ExhibitionsUser.find(params[:exhibition_user_id])
    eu = ExhibitionsUser.find(params[:exhibition_user_id])
    artcount = Artwork.count(:conditions => "user_id = #{current_user.id} AND exhibition_id = #{eu.exhibition.id}") 
    render :update do |page|
      if artcount > 9
        page.alert("You Can Not Upload More Than 10 Artwork For A Single Exhibition")
      else    
        page["add_the_artwork"+params[:artwork_count]].replace_html :partial=>"add_the_artwork_exhibition",:locals=>{:exhibition_user_id => params[:exhibition_user_id],:artwork_count=>params[:artwork_count].to_i+1,:exhibition_id=>eu.exhibition.id}
        page["enterartworkcompetition"].show
        page["add_the_artwork"+params[:artwork_count]].show
        page["iteam_image"+params[:artwork_count]].show
        page["iteam_image_uploaded"].hide
      end  
    end
  end  


  def  add_exhibition_artwork_insamediv
    # order = ExhibitionsUser.find(params[:exhibition_user_id])
    #eu = ExhibitionsUser.find(params[:exhibition_user_id])
    artcount = Artwork.count(:conditions => "user_id = #{current_user.id} AND exhibition_id = #{@order.exhibition.id}") 
    render :update do |page|
      page["add_the_artwork0"].replace_html :partial=>"add_the_artwork_exhibition",:locals=>{:exhibition_user_id => @order.id,:exhibition_id=>@order.exhibition.id,:messageforimageuploaded=>"Your Payment Is Done Please Upload The Artwork"}
      page["description_competition_ex_py"].hide
      page["enterartworkcompetition"].show
      page["add_the_artwork0"].show
      page["iteam_image0"].show
      page["iteam_image_uploaded"].hide
      eu=@order
   if    !eu.user.invoices.blank?  and((eu.user.invoices.find(:first ,:conditions=>["purchasable_id = ? ",eu.id]) != nil and   eu.user.invoices.find(:first ,:conditions=>["purchasable_id = ? ",eu.id]).state != "validated") or (eu.user.invoices.find(:last ,:conditions=>["purchasable_id = ? ",eu.id]) != nil and   eu.user.invoices.find(:last ,:conditions=>["purchasable_id = ? ",eu.id]).state != "validated")) 
   else
        
        page["payonlineexhibition#{eu.id}"].replace_html "online paid"
   end 
      
    end
  end  


  
  




  def create_exhibition_artwork
    i=1
    params[:artwork].each do   
      if !params[:artwork_id].blank?
        @artwork = ExhiArtwork.find(params[:artwork_id])
        @artwork.title=params[:artwork]["title"+@artwork.id.to_s]                                                                                                                                 
        @artwork.user_id=current_user.id
        if !params[:artwork]["image"+@artwork.id.to_s].blank?
           @artwork.image = params[:artwork]["image"+@artwork.id.to_s]
        end
        @artwork.medium = params[:artwork]["medium"+@artwork.id.to_s]
        @artwork.width = params[:artwork]["width"+@artwork.id.to_s]
        @artwork.height = params[:artwork]["height"+@artwork.id.to_s]
        @artwork.depth = params[:artwork]["depth"+@artwork.id.to_s]
        @artwork.edition_name = params[:artwork]["edition_name"+@artwork.id.to_s]
        @artwork.edition_number = params[:artwork]["edition_number"+@artwork.id.to_s]
        @artwork.price = params[:artwork]["price"+@artwork.id.to_s]
        @artwork.is_purchasable = params[:artwork]["is_purchasable"+@artwork.id.to_s]  
        @artwork.save
      else  
        @artwork = ExhiArtwork.new()
        @artwork.title=params[:artwork]["title"+i.to_s]
        @artwork.user_id=current_user.id
        @artwork.image = params[:artwork]["image"+i.to_s]
        @artwork.medium = params[:artwork]["medium"+i.to_s]
        @artwork.width = params[:artwork]["width"+i.to_s]
        @artwork.height = params[:artwork]["height"+i.to_s]
        @artwork.depth = params[:artwork]["depth"+i.to_s]
        @artwork.edition_name = params[:artwork]["edition_name"+i.to_s]
        @artwork.edition_number = params[:artwork]["edition_number"+i.to_s]
        @artwork.price = params[:artwork]["price"+i.to_s]
        @artwork.is_purchasable = params[:artwork]["is_purchasable"+i.to_s]
        @artwork.exhibition_id = params["exhibition_id"]
        if  @artwork.save
          wcp = Workspace.find(:first, :conditions => { :creator_id => current_user.id}).id
          itw=ItemsWorkspace.new(:workspace_id=>wcp,:itemable_type=>"Artwork",:itemable_id=>@artwork.id)
          itw.save
          i=i+1
        end
      end
    end  #im changed this response code because this method will be called only for edit the exhibition
    responds_to_parent do
      render :update do |page|
        page["messageforimageuploaded#{@artwork.id}"].replace_html :partial=>"edit_artwork_exhibition_response",:locals=>{:updateimage=>@artwork,:messageforimageuploaded=>"Your Image Is Uploaded"}
      end
    end  
  end


  def create_exhibition_artwork_insamediv
    artwork = ExhiArtwork.new()
    artwork.title=params[:artwork]["title"]
    artwork.user_id=current_user.id
    artwork.image = params[:artwork]["image"]
    artwork.medium = params[:artwork]["medium"]
    artwork.width = params[:artwork]["width"]
    artwork.height = params[:artwork]["height"]
    artwork.depth = params[:artwork]["depth"]
    artwork.edition_name = params[:artwork]["edition_name"]
    artwork.edition_number = params[:artwork]["edition_number"]
    artwork.price = params[:artwork]["price"]
    artwork.is_purchasable = params[:artwork]["is_purchasable"]
    artwork.exhibition_id = params["exhibition_id"]
    if  artwork.save
      wcp = Workspace.find(:first, :conditions => { :creator_id => current_user.id}).id
      itw=ItemsWorkspace.new(:workspace_id=>wcp,:itemable_type=>"Artwork",:itemable_id=>artwork.id)
      itw.save
    end
    responds_to_parent do
      render :update do |page|
        page["add_the_artwork0"].replace_html :partial=>"add_the_artwork_exhibition",:locals=>{:exhibition_user_id => params[:exhibition_user_id],:exhibition_id=>params[:exhibition_id],:messageforimageuploaded=>"Your Artwork Is Uploaded"}
        page["enterartworkcompetition"].show
        page["add_the_artwork0"].show
        page["iteam_image0"].show   
        page["iteam_image_uploaded"].hide   
      end
    end  
  end





  def upload_exhibition_image
    render :update do |page|
      page["enterintocompetitionfront"].replace_html :partial=>"upload_image_exhibition",:locals=>  {:exhibition_id=>params[:id],:messageforimageuploaded=>nil}
      page["description_competition_ex_py"].show
      page["useruploadedpic"].hide
      
      for k in 0..9
        page["iteam_image#{k}"].hide
      end
    end
  end  


  def upload_exhibition_artwork
    artwork = ExhiArtwork.new()
    artwork.title=params[:artwork]["title"]
    artwork.user_id=current_user.id
    artwork.image = params[:artwork]["image"]
    artwork.medium = params[:artwork]["medium"]
    artwork.width = params[:artwork]["width"]
    artwork.height = params[:artwork]["height"]
    artwork.depth = params[:artwork]["depth"]
    artwork.edition_name = params[:artwork]["edition_name"]
    artwork.edition_number = params[:artwork]["edition_number"]
    artwork.price = params[:artwork]["price"]
    artwork.is_purchasable = params[:artwork]["is_purchasable"]
    artwork.exhibition_id = params["exhibition_id"]
    if  artwork.save
      wcp = Workspace.find(:first, :conditions => { :creator_id => current_user.id}).id
      itw=ItemsWorkspace.new(:workspace_id=>wcp,:itemable_type=>"Artwork",:itemable_id=>artwork.id)
      itw.save
      responds_to_parent do
        render :update do |page|
          page["enterintocompetitionfront"].replace_html :partial=>"upload_image_exhibition",:locals=>  {:exhibition_id=>params["exhibition_id"],:messageforimageuploaded=>"Your Artwork Is Uploaded"}
          page["description_competition_ex_py"].show
        end
      end          		     
    else
      responds_to_parent do
        render :update do |page|
          page["enterintocompetitionfront"].replace_html :partial=>"upload_image_exhibition",:locals=>  {:exhibition_id=>params["exhibition_id"],:messageforimageuploaded=>"Artwork Is Not Uploaded Please Try Again"}
          page["description_competition_ex_py"].show
        end
      end  
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
      return_url="http://" + request.host_with_port + "/paypal_return",
      cancel_url="http://" + request.host_with_port + "/paypal_cancel",
      amount=session[:paypal_amount].to_i/100
    )
    logger.info response.to_s
    logger.info "this is paypal response"
    @token = (response.ack == 'Success') ? response['TOKEN'] : ''
    session[:token] = @token
  end  

  def  paypal_return
    username= "pathak_1259733727_biz_api1.gmail.com"
    password = "1259733733"
    signature= "A.gsseBoaG2XQonqoXpE4WUr4VafArVDPTPSg6gSo7rEoyqCTsE-yxWp"
    paypal = Paypal.new(username, password, signature)
    response = paypal.do_get_express_checkout_details(session[:token])
    logger.info response.to_s
    logger.info "this is paypal response"
    if response.ack == "Success"
      response = paypal.do_express_checkout_payment(token=session[:token],
        payment_action='Sale',
        payer_id=response.payerid,
        amount=session[:paypal_amount].to_i/100)#end of do express checkout method
      if !session[:total_entry].blank?   
        if !session[:competition_id].blank?
            cu = CompetitionsUser.find_by_user_id_and_competition_id(current_user.id,session[:competition_id])
            cu.total_entry = session[:total_entry].to_i
            cu.save
        end
      end
      if (!session[:current_object_id].blank?)
        payment = session[:current_object_id]
        payment.state = 'online_validated'
        #payment.save
        # i assume here that when session[:totalentry present then it is competition user payment so the procedure of online payment will be followed here, same to the case for exhibition user payment]
        if session[:competition_id].blank?
          params[:invoice_id] = session[:invoice_id] 
          session[:invoice_id] = nil
          make_the_payment_exhibition_paypal#here the invoice in created and validated
          make_the_invoice #this method is extraction from above make exhibition payment . because this method is get called after the paypal returns. so in previous method the next procedure is get called which im putting it in this method  
        else
          
          make_the_payment_comp_paypal
          
        end  
        session[:current_object_id] = nil
      end
      if !session[:groupsshowid].blank?
          groupshowid = session[:groupsshowid].to_i
          groupshowuser = Usergroupshow.find(:first,:conditions=>["user_id = ? and groupshow_id = ? ",current_user.id,groupshowid])
          groupshowuser.state = "validated"
          groupshowuser.save
          payment = Payment.new
          payment.invoice = groupshowuser.generate_invoice(current_user.id,{"payment_medium"=>"paypal"},amount)
          payment.save
          note = "no notes created"
          note = groupshowuser.groupshow.note if groupshowuser.groupshow
          start_date = groupshowuser.groupshow.starting_date
          end_date = groupshowuser.groupshow.ending_date
          create_pdf(payment.invoice.id,payment.invoice.number,start_date,payment.invoice.client.profile.full_address_for_invoice,payment.invoice.client.profile.full_name_for_invoice,groupshowuser.groupshow.title,payment.invoice.final_amount.to_i,note,"","",false,end_date)
          begin
          email = UserMailer.create_send_invoice_groupshow(payment.invoice,current_user)
          UserMailer.deliver(email)
          rescue
          end
      end
    end 
  
    comid = session[:competition_id]
    
    session[:competition_id] = nil
  
    session[:total_entry] = nil
    if comid.blank?
      flash[:notice] = "Your Payment Is Done"
      redirect_to "/"   
    elsif !session[:groupshowid].blank? 
           session[:groupshowid] = nil
           flash[:notice] = "Your Payment Is Done Please Upload The Images"
           redirect_to "/" 
    else  
      flash[:notice] = "Your Payment Is Done.Please Click On Brows Image To Upload  The Artwork"
      redirect_to "/competitions/#{ comid }"                  
    end 
        
        
  end

  def paypal_cancel
    logger.info "cancelled transaction"
    logger.info "this is paypal response"
    flash[:notice] = "You Have Cancelled The Paypal Transaction"
    comid = session[:competition_id]
    session[:competition_id] = nil
    session[:paypal_amount] = nil
    session[:total_entry] = nil
    session[:current_object_id] = nil
    if comid.blank?
      redirect_to "/"
    elsif session[:goupshow] == "true"
      
    else  
      redirect_to "/competitions/#{ comid }"
    end  
  end    


  def test_delete
    CompetitionsUser.delete_all("competition_id = #{params[:id]}");
  end  
 
  def test_anything 
    #@timingperiod = Timing.find(:all)
    #@array=[]
    #@timingperiod.each do |x| @array<<x.objectable_id.to_s+x.objectable_type.to_s end
    #@compeitionuser = CompetitionsUser.find(:all,:conditions=>"competition_id = 30")
    #@idlist = []
    #@compeitionuser.each do |x|@idlist << x.user.profile.first_name+ " " end
    #render :text=>@idlist.to_s
    #@competition=Competition.find(:all)
    #@comp_users=CompetitionsUser.find(:all)
    #@artcomp = ArtworksCompetition.find(:all)
    #@invoice=Invoice.find(:all,:conditions=>"purchasable_type = 'CompetitionsUser' ")
    p params
    @myquery = params[:id].constantize.find(:all,:conditions=>"#{params[:conditions]}");
    a= @myquery.first.to_a
    p a[0].instance_values
    p "string object"
    p a[1]
    
    render :text=>@myquery.first.instance_values
  end

  def make_the_invoice
    invoice = Invoice.find(:last,:conditions=>["purchasable_type = ? and  client_id = ? and purchasable_id = ?","ExhibitionsUser" , session[:order].user,session[:order].id])
    if  invoice.state == "created"
      alreadypaidamt = session[:order].price - invoice.final_amount
      note = "no note is created"
      note = session[:order].exhibition.timing.note if session[:order].exhibition.timing
      create_pdf(invoice.id,invoice.number,invoice.sent_at.strftime("%d %b %Y"),invoice.client.profile.full_address_for_invoice,invoice.client.profile.full_name_for_invoice,session[:order].exhibition.title,session[:order].price.to_i,note,session[:order].price - alreadypaidamt,alreadypaidamt)
      #QueuedMail.add( 'UserMailer',  'send_invoice_exhibition', [invoice.client.profile.email_address,"invoice#{invoice.id}","Your Exhibition Payment Is Done And An Invoice Is Sent to Your Email.",invoice, invoice.client],0,true,invoice.client.profile.email_address,"test@pragtech.co.in") 
      #p "from here im sending the email8888888888888888888888888888"
      #QueuedMail.add('UserMailer', 'send_invoice_exhibition', [invoice, invoice.client], 0, true)
      #send_invoice_exhibition(tomial,subject,body,invoice, user)
      begin
      email= UserMailer.create_send_invoice_exhibition(invoice.client.profile.email_address,"invoice#{invoice.id}","Your Exhibition Payment Is Done And An Invoice Is Sent to Your Email",invoice, invoice.client)
      UserMailer.deliver(email)
      rescue
      end
    end    

  end

  def  make_the_payment_exhibition_paypal
    @invoice = Invoice.find(params[:invoice_id])
    @invoice.validating("paypal")
  end

  def make_the_payment_comp_paypal
   
      
      make_the_payment_paypal
    
  
  end 

  #actual payment is done in above method onlyhere the invoice processing is done
  def make_the_payment_paypal
    #here i need to refresh the order because the total entry field is changed
    order=CompetitionsUser.find(session[:order].id)
    if  order and order.invoices.last
      @invoice = order.generate_invoice_extra_entry(@current_user,{"payment_medium"=>"paypal"} )
    else
      @invoice = order.generate_invoice(@current_user, {"payment_medium"=>"paypal"}) 
    end 	
    @invoice.validating("paypal")
    session[:current_object].invoice = @invoice
    session[:current_object].save
    invoice = Invoice.find(:last,:conditions=>["client_id = ? and purchasable_id = ?",@current_user.id,order.id])
    
    if order.instance_of? CompetitionsUser
      note = "no note created"
      note = order.competition.timing.note if order.competition.timing 
      
      start_date = order.competition.timing.starting_date.strftime("%d %b %Y")
      end_date = order.competition.timing.ending_date.strftime("%d %b %Y")
      create_pdf(invoice.id,invoice.number,invoice.sent_at.strftime("%d %b %Y"),invoice.client.profile.full_address_for_invoice,invoice.client.profile.full_name_for_invoice,order.competition.title,invoice.final_amount.to_i,note,"",invoice.final_amount.to_i,false,end_date)
    elsif  order.instance_of? ExhibitionsUser
      note = "no note created"
      note = order.exhibition.timing.note if order.exhibition.timing 
      create_pdf(invoice.id,invoice.number,invoice.sent_at.strftime("%d %b %Y"),invoice.client.profile.full_address_for_invoice,invoice.client.profile.full_name_for_invoice,order.exhibition.title,invoice.final_amount.to_i,note)
    end
    #QueuedMail.add('UserMailer', 'send_invoice',[@invoice,@current_user], 0, send_now=true)	
    #QueuedMail.create(:mailer => 'UserMailer', :mailer_method => 'send_invoice',:args => [@current_user.profile.email_address,"invoice#{invoice.id}","An Invoice Is Send To Your Email For Your Payment"],:priority => 0,:tomail=>@current_user.profile.email_address,:frommail=>"test@pragtech.co.in")
    begin
    email= UserMailer.create_send_invoice(invoice,@current_user)
    UserMailer.deliver(email)
    rescue => e
      logger.info "there is error while sending the email"
      logger.info e
    end
  end

  #############333333333333333333333333333333333333333333this all is for group show payment

  def show_group_show_form
    @credit_card = CreditCard.new
    alreadypaidamt = nil
    groupshow = Groupshow.find(params[:id])
    gallery = Gallery.find(groupshow.gallery_id.split(","))
    price = 0
    gallery.each do |g|  price = price + g.price   end
    render :update do |page|
      page["enterintocompetitionfront"].replace_html :partial=>"enter_groupshow_payment",
        :locals=>  {:price=>price,:groupshow=>groupshow,
        :credit_card=>@credit_card,:alreadypaidamt=>alreadypaidamt}
      page["description_competition_ex_py"].show
      page["iteam_image_uploaded"].hide
      page["useruploadedpic"].hide
      for k in 0..9
        page["iteam_image#{k}"].hide
      end
    end
  end
  
  def show_group_payment
    @payment = Payment.new
    current_user.profile.biography = params[:biography]
    current_user.profile.save
    creditcardno =  params[:credit_card][:number0]+params[:credit_card][:number1]+params[:credit_card][:number2]+params[:credit_card][:number3]+params[:credit_card][:number4]+params[:credit_card][:number5]+params[:credit_card][:number6]+params[:credit_card][:number7]+params[:credit_card][:number8]+params[:credit_card][:number9]+params[:credit_card][:number10]+params[:credit_card][:number11]+params[:credit_card][:number12]+params[:credit_card][:number13]+params[:credit_card][:number14]+params[:credit_card][:number15]
    if ((params[:invoicing_info][:payment_medium] == "cash") or (params[:invoicing_info][:payment_medium] ==  "direct deposit") or (params[:invoicing_info][:payment_medium] == "cheque"))
         show_cash_response_groupshow
         return
    elsif (params[:invoicing_info][:payment_medium] == "visa" or params[:invoicing_info][:payment_medium] ==  "master card" )
      @payment.common_wealth_bank_process((params[:price].to_i * 100),params,creditcardno)
    elsif  (params[:invoicing_info][:payment_medium] == "paypal") 
      session[:paypal_amount] = params[:price].to_i * 100
      set_the_token
      session[:groupsshowid] = params[:groupshowid]
      render :update do |page|
              page["modal_space_answer"].hide                                     
              page["paypal_form"].replace_html :partial=>"paypal_form",:locals=>{:token =>@token,:amt=>( params[:price].to_i * 100)}
              page.call 'submit_my_form'
              
      end
      return
    end
    #here i need to create the invoice and give the return message
    if @payment.state  == 'online_validated'
      make_groupshow_payment
    else
      render :text=>"Please Check Your Details And Try Again"
    end
  end
  def show_cash_response_groupshow
   
    render :update do |page|
      page["add_the_artwork0"].replace_html :partial=>"create_groupshow_artwork",:locals=>{:groupshow_id => params[:groupshowid],:messageforimageuploaded=>"Please Upload The Artwork"}
      page["description_competition_ex_py"].hide
      page["enterartworkcompetition"].show
      page["add_the_artwork0"].show
      page["iteam_image0"].show
      page["iteam_image_uploaded"].hide
    end
  
  end
  def make_groupshow_payment
    @groupshowuser = Usergroupshow.find_by_groupshow_id_and_user_id(params[:groupshowid],current_user.id)
    @groupshowuser.state = "validated"
    @groupshowuser.save
    @payment.invoice = @groupshowuser.generate_invoice(current_user.id,params[:invoicing_info],params[:price].to_i)
    @payment.save
    note = "no note created"
    note = @groupshowuser.groupshow.note  if @groupshowuser.groupshow
    start_date = @groupshowuser.groupshow.starting_date.strftime("%d %b %Y")
    end_date = @groupshowuser.groupshow.ending_date.strftime("%d %b %Y")
    create_pdf(@payment.invoice.id,@payment.invoice.number,start_date,@payment.invoice.client.profile.full_address_for_invoice,@payment.invoice.client.profile.full_name_for_invoice,@groupshowuser.groupshow.title,@payment.invoice.final_amount.to_i,note,"","",false,end_date)
    begin
      email = UserMailer.create_send_invoice_groupshow(@payment.invoice,current_user)
      UserMailer.deliver(email)
    rescue
    end
    render :update do |page|
      page["add_the_artwork0"].replace_html :partial=>"create_groupshow_artwork",:locals=>{:groupshow_id => params[:groupshowid],:messageforimageuploaded=>"Your Payment Is Done Please Upload The Artwork"}
      page["description_competition_ex_py"].hide
      page["enterartworkcompetition"].show
      page["add_the_artwork0"].show
      page["iteam_image0"].show
      page["iteam_image_uploaded"].hide
      page["paymentlink#{@groupshowuser.id}"].replace_html "online paid"
    end
  end
  
  def show_upload_groupform
     render :update do |page|
      page["add_the_artwork0"].replace_html :partial=>"create_groupshow_artwork",:locals=>{:groupshow_id => params[:id],:messageforimageuploaded=>"Please Upload The Image"}
      page["description_competition_ex_py"].hide
      page["enterartworkcompetition"].show
      page["add_the_artwork0"].show
      page["iteam_image0"].show
      page["iteam_image_uploaded"].hide
      page["useruploadedpic"].hide
      for k in 1..9
        page["iteam_image#{k}"].hide
      end
     end
  end
  
  def upload_the_artwork_to_groupshow
    @groupshowuser   = Usergroupshow.find_by_groupshow_id_and_user_id(params[:groupshowid],current_user.id)
    groupshowartwork = Groupshowartwork.new
    groupshowartwork.title  = params[:groupshow_user][:title]
    groupshowartwork.medium = params[:groupshow_user][:medium]
    groupshowartwork.size1  = params[:groupshow_user][:size1]
    groupshowartwork.size2  = params[:groupshow_user][:size2]
    groupshowartwork.size3  = params[:groupshow_user][:size3]
    groupshowartwork.price  = params[:groupshow_user][:price]
    groupshowartwork.editionname  = params[:groupshow_user][:editionname]
    groupshowartwork.editionumber  = params[:groupshow_user][:editionumber]
    groupshowartwork.user_id = current_user.id
    groupshowartwork.groupshow_id = params[:groupshow_id]
    groupshowartwork.artworkurl = params[:groupshow_user][:image]
   # groupshowartwork.save_image(params)
    groupshowartwork.save
    responds_to_parent do
      render :update do |page|
        page["add_the_artwork0"].replace_html :partial=>"create_groupshow_artwork",:locals=>{:groupshow_id => params[:groupshow_id],:messageforimageuploaded=>"Your Artwork Is Saved"}
        page["description_competition_ex_py"].hide
        page["enterartworkcompetition"].show
        page["add_the_artwork0"].show
        page["iteam_image0"].show
        page["iteam_image_uploaded"].hide
      end
    end
  end
  
  def edit_groupshow_image
    i=0
    @groupshowuser   =  Groupshowartwork.find_all_by_groupshow_id_and_user_id(params[:id],current_user.id)  
    render :update do |page|
        page["description_competition_ex_py1"].hide  
        page["description_competition_ex_py"].hide  
        for updateimage in @groupshowuser
          page["add_the_artwork"+i.to_s].replace_html ""
          page["add_the_artwork"+i.to_s].replace_html :partial=>"edit_the_artwork_groupshow",:locals=>{:groupshow_id => updateimage.groupshow.id,:messageforimageuploaded=>"",:updateimage=>updateimage}
          page["enterartworkcompetition"].show
          page["add_the_artwork"+i.to_s].show
          page["iteam_image"+i.to_s].show
          i=i+1
        end  
        while i < 10
          page["add_the_artwork"+i.to_s].replace_html ""
          page["iteam_image"+i.to_s].hide
          i=i+1
        end  
        if @groupshowuser.blank?
          page["add_the_artwork0"].replace_html :partial=>"create_groupshow_artwork",:locals=>{:groupshow_id => params[:id],:messageforimageuploaded=>"Please Upload The Image"}
          page["add_the_artwork0"].show
          page["iteam_image0"].show
        else
        end
        page["iteam_image_uploaded"].hide  
        page["useruploadedpic"].hide
        
    end
  end
  
  def edit_upload_the_artwork_to_groupshow
    @groupshowuser   =  Groupshowartwork.find(params[:artworkgroupshowid])  
    @groupshowuser.title  = params[:groupshow_user][:title]
    @groupshowuser.medium = params[:groupshow_user][:medium]
    @groupshowuser.size1  = params[:groupshow_user][:size1]
    @groupshowuser.size2  = params[:groupshow_user][:size2]
    @groupshowuser.size3  = params[:groupshow_user][:size3]
    @groupshowuser.price  = params[:groupshow_user][:price]
    @groupshowuser.editionname  = params[:groupshow_user][:editionname]
    @groupshowuser.editionumber  = params[:groupshow_user][:editionumber]
    @groupshowuser.user_id = current_user.id
    #@groupshowuser.groupshow_id = params[:groupshow_id]
    @groupshowuser.artworkurl = params[:groupshow_user][:image]
    #@groupshowuser.save_image(params)
    @groupshowuser.save
    responds_to_parent do
       render :update do |page|
          page["artworkchange#{@groupshowuser.id}"].replace_html :partial=>"edit_groupsshow_response",:locals=>{:messageforimageuploaded=>"Your Artwork Is Changed",:updateimage=>@groupshowuser}
       end
    end
    
  end
  
end

