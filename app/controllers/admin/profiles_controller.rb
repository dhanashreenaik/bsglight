class Admin::ProfilesController < Admin::ApplicationController
  
  def show_columns
    if params[:id]
      Timing.delete_all(" id = #{params[:id]}")
    end
    @exhibition = Exhibition.find(:last)
    Timing.delete_all(" id >= #{@exhibition.id} and objectable_type = 'Exhibition'")
    @exhibition = Competition.find(:last)
    Timing.delete_all(" id >= #{@exhibition.id} and objectable_type = 'Competition'")
    
    @timing=Timing.find(:all)
    @string=""
    @timing.each do |x|
      @string << x.id.to_s + "id"+ x.objectable_id.to_s + " " + x.objectable_type + "<br/>"
    end
    
    render :text=>"imshow coluns"+@string
  end
  
  
  
  
	acts_as_ajax_validation

  # GET /profiles
  # GET /profiles.xml
  def index
      if  current_user.login == "admin" || current_user.login == "superadmin"
		    @current_objects = Profile.superadmin_filtered.all(:order => 'first_name asc')
		    @num = @current_objects.size
        respond_to do |format|
          format.html # index.html.erb
          format.xml  { render :xml => @current_objects }
        end
     else
        flash[:notice] = "Please Login As Admin to View All The Users List"
        redirect_to "/admin"
     end   
        
  end

	def filter
 		if params[:category_ids]
			@current_objects = []
			params[:category_ids].each do |cat|
				@current_objects += ProfilesCategory.find(:all, :conditions => { :category_id => cat.to_i }).map{ |e| e.profile }
			end
			@current_objects.uniq!
			# TODO integrate to searchable, special filter for join table :join_checking{ |model_join, ids| } field=name & jointable conventional
#			raise "tamerellepue"
		else
			@current_objects = Profile.find(:all, :order => 'first_name asc')
		end
		@num = @current_objects.size
		@filters = params[:category_ids].map{ |e| e.to_i }
   
    @newsletter = Newsletter.find(:all)
		respond_to do |format|
      format.html { render :template => 'admin/profiles/index.html.erb'}
      format.xml  { render :xml => @current_objects }
    end
	end

  # GET /profiles/1
  # GET /profiles/1.xml
 def show
   if  current_user.login == "admin" || current_user.login == "superadmin"  
    
    @current_object = Profile.find(params[:id])
		#@my_subscription = CompetitionsUser.find(:last);
    @artworkexhibition = Artwork.find(:all,:conditions=>["user_id = ? and exhibition_id = ?",@current_user.id,@current_object.id])
    #@folder = @current_object.user.inbox
    @messages = @current_object.user.sent_messages.paginate :conditions=>["deletedm = ? or deletedm is null",false], :per_page => 500, :page => params[:page], :order => "created_at DESC"
    #@messages = current_user.sent_messages.paginate :conditions=>["deletedm = ? or deletedm is null ",false], :per_page => 500, :page => params[:page], :order => "created_at DESC"
     @message_recd = []
    #above are the recd message and below are the sent message
    #adminuser = User.find_by_login("admin")
    @current_object.user.received_messages.each do |mc|
      @message_recd << mc.message
    end
    #@messages.flatten!
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @current_object }
    end
   else
      flash[:notice] = "Please Login As Admin to View All The Users List"
      redirect_to "/admin"
   end
    
    
  end
  
  def compose_user_mail
     @message = current_user.sent_messages.build
     @frommail = Frommail.find(:all)
     @sendusermail=User.find(params[:id])
     render :layout=> "gallery_promoting_mail"
  end
  
  def create_sent_mail
    @message = current_user.sent_messages.build(params[:message])
    @message.prepare_copies(params[:user][:email])
    @message.body =  @message.body + "<br/><font color='#FF0080'>" + params[:signature].to_s+"</font>"
    all_the_recipient = params[:user][:email].split(',')
    EmailSystem::deliver_email_notification(all_the_recipient,@message.subject,@message.body)
    if @message.save
      flash[:notice] = "Message sent."
      redirect_to :back
    else
      flash[:notice] = "Please Try Again There Was a Problem In Sending an Email."
      redirect_to :back
    end
  end
  
   def exhibition_payment 
        exhibitionuser = ExhibitionsUser.find(params[:id])
        @invoice = Invoice.find(:first,:conditions=>["purchasable_type = ? and  client_id = ?  and purchasable_id = ? ","ExhibitionsUser" , exhibitionuser.user,exhibitionuser.id])
        if  @invoice != nil and @invoice.state == "created"
        else
        @invoice = Invoice.find(:last,:conditions=>["purchasable_type = ? and  client_id = ? and purchasable_id = ?","ExhibitionsUser" , exhibitionuser.user,exhibitionuser])
        end
        @order = exhibitionuser
    		@credit_card = CreditCard.new	
		    session[:purchasable] = exhibitionuser
		    render :partial=>"exhibitionpayment"
   end
     
    def exhibition_payment_front 
        
        alreadypaidamt = nil
        exhibitionuser = ExhibitionsUser.find(params[:id])
        @invoice = Invoice.find(:first,:conditions=>["purchasable_type = ? and  client_id = ?  and purchasable_id = ? ","ExhibitionsUser" , exhibitionuser.user,exhibitionuser.id])
        if  @invoice != nil and @invoice.state == "created"
        else
        @invoice = Invoice.find(:last,:conditions=>["purchasable_type = ? and  client_id = ? and purchasable_id = ?","ExhibitionsUser" , exhibitionuser.user,exhibitionuser])
        alreadypaidamt = exhibitionuser.price - @invoice.final_amount
        end
        @order = exhibitionuser
    		@credit_card = CreditCard.new	
		    session[:purchasable] = exhibitionuser
		    #render :partial=>"exhibitionpaymentfront"
	  	  render :update do |page|
		        page["enterintocompetitionfront"].replace_html :partial=>"exhibitionpaymentfront",:locals=>  {:order=>@order,:invoice=>@invoice,:exhibitionuser=>exhibitionuser,:credit_card=>@credit_card,:alreadypaidamt=>alreadypaidamt}
		        page["description_competition_ex_py"].show
		        page["iteam_image_uploaded"].hide
            page["useruploadedpic"].hide
		        for k in 0..9
		              page["iteam_image#{k}"].hide
            end
		    end
    end
     
     
     
     
  # GET /profiles/new
  # GET /profiles/new.xml
  def new
    @current_object = Profile.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @current_object }
    end
  end

  # GET /profiles/1/edit
  def edit
    @current_object = Profile.find(params[:id])
    @role = Role.find(:all)
  end
    
  def edit_password
      render :action=>"password"  
  end  
  
  def change_password
      @user = User.find(params[:id])
      @user.password = params[:user][:password]
      @user.password_confirmation = params[:user][:password_confirmation]
      if @user.save
        flash[:notice] = "Password Has Been Changed For #{@user.profile.first_name} #{@user.profile.last_name}"
        redirect_to :back
      else
       
        flash[:notice] = "Password Has Not Been Changed"
      redirect_to :back
        
      end  
  end  
  
    

  
  # POST /profiles
  # POST /profiles.xml
  def create
    @current_object = Profile.new(params[:profile])
    respond_to do |format|
      if @current_object.save
		 @current_object.create_profile_workspace
        flash[:notice] = 'Profile was successfully created.'
        format.html { redirect_to admin_profile_path(@current_object.id) }
        format.xml  { render :xml => @current_object, :status => :created, :location => @current_object }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @current_object.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /profiles/1
  # PUT /profiles/1.xml
  def update
    @role = Role.find(:all)
    @current_object = Profile.find(params[:id])
    respond_to do |format|
      
      if @current_object.update_attributes(params[:profile])
				@current_object.create_profile_workspace if @current_object.profile_workspace.nil?
				if user = @current_object.user
					user.email = @current_object.email_address
					user.system_role_id = params[:system_role_id]
					user.save
				end
        flash[:notice] = 'Profile was successfully updated.'
        format.html { redirect_to admin_profile_path(@current_object.id) }
        format.xml  { head :ok }
      else
        flash[:notice] = "Problem in saving the profile "+@current_object.errors.first[1]
        format.html { render :action => "edit" }
        format.xml  { render :xml => @current_object.errors, :status => :unprocessable_entity }
      end
    end
  end
  # DELETE /profiles/1
  # DELETE /profiles/1.xml
  def destroy
    @current_object = Profile.find(params[:id])
    User.delete_all("id = #{@current_object.user_id}")
    @current_object.destroy

    respond_to do |format|
      format.html { redirect_to(admin_profiles_url) }
      format.xml  { head :ok }
    end
  end

	def update_notices
	    @current_object = Profile.find(params[:id])
			#@current_oject.notices = @current_oject.notices
			@current_object.notices = params[:notice]
      @current_object.save
			flash[:notice] = "Profile Is Updated"
			redirect_to :back		
	end
  
  def show_message_sent
    
    @message = Message.find(params[:id])
       render :update do |page|
        page["show_message_details"].replace_html(:partial =>'message_sent_detail', :object =>@message)
        page["ajax_spinner"].visual_effect :hide
      end
  end

  
  
  def show_message_recd
    
  
  @message = current_user.sent_messages.find(params[:id])
       render :update do |page|
        page["show_message_details"].replace_html(:partial =>'message_sent_detail', :object =>@message)
        page["ajax_spinner"].visual_effect :hide
      end
  end
  
  
end
