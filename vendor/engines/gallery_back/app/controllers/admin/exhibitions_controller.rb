# This controller is managing the different actions relative to the Image item.
#
# It is using a mixin function called 'acts_as_item' from the ActsAsItem::ControllerMethods::ClassMethods,
# so see the documentation of that module for further informations.
#
class Admin::ExhibitionsController < Admin::ApplicationController
  
before_filter :workspace_id

def  workspace_id
   if params[:workspace_id].blank? and !params[:exhibition].blank?
    params["exhibition"]["workspace_ids"]=Workspace.find(:first, :conditions => { :creator_id => current_user.id}).id.to_s
end  
end

	# Method defined in the ActsAsItem:ControllerMethods:ClassMethods (see that library fro more information)
	acts_as_item do
		#Filter calling the encoder method of ConverterWorker with parameters
    before :new do
		       if !params[:workspace_id].blank?
		       if  Workspace.find(params[:workspace_id]).creator_id != 2  and  Workspace.find(params[:workspace_id]).creator_id != 1
		    
		       end
		        if  Workspace.find(params[:workspace_id]).creator_id != 2 and Workspace.find(params[:workspace_id]).creator_id != 1#admin and superadmin role should not be artist
			        User.find(Workspace.find(params[:workspace_id]).creator_id).update_attribute("system_role_id",8 )
			    end
		       end       
      @oldtimingperiodid =  @current_object.timing.period_id    if !@current_object.timing.blank?
			@current_object.build_timing 
			@places = Gallery.all
			sr = Role.find_by_name('artist')
			@artists = Profile.with_conditions_on_user({ :conditions => "users.system_role_id=#{sr.id}"}).all(:order => 'first_name ASC')
			session[:user_ids] = @current_object.user_ids
    	if  !params[:workspace_id].blank?
				@workspace = Workspace.find(params[:workspace_id])
			end
    end
    
  before :edit do
           if !params[:workspace_id].blank?
		       if  Workspace.find(params[:workspace_id]).creator_id != 2  and  Workspace.find(params[:workspace_id]).creator_id != 1
		    
		       end
		        if  Workspace.find(params[:workspace_id]).creator_id != 2 and Workspace.find(params[:workspace_id]).creator_id != 1#admin and superadmin role should not be artist
			        User.find(Workspace.find(params[:workspace_id]).creator_id).update_attribute("system_role_id",8 )
			    end
		       end       
      @oldtimingperiodid =  @current_object.timing.period_id    if !@current_object.timing.blank?
      
      #@current_object.build_timing 
			@places = Gallery.all
			sr = Role.find_by_name('artist')
			@artists = Profile.with_conditions_on_user({ :conditions => "users.system_role_id=#{sr.id}"}).all(:order => 'first_name ASC')
			p "before edit im user ids"
      p @current_object.user_ids
      session[:user_ids] = @current_object.user_ids
      session[:oldexhibitionusers] = @current_object.exhibitions_users
      
			if  !params[:workspace_id].blank?
				@workspace = Workspace.find(params[:workspace_id])
			end
    end
  
  

		after :create_fails, :update_fails do
       @current_object.errors.each do |x,y|
       end
			@current_object.build_timing if @current_object.timing.nil?
			@places = Gallery.all
			sr = Role.find_by_name('artist')
			@artists = Profile.with_conditions_on_user({ :conditions => "users.system_role_id=#{sr.id}"}).all(:order => 'first_name ASC')
    end

		before :create, :update do
      
			 # TODO manage the add for artists, just what they can access ...
		   if params[:group_show] == "0"
		         create_group_show
       else
         
       end
		end

       #i have commented it just for requirement it may be required to change it again
		#after :create, :update do
		#	@current_object.exhibitions_users.map{ |e| e.init }
		#end
    before :destroy do
     begin 
     exhibitionuser =  ExhibitionsUser.find(:all,:conditions=>["exhibition_id = #{@current_object.id}"])
     
     for exhu in exhibitionuser
       Invoice.delete_all("purchasable_type = 'ExhibitionsUser' and purchasable_id = #{exhu.id}") 
     end
     Artwork.delete_all("exhibition_id = #{exhu.exhibition.id}") 
     rescue
       logger.info "some database is not get deleted"
     end
    end  
  
    after :create do
          	@current_object.exhibitions_users.map{ |e| e.init }
    end
		after :update do
		 	      if  @current_object.user_ids.blank?
		            newuserid = []
		        else
                newuserid =  @current_object.user_ids
		        end
		        if  session[:user_ids].blank?
		            olduserid = []
		        else
		             olduserid = session[:user_ids]
		        end
		        new_user_id = newuserid - olduserid
            
            #here im re submitting the old exhibition user data
            session[:oldexhibitionusers].each do |exhu|
            
            if(!ExhibitionsUser.find(:first,:conditions=>["user_id = ? and exhibition_id = ?",exhu.user_id,exhu.exhibition_id]).blank?)
              
            else
            exnu=ExhibitionsUser.new(:user_id=>exhu.user_id,:exhibition_id=>exhu.exhibition_id,:state=>exhu.state,:price=>exhu.price,:invited_at=>exhu.invited_at,:created_at=>exhu.created_at,:updated_at=>exhu.updated_at)
            exnu.save
             #here i need to update the invoices also because the exhibition user id changed so invoice need to be changed
            inv = Invoice.find(:all,:conditions=>"purchasable_type = 'ExhibitionsUser' and purchasable_id = #{exhu.id}")
                inv.each do |invc|
                  invc.purchasable_id = exnu.id
                  invc.save
                end
            end
            
            end
    
            session[:user_ids]  = nil
            session[:oldexhibitionusers] = nil
            user = User.find(new_user_id)
            user.each do |u|
				        if !u.blank?
				            exhibitionuser = ExhibitionsUser.find(:first,:conditions=>["user_id= #{u.id} and exhibition_id=#{@current_object.id}"])
				            exhibitionuser.init
				            #  Notifier.deliver_website_role_change(u.email,u.profile.first_name + " " + u.profile.last_name ,"Artist",@current_object.title)
				            # QueuedMail.add('UserMailer', 'website_role_change',[u.email,u.profile.first_name + " " + u.profile.last_name ,"Artist",@current_object.title], 0, true)	
	                  # QueuedMail.send_emails
	              end
            end
            
            
   	end

   #     after :update do
   #     if params[:exhibitions] and params[:exhibitions][:publish] == "1"
   #         ExhibitionsUser.update_all "state = 'published'","exhibition_id = #{@current_object.id }"         
   #     end
   #     end
		before :show do
    	get_artworks_lists
  	end

  end

	def filtering_artworks
		@current_object = !params[:exhibition_id].blank? ? Exhibition.find(params[:id]) : Exhibition.new
    options = ""
		#raise current_workspace.contacts_workspaces.map{ |e| e.to_group_member(@current_user.id) }.delete_if{ |e| e['email'].first != params[:start_with] && params[:start_with] != "all"}.inspect
    @remaining_artworks.delete_if{ |e| e['title'].first != params[:start_with] && params[:start_with] != "all"}.each do |mem|
      options = options+ "<option value = '#{mem['id'].to_s}'>#{mem['title']}</option>"
    end
    render :update do |page|
      page.replace_html 'assignedArtworkOptions' ,:text => options
    end
  end

	def index_by_galleries
		@galleries = Gallery.all
		@galleries_ids = @galleries.map{ |e| e.id }
	end

    
	def submit_artworks
		@current_object = Exhibition.find(params[:id])
		if !@current_user.has_system_role('admin')
			params[:selectedOptions] += ",#{(@current_object.artworks - @current_user.private_workspace.artworks).map{ |e| e.id }.join(',')}" if params[:selectedOptions]
		end
		@current_object.artwork_ids= params[:selectedOptions].split(',')
		@current_object.save
		redirect_to item_path(@current_object)
	end
  
  def submit_exhibition_artwork
    artwork = Artwork.find(params[:id])
    @current_object = Exhibition.find(artwork.exhibition_id)
		#if !@current_user.has_system_role('admin')
		#	params[:selectedOptions] += ",#{(@current_object.artworks - @current_user.private_workspace.artworks).map{ |e| e.id }.join(',')}" if params[:selectedOptions]
		#end
		@current_object.artworks << artwork
		@current_object.save
  render :nothing=>true
  end
  
  def unselect_exhibition_artwork
    artwork = Artwork.find(params[:id])
    @current_object = Exhibition.find(artwork.exhibition_id)
		#if !@current_user.has_system_role('admin')
		#	params[:selectedOptions] += ",#{(@current_object.artworks - @current_user.private_workspace.artworks).map{ |e| e.id }.join(',')}" if params[:selectedOptions]
		#end
  	@current_object.artworks.delete(artwork)
		@current_object.save
    render :nothing=>true
  end
  
  def send_email_to_publish_user
    exhibitionuserlist = ExhibitionsUser.find(:all,:conditions=>"exhibition_id = #{params[:id]} and state = 'published'")
    @emailsendarray=[]
    @usernames = []
    exhibitionuserlist.each do |exhuser|
      @emailsendarray << exhuser.user.profile.email_address
      @usernames << exhuser.user.profile.first_name + " " + exhuser.user.profile.last_name
    end
    @usernames.uniq!
    @emailsendarray.uniq!
    @frommail = Frommail.find(:all)
    @exhibition = Exhibition.find(params[:id])
    render :layout=>"gallery_promoting_mail"
  end

  
  def  create_group_show
    groupshow = Groupshow.new
    groupshow.title = params[:exhibition][:title]
    groupshow.gallery_id = params[:exhibition][:timing_attributes][:gallery_ids].join(",")
    groupshow.description = params[:exhibition][:description]
    groupshow.note = params[:exhibition][:timing_attributes][:note]
    period = Period.find(params[:exhibition][:timing_attributes][:period_id])
    groupshow.starting_date = period.starting_date
    groupshow.ending_date = period.ending_date
    groupshow.save
    if !params[:exhibition][:user_ids].blank?
        @user = User.find(params[:exhibition][:user_ids])
        @user.each do |user|
          usergroupshow = Usergroupshow.new
          usergroupshow.groupshow_id = groupshow.id
          usergroupshow.user_id = user.id
          usergroupshow.state = "created"
          usergroupshow.save
        end
    end 
    flash[:notice] = "Your Group Show Is Created"
    redirect_to "/admin/groupshows/#{groupshow.id}"
  end
  
  def send_email_to_selected_user
    exhibitionuserlist = ExhibitionsUser.find(:all,:conditions=>"exhibition_id = #{params[:id]}")
    @emailsendarray=[]
    @usernames = []
    exhibitionuserlist.each do |exhuser|
      @emailsendarray << exhuser.user.profile.email_address
      @usernames << exhuser.user.profile.first_name + " " + exhuser.user.profile.last_name
    end
    @usernames.uniq!
    @emailsendarray.uniq!
    @frommail = Frommail.find(:all)
    @exhibition = Exhibition.find(params[:id])
    render :layout=>"gallery_promoting_mail"
  end
  
  def exhibition_selected_user_email
    @message = current_user.sent_messages.build(params[:message])
    @message.prepare_copies(params[:message][:email])
    @message.body =  @message.body + "<br/><font color='#FF0080'>" + params[:signature].to_s+"</font>"
    all_the_recipient = params[:message][:email].split(',')
    EmailSystem::deliver_email_notification(all_the_recipient,@message.subject,@message.body)
    if @message.save
      flash[:notice] = "Message sent."
      redirect_to :back
    else
      render :action => "send_mail_to_artist"
    end
  end
  
	protected
	def get_artworks_lists
		if @current_user.has_system_role('admin')
			@selected_artworks = @current_object.new_record? ? [] : @current_object.artworks
			#@remaining_artworks = @current_object.exhibitions_users.all(:conditions => { :state => ['validated', 'published', 'unpublished']}).map{ |e| e.user }.delete_if{ |e| !e.private_workspace }.map{ |e| e.private_workspace.artworks.find(:all,:conditions=>["exhibition_id = #{@current_object.id}"]) }.flatten - @selected_artworks
      @remaining_artworks = @current_object.exhibitions_users.all.map{ |e| e.user }.delete_if{ |e| !e.private_workspace }.map{ |e| e.private_workspace.artworks.find(:all,:conditions=>["exhibition_id = #{@current_object.id}"]) }.flatten - @selected_artworks
      
      @all_artworks = @remaining_artworks + @selected_artworks
      
      
		elsif ExhibitionsUser.exists?(:user_id => @current_user.id, :exhibition_id => @current_object.id, :state => ['validated', 'published', 'unpublished'])
      @selected_artworks = @current_object.new_record? ? [] : @current_object.artworks & @current_user.private_workspace.artworks
			# TODO hack for rights ...
			@remaining_artworks = @current_user.private_workspace.artworks - @selected_artworks
  	
    end
	end
  end


module Resourceful
  module Default
    module Actions
      def create
       
        
        build_object
        load_object
        before :create
        
      if params[:group_show] == "0"
         
      else    
        if current_object.save
          save_succeeded!
          after :create
          response_for :create
        else
          save_failed!
          after :create_fails
          response_for :create_fails
        end
      end  
      
      end
    end
  end
end