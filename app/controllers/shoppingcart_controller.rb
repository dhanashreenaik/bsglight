class ShoppingcartController < ApplicationController
  layout "front"
  require "rubygems"
  require "net/https"
  require "uri"
  require "ruby-paypal"
  
  def add_to_cart
    if params[:orderable_type].to_s.include? "CompetitionsUser"
      objekt = { "#{params[:orderable_type]}_#{params[:orderable_id]}_#{params[:eachimage]}" => params[:number]}
    else
      objekt = { "#{params[:orderable_type]}_#{params[:orderable_id]}" => params[:number]}
    end  
    if session[:cart].blank?
       session[:cart]={}
    end
		if session[:cart].merge!(objekt)
  		msg = "Product added to the cart"
		else
			msg = "Error ading product to the cart"
		end
    render :update do |page|
      if params[:orderable_type].to_s.include? "CompetitionsUser"
         page["shoppingcartlink#{params[:orderable_id]}#{params[:orderable_type]}#{params[:eachimage]}"].replace_html msg
      else
        page["shoppingcartlink#{params[:orderable_id]}#{params[:orderable_type]}"].replace_html msg
      end
    end 
 
  end
  
  def remove_from_cart
    if params[:orderable_type].to_s.include? "CompetitionsUser"
      session[:cart].delete("#{params[:orderable_type]}_#{params[:orderable_id]}_#{params[:imagename]}")
    else
      session[:cart].delete("#{params[:orderable_type]}_#{params[:orderable_id]}")
    end
		@current_object = Order.new_from_cart(session[:cart], @current_user)
    render :update do |page|
      page["order#{params[:i]}"].hide
      page["total_amount"].replace_html "<h> #{@current_object.total_amount}  AUD</h><br />"
    end
	end
  
  def show_me_cart
    
    begin
      
    p "im sending"
    p "this is my session of cart"
    p session[:cart]
    @current_object = Order.new_from_cart(session[:cart], @current_user)
    p @current_object
    p "this is my currentobject"
    @paymentdone  = params[:payment_message]
    if !session[:current_purchase].blank?
       @current_purchase =  session[:current_purchase]#= Order.new_from_cart(session[:current_purchase], @current_user)
       session[:current_purchase] = {}
    end
    rescue => e
      p "but im from rescueeee"
      session[:current_purchase] = {}
      logger.info e
      logger.info "there is some errors in shopping cart"
    end
    
  end

  def show_payment_form
      render :update do |page|
        page["add_the_artwork0"].replace_html :partial=>"shopping_payment"
        page["iteam_image0"].show
      end
  end
  
  def shopping_cart_payment
    if params[:invoicing_info][:payment_medium] == "visa" or params[:invoicing_info][:payment_medium] == "master card"
       makeshoppingcartpayment
      return
    end
    if params[:invoicing_info][:payment_medium] == "paypal"
       makeshoppingcartpaypalpayment
      
    end
  end
  
  def list_of_my_order
      #@payment = Payment.find(:all,:conditions=>["user_id = ?",current_user.id])
      @order = Order.find(:all,:conditions=>["client_id = ?",current_user.id])
      render :update do |page|
        page["add_the_artwork0"].replace_html :partial=>"list_of_order"
        page["iteam_image0"].show
      end
  end 
  
  def makeshoppingcartpayment
    image_array = ['fworkimage','sworkimage','tworkimage','foworkimage','fiworkimage','siworkimage','seworkimage','eworkimage','nworkimage','teworkimage']
    sold_array = [ 'fsold=','ssold=','tsold=','fosold=','fisold=','sisold=','sesold=','eisold=','nsold=','tesold=']
    editionnamearray = ['fworkedname=','sworkedname=','tworkedname=','foworkedname=','fiworkedname=','siworkedname=','seworkedname=','eiworkedname=','niworkedname=','teworkedname=']
    editionnamearrayv = ['fworkedname','sworkedname','tworkedname','foworkedname','fiworkedname','siworkedname','seworkedname','eiworkedname','niworkedname','teworkedname']
    editionnumberarrayv = ['fworkednumber','sworkednumber','tworkednumber','foworkednumber','fiworkednumber','siworkednumber','seworkednumber','eiworkednumber','niworkednumber','teworkednumber']
   	@current_object = Order.new_from_cart(session[:cart], @current_user)
      payment = Payment.new()
      order = Order.complete_from_cart(session[:cart], @current_user)
      crnumber =  params[:credit_card][:number0]+params[:credit_card][:number1]+params[:credit_card][:number2]+params[:credit_card][:number3]+params[:credit_card][:number4]+params[:credit_card][:number5]+params[:credit_card][:number6]+params[:credit_card][:number7]+params[:credit_card][:number8]+params[:credit_card][:number9]+params[:credit_card][:number10]+params[:credit_card][:number11]+params[:credit_card][:number12]+params[:credit_card][:number13]+params[:credit_card][:number14]+params[:credit_card][:number15]
      payment.common_wealth_bank_process(@current_object.total_amount*100,params,crnumber)
      if  payment.state == "online_validated"
          order = Order.complete_from_cart(session[:cart], @current_user)
          payment.invoice = order.generate_invoice(current_user, params[:invoicing_info])
          payment.user_id = current_user.id
          payment.amount_in_cents = @current_object.total_amount*100
          payment.save
          if session[:cart]  
             session[:cart].each do |k, v|
    		        if  k.split('_')[0] == "CompetitionsUser"
                    cu = CompetitionsUser.find(k.split('_')[1])      
                    editvalue = cu.send editionnamearrayv[image_array.index(k.split('_')[2])]
                    cu.send(editionnamearray[image_array.index(k.split('_')[2])],editvalue.to_i+1)
                
                    if(editvalue.to_i+1 > (cu.send(editionnumberarrayv[image_array.index(k.split('_')[2])])).to_i)  
                      cu.send (sold_array[image_array.index(k.split('_')[2])],true)
                    end
                
                    cu.save
                end
                if  k.split('_')[0] == "Artwork"
                    art = Artwork.find(k.split('_')[1])      
                    art.edition_name = art.edition_name.to_i + 1
                    if art.edition_name.to_i > art.edition_number.to_i
                      art.sold = true 
                    end
                    art.save
                end
                if  k.split('_')[0] == "Groupshowartwork"
                  art = Groupshowartwork.find(k.split('_')[1]) 
                  art.editionname = art.editionname.to_i + 1
                  if art.editionname.to_i > art.editionumber
                     art.sold = true
                  end
                  art.save
                end
            end    
          end 
          
          session[:current_purchase] = order
          session[:cart] = {}  
          
          render :update do |page|
              page["modal_space_answer"].hide
              page.redirect_to :action=>"show_me_cart",:payment_message=>"Your Payment Is Done"
          end
      else
          render :text=>"Please Check Your Details And Try Again"
      end      
  end
  
  def makeshoppingcartpaypalpayment
      @current_object = Order.new_from_cart(session[:cart], @current_user)
      session[:paypal_amount] = @current_object.total_amount.to_i 
      set_the_token
            render :update do |page|
              page["modal_space_answer"].hide                                     
              page["paypal_form"].replace_html :partial=>"paypal_form",:locals=>{:token =>@token,:amt=>( @current_object.total_amount.to_i )}
              page.call 'submit_my_form'
      end
  end
  
  def set_the_token
    username= "pathak_1259733727_biz_api1.gmail.com"
    password = "1259733733"
    signature= "A.gsseBoaG2XQonqoXpE4WUr4VafArVDPTPSg6gSo7rEoyqCTsE-yxWp"
    paypal = Paypal.new(username, password, signature)
    response = paypal.do_set_express_checkout(
      return_url="http://" + request.host_with_port + "/shopping_paypal_return",
      cancel_url="http://" + request.host_with_port + "/shopping_paypal_cancel",
      amount = session[:paypal_amount].to_i
    )
    @token = (response.ack == 'Success') ? response['TOKEN'] : ''
    session[:token] = @token
  end 
  
  
  def  paypal_return
    image_array = ['fworkimage','sworkimage','tworkimage','foworkimage','fiworkimage','siworkimage','seworkimage','eworkimage','nworkimage','teworkimage']
    sold_array = [ 'fsold=','ssold=','tsold=','fosold=','fisold=','sisold=','sesold=','eisold=','nsold=','tesold=']
    editionnamearray = ['fworkedname=','sworkedname=','tworkedname=','foworkedname=','fiworkedname=','siworkedname=','seworkedname=','eiworkedname=','niworkedname=','teworkedname=']
    editionnamearrayv = ['fworkedname','sworkedname','tworkedname','foworkedname','fiworkedname','siworkedname','seworkedname','eiworkedname','niworkedname','teworkedname']
    editionnumberarrayv = ['fworkednumber','sworkednumber','tworkednumber','foworkednumber','fiworkednumber','siworkednumber','seworkednumber','eiworkednumber','niworkednumber','teworkednumber']

    username = "pathak_1259733727_biz_api1.gmail.com"
    password = "1259733733"
    signature = "A.gsseBoaG2XQonqoXpE4WUr4VafArVDPTPSg6gSo7rEoyqCTsE-yxWp"
    paypal = Paypal.new(username, password, signature)
    response = paypal.do_get_express_checkout_details(session[:token])
    if response.ack == "Success"
       response = paypal.do_express_checkout_payment(token=session[:token],
       payment_action='Sale',
       payer_id=response.payerid,
       amount=session[:paypal_amount].to_i)#end of do express checkout method
       @current_object = Order.new_from_cart(session[:cart], @current_user)
       payment = Payment.new()
       payment.state = "online_validated"
       order = Order.complete_from_cart(session[:cart], @current_user)
       payment.invoice = order.generate_invoice(current_user,{"payment_medium"=>"paypal"})
       payment.user_id = current_user.id
       payment.amount_in_cents = session[:paypal_amount].to_i * 100
       payment.save
       order.save
       if session[:cart]  
             session[:cart].each do |k, v|
    		         if  k.split('_')[0] == "CompetitionsUser"
                    cu = CompetitionsUser.find(k.split('_')[1])      
                    editvalue = cu.send editionnamearrayv[image_array.index(k.split('_')[2])]
                    cu.send(editionnamearray[image_array.index(k.split('_')[2])],editvalue.to_i+1)
                    if( editvalue.to_i+1 > (cu.send(editionnumberarrayv[image_array.index(k.split('_')[2])])).to_i)  
                      cu.send (sold_array[image_array.index(k.split('_')[2])],true)
                    end
                    cu.save
                end
                if  k.split('_')[0] == "Artwork"
                    art = Artwork.find(k.split('_')[1])      
                    art.edition_name = art.edition_name.to_i + 1
                    if art.edition_name.to_i > art.edition_number.to_i
                      art.sold = true 
                    end
                    art.save
                end
                 if  k.split('_')[0] == "Groupshowartwork"
                  art = Groupshowartwork.find(k.split('_')[1])      
                  art.editionname = art.editionname.to_i + 1
                  if art.editionname.to_i > art.editionumber
                     art.sold = true
                  end
                  art.save
                end
            end    
       end 
       session[:cart] = {}
       redirect_to :action=>"show_me_cart",:payment_message=>"Your Payment Is Done"
    end 
  end

  
  def paypal_cancel
      redirect_to :action=>"show_me_cart" ,:payment_message=>"You Have Cancelled The PAyment"
  end 
   
   
   
   
  
end
