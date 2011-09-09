# This controller handles the functions relative to the session of a logged user.
#
class Admin::SessionsController < Admin::ApplicationController

	# Filter skipping the authentication for the following action, except for 'destroy' and 'change_language' actions.
  skip_before_filter :is_logged?, :except => [:destroy, :change_language]

	# To overwrite the layout define inside 'application_controller.rb' with the login layout.
  layout 'login'

	# Action managing session creation
	#
  # This function is creating a new session for given login and password,
	# or if the uthentication is not proved, it is redirecting on le login page.
	#
	# Usage URL :
	# - GET /login
  def create
    logout_keeping_session!
    #user = User.authenticate(params[:login], params[:password])
    user = User.authenticate_by_email(params[:email], params[:password])
   
    if user && user.activated_at
      # Protects against session fixation attacks, causes request forgery
      # protection if user resubmits an earlier form using back
      # button. Uncomment if you understand the tradeoffs.
      # reset_session
      self.current_user = user
      new_cookie_flag = (params[:remember_me] == "1")
      handle_remember_cookie! new_cookie_flag
			session[:cart] = {}
			#flash[:notice] = I18n.t('user.session.flash_notice')
			
      if (current_user.login == "admin" or current_user.login ==   "superadmin")
	      redirect_to admin_profiles_path
      else
             #redirect_back_or_default("/admin/profiles/#{current_user.id}")
             if session[:compredirecid].blank?
               if session[:buyartwork].blank?
                 if session[:comp].blank?
                    redirect_back_or_default("/")
                 else
                    redirect_to "/competitions/"+session[:comp][1].to_s
                 end
                 
                 
               else
                 redirect_to "/"+session[:buyartwork][1].to_s
                 session[:buyartwork]=nil
               end
             else  
               redirect_to "/competitions/"+session[:compredirecid].to_s  
             end  
             session[:compredirecid] = nil                
      end	       
      
      
    else
      flash[:error] =  I18n.t('user.session.login_error')+' '+params[:login].to_s
			logger.warn "Failed login for '#{params[:login]}' from #{request.remote_ip} at #{Time.now.utc}"
      @login       = params[:login]
      @remember_me = params[:remember_me]
      flash[:error] = I18n.t('user.session.flash_error')
      redirect_back_or_default('/admin')
    end
  end

  # Action managing session deletion
	#
	# This function is destroying the session of the current user, updating his 'last_connected_at' field,
	# and redirecting on the root page.
	#
  # Usage URL :
  # - GET /logout
  def destroy
    if params[:id]
      User.find(params[:id]).update_attributes(:last_connected_at => Time.now)
    end
    logout_killing_session!
    #flash[:notice] = I18n.t('user.session.logout_notice')
    redirect_back_or_default('/')
  end

end
