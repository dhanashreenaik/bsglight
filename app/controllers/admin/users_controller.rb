class Admin::UsersController < Admin::ApplicationController
   
  acts_as_ajax_validation
	acts_as_authorizable(
		:actions_permissions_links => {
				'edit' => 'edit',
				'update' => 'edit',
				'show' => 'show',
				'destroy' => 'destroy',
				'locking' => 'destroy'
			},
		:skip_logging_actions => [:new, :create, :validate, :forgot_password, :reset_password, :activate])
	#layout 'application', :expect => [:new, :create]
	layout :give_da_layout
  # Check Current User Status and Give the Layout
	def give_da_layout 
		if params[:action] == 'forgot_password' || params[:action] == 'reset_password'
			if logged_in?
				return get_current_layout
			else
				return 'login'
			end
		else
			return get_current_layout
		end
	end

	def show
    
    
    
		@current_object = User.find(params[:id])
		@profile = @current_object.profile
		respond_to do |format|
			format.html { render :action => 'show' }
		end
	end

	def new
   	@current_object = User.new
    if params[:email]
       @current_object.email = params[:email]
    end
    
    
		if (!current_user && is_allowed_free_user_creation?) || (current_user && @current_object.has_permission_for?('new', @current_user, current_container))
			@current_object.build_profile if @current_object.profile.nil?
			respond_to do |format|
				if !current_user
					format.html { render :action => 'new', :layout => 'login' }
				else
					format.html { render :action => 'new' }
				end
			end
		else
			no_permission_redirection
		end
	end

	def edit
		@current_object = User.find(params[:id])
		@current_object.build_profile if @current_object.profile.nil?
		#@profile = @current_object.profilable || ProfileBase.new
		respond_to do |format|
			format.html { render :action => 'edit' }
			#format.js { render :partial => "#{params[:profile].pluralize}/form", :layout => false }
		end
	end
     
     def destroy
     user = User.find(params[:id])
     Artwork.delete_all(:user_id=>user.id)
     CreditCard.delete_all(:user_id=>user.id)
       
     user.destroy
     flash[:notice] = "User Has Been Destroyed"
     redirect_to :back
     end
  
	def create
	   admin_logged_in = false
     if logged_in?
 	    admin_logged_in=current_user
     end
	  @current_object = User.new(params[:user])
		@current_object.build_profile if @current_object.profile.nil?
		if (!current_user && is_allowed_free_user_creation?) || (current_user && @current_object.has_permission_for?('new', @current_user, current_container))
			if @current_object.login.nil?
			   @current_object.auto_login
			end
			@current_object.profile.email_address = @current_object.email if @current_object.profile
			@current_object.system_role_id = Role.find(:first, :conditions => { :name => 'artist' }).id if !@current_object.system_role_id || !@current_user.has_system_role("admin")
			respond_to do |format|
					if @current_object.save
						if is_given_private_workspace
							@current_object.create_private_workspace_with_role('private_user')
						end
						@current_object.accessing_public_containers_with_role('workspace', 'reader')
						flash[:notice] = I18n.t('user.new.flash_notice')
						session[:latest_register] = true
						if  admin_logged_in
						session[:latest_register] = false
						   flash[:notice]="User Has Been Successfully created"
						   self.current_user = admin_logged_in
                email= UserMailer.create_admin_register_user(@current_object)
                UserMailer.deliver(email)
                Tempraryinbox.delete_all("fromemail = '#{@current_object.email}'")
                Tempraryinbox.delete_all("fromemail = '#{@current_object.email}'")
               redirect_to admin_profiles_path
                           return
                        end
						if session[:compredirecid].blank?
						        self.current_user = @current_object
								    redirect_to "/"
								    
				    	return
						else
						self.current_user = @current_object
						#here i need to put the competition url
						#redirect_to  session[:return_to].to_s + "?user_id="+@current_object.id.to_s + "&&email="+@current_object.email
						  redirect_to "/competitions/"+session[:compredirecid]
						  session[:compredirecid] = nil
				       return
				    end
                        
				        else
                  mssg = ""
                  @current_object.errors.each do |attr,msg|
                   mssg << " " + msg 
                  
                  end
        		flash[:error] = I18n.t('user.new.flash_error') + " " +mssg
						if !@current_user
          		format.html { render :template => "#{RAILS_ROOT}/vendor/engines/gallery_front/app/views/visitors/new.html.erb", :layout => 'front' }
						else
							format.html { render :action => :new }
            end

				    end
                
			        end
		else
			no_permission_redirection
		end
	end

	def update
		@current_object = User.find(params[:id])
		# TODO check user right for that profile
#		@profile = @current_object.profilable
#		tmp_profile = @profile
		params[:user][:profile_attributes][:category_ids] ||= []
		@current_object.attributes= params[:user]
		@current_object.profile.email_address = @current_object.email
#		raise @current_user.profile.email_address.inspect
#		# Check in case of a new profile ...
#		if (@profile.class.to_s != @current_object.profilable_type)
#			@profile = @current_object.profilable_type.classify.constantize.new(params[@current_object.profilable_type.to_sym])
#		else
#			@profile.attributes= params[@current_object.profilable_type.to_sym]
#		end
		respond_to do |format|
				if @current_object.save #&& @profile.save
					if is_given_private_workspace && @current_object.private_workspace.nil?
						@current_object.create_private_workspace
					end
					flash[:notice] = I18n.t('user.edit.flash_notice')
					format.html { redirect_to admin_user_path(@current_object) }
			else
			 
				flash[:error] = I18n.t('user.edit.flash_error')
				format.html { render :action => :edit }
			end
		end
	end

	def locking
		current_object
		if @current_object.activation_code == 'unlocked'
			if @current_object.lock
				flash[:notice] = I18n.t('user.locking.lock_flash_notice')
			else
				flash[:error] = I18n.t('user.locking.flash_error')
			end
		else
			if @current_object.unlock
				flash[:notice] = I18n.t('user.locking.unlock_flash_notice')
			else
				flash[:error] = I18n.t('user.locking.flash_error')
			end
		end
		redirect_to admin_users_path
	end

	def index
		current_objects
	  respond_to do |format|
			format.html {  }
			format.js { render :layout => false }
			format.xml { render :xml => @current_objects }
			format.json { render :json => @current_objects }
      format.atom { render :template => "users/index.atom.builder", :layout => false }
		end
	end

  # Users Index Object for All Users
	def current_objects #:nodoc:
	  params[:container_type] = 'workspace'
    params_hash = setting_searching_params(:from_params => params)
    params_hash.merge!({:skip_pag => true}) if params[:format] && params[:format] != 'html'
    if @current_user.has_system_role('admin')
		  @current_objects ||= User.get_da_objects_list(params_hash)
		else
		  @current_objects ||= User.get_da_objects_list(params_hash).delete_if{|u| u.has_system_role('superadmin')}
		end
	end

  # AutoComplete for Users in TextBox
  #
  # Usage URL
  #
  # /users/autocomplete_on
  def autocomplete_on
    conditions = if params['login']
      ["login LIKE :login OR firstname LIKE :login OR lastname LIKE :login",
        { :login => "%#{params['login']}%"}]
    else
      {}
    end
    @objects ||= User.find(:all, :conditions => conditions)
    render :text => '<ul>'+@objects.map{ |e| "<li>#{e.login} (#{e.full_name})</li>" }.join(' ')+'</ul>'
  end
	
  # Function allowing to activate the user with the RESTful authentification plugin
  #
  # Usage URL
  #
  # /users/activate
  def activate
    activating_user = params[:activation_code].blank? ? false : User.find_by_activation_code(params[:activation_code])
    if activating_user && !activating_user.active?
      activating_user.activate
      flash[:notice] = "Subscription complete !"
		else
			flash[:error] = "Action failed !"
		end
    redirect_to '/login'
  end

  # Function allowing to gain his password by email in case of forgot
  #
  # Usage URL
  #
  # /forgot_password
  def forgot_password
    return unless request.post?
    if @user = User.find_by_email(params[:user][:email])
      @user.create_reset_code
      flash[:notice] = I18n.t('user.forgot_password.flash_notice')
      redirect_to admin_login_path
    else
      flash[:error] = I18n.t('user.forgot_password.flash_error')
      render :action => "forgot_password"
    end
  end
 
  # Function allowing to reset the password of the current user after to have received a reset link in an email
  #
  # Usage URL
  #
  # /reset_password
  def reset_password
    if (@user = User.find_by_password_reset_code(params[:password_reset_code]) unless params[:password_reset_code].nil?)
      if request.post?
        if @user.update_attributes(:password => params[:user][:password], :password_confirmation => params[:user][:password_confirmation])
          self.current_user = @user
          @user.delete_reset_code
          flash[:notice] = "#{@user.login},"+I18n.t('user.reset_password.flash_notice')
          redirect_to admin_login_path
        else
          flash.now[:error] = I18n.t('user.reset_password.flash_error')
          render :action => :reset_password
        end
      end
    else
      flash[:error] = I18n.t('user.reset_password.flash_error_link')
      redirect_to admin_login_path
    end
  end

  # Overwritting the AjaxValidation plugin to manage the permission
  #
  # /users/validate
  def validate
    model_class = params['model'].classify.constantize
    @model_instance = params['id'] ? model_class.find(params['id']) : model_class.new
    @model_instance.send("#{params['attribute']}=", params['value'])
    @model_instance.valid?
    render :inline => "<%= error_message_on(@model_instance, params['attribute']) %>"
  end

  # allow only post pethod to resend activation mail again or activate manually by admin only and parameter id is user's activation_code
  def resend_activation_mail_or_activate_manually
    if @current_user.has_system_role('admin') and @user = User.find_by_activation_code(params[:id])
      UserMailer.deliver_signup_notification(@user) if !params[:resend_activation_mail].nil?
      @user.activate if !params[:activate_manually].nil?
      redirect_to admin_users_path
    else
      flash[:error] = I18n.t('general.common_message.permission_denied')
      redirect_to admin_login_path
    end
  end

end
























