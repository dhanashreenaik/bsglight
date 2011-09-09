class VisitorsController < ApplicationController

	layout 'front'

	def home_page
		@pramoting_stuff = PromotingStuff.find(:all,:limit=>3,:order=>"created_at desc")
		@front_image = Frontendpic.find(:all,:conditions =>[" selectpic = ? ",1],:order=>"created_at desc")
    if logged_in?
      @competitionuserenteredlist = CompetitionsUser.find(:all,:conditions=>["user_id = ?   ",current_user.id])
       image_array = ['fworkimage','sworkimage','tworkimage','foworkimage','fiworkimage','siworkimage','seworkimage','eworkimage','nworkimage','teworkimage']	
       @useruploadedpics = []
        for compu in @competitionuserenteredlist
          for imgarname in image_array
              if !compu.send(imgarname.to_sym).blank?
                  @useruploadedpics << compu.send(imgarname.to_sym)
              end  
          end  
        end 
       @exhibitionuserlist = current_user.exhibitions_users.all(:include => [:exhibition], :order => 'created_at DESC')
       @edit_ex_img = {}
       for eul in @exhibitionuserlist
            if Artwork.find(:first,:conditions=>["user_id = ? and exhibition_id = ?",current_user.id,eul.exhibition.id])
              @edit_ex_img[eul.exhibition.id] = "true"
            end  
       end
       @groupshowusers = Usergroupshow.find(:all,:conditions=>[" user_id = ? ",current_user.id])
   end
  end
	def new
		@current_object = User.new
		@current_object.build_profile if @current_object.profile.nil?
  
    if params[:msg] == "buy artwork"
       flash[:notice] = "Need To Login To Buy Atrwork"
    end
		session[:compredirecid] = params[:id]
	end
	
	def login
    #self.current_user = User.find_by_email("kedar.pathak@pragtech.co.in")
    #p "im logged in"
    #p logged_in?  
    #this is for entering into a competition
   session[:compredirecid] = params[:id]
   if params[:msg]
      session[:buyartwork] = params[:msg].to_s.split("-")
   end
   #this is for buy the artwork
   if params[:comp]
      session[:comp] = params[:comp].to_s.split("-")
   end
   
 	end  

#  def create
#
#	end

	def mailing_list
		@profile = Profile.new
	end
   
    def studios
		@profile = Profile.new
	end
     
  def adding_profile
	  @profile = Profile.new
	  @studiosndmailinglist = StudioAndMailingList.new(params[:profile])
		if !params[:profile][:studio].blank?
			   @studiosndmailinglist.studio = true
			   @studiosndmailinglist.mailing_list=false
       	else
 		       @studiosndmailinglist.mailing_list=true
 	         @studiosndmailinglist.studio=false
		end
	   if  !StudioAndMailingList.find(:first,:conditions=>["email_address = ? and studio = ? and mailing_list = ?",@studiosndmailinglist.email_address,@studiosndmailinglist.studio,@studiosndmailinglist.mailing_list]).blank?
		       flash[:notice] = "Record Is Already There"
       else          
             if @studiosndmailinglist.save
			         flash[:notice] = "Your Name Was Added To Email List"
			            if !params[:profile][:studio].blank?
			                 	 QueuedMail.add('UserMailer', 'studio_notification',[@studiosndmailinglist.email_address,@studiosndmailinglist.first_name + " " + @studiosndmailinglist.last_name], 0, true)
                        else
                 		  	 QueuedMail.add('UserMailer', 'mailing_list_notification',[@studiosndmailinglist.email_address,@studiosndmailinglist.first_name + " " + @studiosndmailinglist.last_name], 0, true)	
			            end
			            redirect_to('/')
			            return
            end        
      end 	
      if params[:profile][:studio].blank?
       			render :action => 'mailing_list'
	   	else
     	render :action => 'studios'
	   	end 		     
  end
     
     
	

end
