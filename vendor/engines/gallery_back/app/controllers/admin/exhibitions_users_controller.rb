# This controller is managing the different actions relative to the Image item.
#
# It is using a mixin function called 'acts_as_item' from the ActsAsItem::ControllerMethods::ClassMethods,
# so see the documentation of that module for further informations.
#
class Admin::ExhibitionsUsersController < Admin::ApplicationController

	def send_invitation
		@current_object = ExhibitionsUser.find(params[:id])
   
		@current_object.generate_invoice(@current_object.user)
         invoice = Invoice.find(:first,:conditions=>["purchasable_type = ? and  client_id = ?  and purchasable_id = ?","ExhibitionsUser" , @current_object.user,@current_object.id])
   	 logger.info "pdf is get created"
	     create_pdf(invoice.id,invoice.number,@current_object.exhibition.timing.starting_date.strftime("%d %b %Y"),invoice.client.profile.full_address_for_invoice,invoice.client.profile.full_name_for_invoice,@current_object.exhibition.title,@current_object.price.to_i,@current_object.exhibition.timing.note,@current_object.price.to_i,0,true,@current_object.exhibition.timing.ending_date.strftime("%d %b %Y"),invoice.final_amount.to_i)
       
    	logger.info "created the invoice and sending same with email #{invoice.id}"
    
    
    if QueuedMail.add('UserMailer','send_invoice_exhibition',[@current_object.user.profile.email_address,"invoice#{invoice.id}","An Invoice Is Sent To Your Email. Please Make The Payment by Login To This Account.",invoice, @current_object.user],0,true,@current_object.user.profile.email_address,"test@pragtech.co.in")
			flash[:notice] = "Invitation sent"
		else
			flash[:error] = "Error sending invitation"
		end
		@current_object.state = 'invited'
		@current_object.invited_at = Time.now
		@current_object.save
		redirect_to item_path(@current_object.exhibition)
	end

  
  def delete_user
    exus = ExhibitionsUser.find(params[:id])
    artwork=Artwork.find(:all,:conditions=>["user_id = ? and exhibition_id = ?",exus.user_id,exus.exhibition_id])
    artwork.each do |art|
    ArtworksExhibition.delete_all("artwork_id = #{art.id}")
    end
    Invoice.delete_all("purchasable_type = 'ExhibitionsUser' and purchasable_id = #{exus.id}") 
    ExhibitionsUser.delete_all(params[:id])
    
     
    
    
    flash[:notice] = "Exhibition User is Deleted"
    redirect_to :back
  end
  
  
	def update_state
       	@current_object = ExhibitionsUser.find(params[:id])
		if params[:state] == 'accepted'
			@current_object.state = params[:state]
			@current_object.setting_the_price
			@current_object.save
			if @current_object.invoices.empty?
				redirect_to invoicing_admin_invoices_url(:purchasable_type => @current_object.class.to_s, :purchasable_id => @current_object.id)
			else
				raise "Invoice already there ..."
				redirect_to admin_invoice_url(@current_object.invoices.first)
			end
		end
#		if params[:state] == 'validated' && @current_user.has_system_permission('admin')
#			@current_object.state = params[:state]
#			UserMailer.deliver_validate_payment(@current_object.exhibition, @current_object.user)
#		end
		if params[:state] == 'published' || params[:state] == 'unpublished'
			@current_object.state = params[:state]
			@current_object.save
			redirect_to item_path(@current_object.exhibition)
		end
		
	end

	def set_prices
		eu = nil
		params[:prices_list].delete_if{ |k,v| v.nil? }.each do |k, v|
			eu = ExhibitionsUser.find(k)
			eu.price = v
			eu.save
		end
		redirect_to item_path(eu.exhibition)
	end

end
