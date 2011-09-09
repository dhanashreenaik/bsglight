# This controller is managing the different actions relative to the Image item.
#
# It is using a mixin function called 'acts_as_item' from the ActsAsItem::ControllerMethods::ClassMethods,
# so see the documentation of that module for further informations.
#
class Admin::CompetitionsController < Admin::ApplicationController
  
   before_filter :workspace_id

    def  workspace_id
       if  params["competition"] && params["competition"]["workspace_ids"].blank?
        params["competition"]["workspace_ids"]=Workspace.find(:first, :conditions => { :creator_id => current_user.id}).id.to_s
       end
       
    end

	def  send_winner_email
      @artworks_competition = ArtworksCompetition.find(params[:id])
	    QueuedMail.add('UserMailer', 'send_winner_email',[@artworks_competition,@artworks_competition.competitions_user.user], 0, send_now=true)	
	    flash[:notice]="The Email Is Sent To  #{@artworks_competition.competitions_user.user.profile.full_name}"
	    redirect_to :back
  end

  def send_mail_to_artist

    @total_selected = ArtworksCompetition.find(:all,:conditions => "competition_id = #{params[:id]} and state = '#{params[:msg]}'")
    @emailsendarray=[]
    @usernames = []
    @total_selected.each do |arc|
    @emailsendarray << arc.competitions_user.user.profile.email_address
    @usernames << arc.competitions_user.user.profile.first_name + " " + arc.competitions_user.user.profile.last_name
    @usernames.uniq!
    @emailsendarray.uniq!
    end

    puts "********************************8"
    @competition = Competition.find(params[:id])
    puts @competition.id
    @artwork= ArtworksCompetition.find(:first,:conditions => ["competition_id=?",@competition.id])
    puts @artwork.inspect
    puts "***********************************8"
    @frommail = Frommail.find(:all)
    render :layout=>"gallery_promoting_mail"
  end
  
  def send_winner_email
    @artselected = ArtworksCompetition.find(params[:id])
    @emailsendarray=[]
    @usernames = []
    
    @emailsendarray << @artselected.competitions_user.user.profile.email_address
    @usernames << @artselected.competitions_user.user.profile.first_name + " " + @artselected.competitions_user.user.profile.last_name
    @usernames.uniq!
    @emailsendarray.uniq!
    
    @competition = Competition.find(@artselected.competition_id)
    @frommail = Frommail.find(:all)
    render :layout=>"gallery_promoting_mail"
  end
  
  def compcreate_sent_mail_to_artist
    if !params[:artworkcompetition].blank?#this is for single winner for send_winner_email
       artwcomp = ArtworksCompetition.find(params[:artworkcompetition])
       if artwcomp.state == "winner"
          artwcomp.prize_detail = "winner of "+artwcomp.competition.title.to_s + "  " +params[:prize]
          artwcomp.save
       end
    end
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
  
  
  def compfind_signature_label
     signature = Signature.find(:all,:conditions=>["frommail_id = ?",params[:fromemail]])  
     render :update do |page|
        page["update_label"].replace_html(:partial =>'find_signature_label', :object =>signature)
     end
  end
  def compfind_signature
     signature = Signature.find(params[:fromemail])  
     render :update do |page|
        page.call("set_the_signature",signature.signature)
     end
  end
 	
  # Method defined in the ActsAsItem:ControllerMethods:ClassMethods (see that library for more information)
	acts_as_item do
		before :new, :edit do
       
       columnnameandheader = Columnnameandheader.find(:all,:conditions=>["idoffieldwithtablename = ?",@current_object.id.to_s+"competition"])
	     @oldlabelvalue={}
	     columnnameandheader.each do |x|   
	       @oldlabelvalue[x.column_name] = x.column_header
	     end
       
			@places = Gallery.all
			@current_object.build_timing if @current_object.timing.nil?
			@judges = User.find(:all, :conditions => "system_role_id=2 OR system_role_id=#{Role.find_by_name('judge').id}")
			@current_object.competitions_subscriptions.build if @current_object.competitions_subscriptions.empty?
		end
		
	   before :update do

       begin
         @current_object.submission_deadline = Date.civil(params[:competition][:submission_deadline].split("-")[0].to_i,params[:competition][:submission_deadline].split("-")[1].to_i,params[:competition][:submission_deadline].split("-")[2].to_i)
	     rescue
	     end
	   end
	   before :create do
             begin
             @current_object.submission_deadline = Date.civil(params[:competition][:submission_deadline].split("-")[0].to_i,params[:competition][:submission_deadline].split("-")[1].to_i,params[:competition][:submission_deadline].split("-")[2].to_i)
	          rescue
	          end
	   end
      after :create do
              params.to_hash.each do |key,value|
                   if key.include? "header"
                      columnnameandheader = Columnnameandheader.new
                      columnnameandheader.column_name = key.split("header")[1]        
                      columnnameandheader.column_header = value
                      columnnameandheader.idoffieldwithtablename = (@current_object.id.to_s+"competition")
                      columnnameandheader.save
                   end 
               end      
      end  
after :update do

              Columnnameandheader.delete_all(["idoffieldwithtablename = ?",@current_object.id.to_s+"competition"])
              params.to_hash.each do |key,value|
                
                   if key.include? "header"
                      columnnameandheader = Columnnameandheader.new
                      columnnameandheader.column_name = key.split("header")[1]        
                      columnnameandheader.column_header = value
                      columnnameandheader.idoffieldwithtablename = (@current_object.id.to_s+"competition")
                      columnnameandheader.save
                   end 
               end 
      
      end  




		



		
		after :create_fails, :update_fails do
			#raise @current_object.errors.inspect
			@places = Gallery.all
			@current_object.build_timing if @current_object.timing.nil?
			@judges = User.find(:all, :conditions => "system_role_id=1 OR system_role_id=2")
			@current_object.competitions_subscriptions.build if @current_object.competitions_subscriptions.empty?
      
   	end

    
    
    
    
      before :destroy do
				
		  @current_object.competitions_users.each do |cu|
		    Invoice.delete_all("purchasable_id = #{cu.id} and purchasable_type = 'CompetitionsUser'")
		  end    
      
      end 
      
      		
		
		before :show do
       
        
        @total_artist = CompetitionsUser.count(:conditions => "competition_id = #{@current_object.id}")
        @total_entry = ArtworksCompetition.count(:conditions => "competition_id = #{@current_object.id}")
        @total_selected = ArtworksCompetition.count(:conditions => "competition_id = #{@current_object.id} and state = 'selected'")
        @total_unselected = ArtworksCompetition.count(:conditions => "competition_id = #{@current_object.id} and state = 'unselected'")
        @total_maybe = ArtworksCompetition.count(:conditions => "competition_id = #{@current_object.id} and state = 'maybe'")
        @winner_selected = ArtworksCompetition.count(:conditions => "competition_id = #{@current_object.id} and state = 'winner'")
        @total_price = 0
        @total_artist_paid = CompetitionsUser.find(:all,:conditions => "competition_id = #{@current_object.id} ")
        @total_artist_paid_id = []
        @total_artist_paid.each do |tap|
        @total_artist_paid_id << tap.id    
        end

     
        if !@total_artist_paid_id.blank? 
          @invoice = Invoice.find(:all,:conditions=>"purchasable_type = 'CompetitionsUser' and state = 'validated' and (payment_medium = 'paypal' or payment_medium = 'online' or payment_medium = 'online_validated') and purchasable_id in (#{@total_artist_paid_id.join(',')})")
        end
      
      if !@invoice.blank?
          @invoice.each do |inv|
            @total_price = @total_price + inv.final_amount
          end
        end
        
			if @current_object.state == 'results_publish'
				 @artworks_competitions = @current_object.artworks_competitions.all(:conditions=>["competitions_users_id != 'null' and state = 'winner' or state =  'selected' or  state = 'unselected' "], :order => "mark DESC")
    	elsif @current_object.state == 'final_published'
				 @artworks_competitions = @current_object.artworks_competitions.all( :conditions => ["state =  'selected' or state = 'winner' or  state = 'unselected' and competitions_users_id != 'null' "])
      
			else
				 @artworks_competitions = @current_object.artworks_competitions.all(:conditions=>["competitions_users_id != 'null'  "])
         puts "^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^"
         puts @artworks_competitions.inspect
         
      
         #@artworks_competitions =  CompetitionsUser.find(:all,  :conditions => { :competition_id =>  @current_object.id })
			end
			get_artworks_lists
			@my_subscription = CompetitionsUser.find(:first,  :conditions => { :user_id => @current_user.id, :competition_id => @current_object.id })
		end
		
	end
  def change_state
    @current_object = Competition.find(params[:competition_id])
    @current_object.update_attributes(:state => params[:new_state])
    redirect_to :back
  end
	def submit_artworks
		@current_object = Competition.find(params[:id])
		if @current_user.has_system_role('admin')
			@current_object.artwork_ids = params[:selectedOptions].split(',')
			@current_object.save
		elsif a=CompetitionsUser.find(:first, :conditions => { :user_id => @current_user.id, :competition_id => @current_object.id })
			my_subscription = a.competitions_subscription
			params[:selectedOptions] += ",#{(@current_object.artworks - @current_user.private_workspace.artworks).map{ |e| e.id }.join(',')}" if params[:selectedOptions]
			@current_object.artwork_ids= params[:selectedOptions].split(',')[0..my_subscription.maximum_works_number-1]
			@current_object.save
		end
		redirect_to item_path(@current_object)
	end

    def open
			@competitionuser = CompetitionsUser.find(:all,:conditions=>["competition_id = ?   ",params[:id]])
    end
   	
   	def finalist
   	      competitionuser = CompetitionsUser.find(:all,:include=>["artworks_competitions"],:conditions=>["competition_id = ?   ",params[:id]])
                @competitionuser  = []
                competitionuser.each do |ac| 
                ac.artworks_competitions.each do |x|  
                  if x.state == "selected"
                  @competitionuser  << x.competitions_user
                  end
               end 
   	end
   	@competitionuser.uniq!
	end
	
	def winner
	         competitionuser = CompetitionsUser.find(:all,:include=>["artworks_competitions"],:conditions=>["competition_id = ?   ",params[:id]])
                @competitionuser  = []
                competitionuser.each do |ac| 
                ac.artworks_competitions.each do |x|  
                  if x.state == "selected"
                  @competitionuser  << x.competitions_user
                  end
               end 
   	end
   	@competitionuser.uniq!
	end
	
	
	private

	def get_artworks_lists
		if @current_user.has_system_role('admin')
			@selected_artworks = @current_object.new_record? ? [] : @current_object.artworks
			

			@remaining_artworks = @current_object.competitions_users.map{ |e| e.user }.delete_if{ |e|;
        if e 
          !e.private_workspace 
        end
      }.map{ |e| 
      if e
        e.private_workspace.artworks 
      end
      }.flatten - @selected_artworks
		elsif CompetitionsUser.exists?(:user_id => @current_user.id, :competition_id => @current_object.id)
			
			@selected_artworks = @current_object.new_record? ? [] : @current_object.artworks & @current_user.private_workspace.artworks
			# TODO hack for rights ...
			@remaining_artworks = @current_user.private_workspace.artworks - @selected_artworks
		end
		
	end

def group_selection
  @filter_selection=ArtworksCompetition.find(:all)
  puts "$$$$$$$$$$$$$$$$4"
  puts @filter_selection.inspect
end

end
