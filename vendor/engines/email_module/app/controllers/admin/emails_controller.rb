class Admin::EmailsController < Admin::ApplicationController
   uses_tiny_mce :options => {
                               :theme => "advanced",
										:theme_advanced_buttons3_add_before => "tablecontrols,separator",
                              :theme_advanced_resizing => true,
                               :theme_advanced_styles => "Normal",
                              :plugins => %w{ table fullscreen },
                              :height=>'100px;',
                              :width=>'100px'
                            }    

	def list_all_messages
		profile = Profile.find(params[:profile_id])
		emails = EmailSystem.all_in_one(profile.email_address)
		if emails.is_a?(Array)
			render :text => emails.each{ |msg|
				@template.blank_list_element(:date => msg[:date], :title => "From : #{msg[:from]} To : #{msg[:to]}<br />Subject : #{msg[:subject]}") {
					@template.link_to_remote 'Open the message', :url => @template.display_full_message_admin_emails_path(:uid => msg[:uid]), :update => 'modal_space', :method => :get
				}
			}.join('')
		else
			render :text => "Error with IMAP .... #{emails.to_s}"
		end
	end

	def display_full_message
		em = EmailSystem.new
		em.connecting
		em.connection.examine('INBOX')
		#em.retrieving_email_ids_matching_with(email_address)

		msg = em.extracting_data_from_uid(params[:uid].to_i)
		p "============================#{msg.inspect}"
		render :partial => 'display_full_message', :locals => { :object => msg }
	end

    #from here the compose email page will be shown
	def compose_mail
	render :layout=>"gallery"
	end	
	
	def compose_email
			   tomail = params[:email][:tomail].split(",")
	   		QueuedMail.create(:mailer => 'UserMailer', :mailer_method => 'friend_email', :args => [tomail,params[:email][:subject],params[:email][:body]], :priority => 0,:tomail=>params[:email][:tomail],:frommail=>current_user.profile.email_address)
        				email= UserMailer.create_friend_email(tomail,params[:email][:subject],current_user.profile.email_address,params[:email][:body])
				UserMailer.deliver(email)
      		flash[:notice]="Email Has Been Sent"
      		redirect_to "/admin/emails/inbox"
	end
 
   def undelete_if_required(qml)
   	 while qml
   	 	qm  =  QueuedMail.find(:last, :conditions=>["id = ?",qml.replayto])
         qmc = qm.replayto
          #this means the top most email if another party has ben deleted
       	if qmc == nil
       	 # this if else is required because starting of email  might be started from another party or it may
       	 #be sent mail and replied 
       		if qm.tomail == current_user.profile.email_address
                 qm.deletefrom = nil
              else
                 qm.deleteto = nil
              end     	     
              qm.save
     			end         
			
         qmca =  QueuedMail.find(:all, :conditions=>["replayto = ?",qmc])
         qml = qmca[0] 
		   #this loop is for there may be any number of parents . e.g. there may be any number of replay for a mail
         #which might be deleted by another party.for a particular communicvation 
          for qmcam in qmca        	 	
   		 	if qmcam.tomail == current_user.profile.email_address
					qmcam.deletefrom = nil   	 	 
				else
			  		qmcam.deleteto = nil 	
   	 		end
   	 		qmcam.save
   	 	 end
   	 
   	 end 
   end
   
    def delete_email
      deletedornot=false          	
    	if !params[:deletemail].blank?
   		 params[:deletemail].each do |eid,dv|
   	 	 	if dv.to_i==1
   	         deletedornot=true	 	    
   		 		delete_all(eid.to_i)
   		 	end
   		 end
       end
        if  deletedornot
         flash[:notice] = "Email Is Deleted"
   		redirect_to :back
        else 	
   		flash[:notice] = "No Email Is Selected"
   		redirect_to :back
   	  end 	 
	end
   
   
	def delete_all(deleteid)
		quied_email = QueuedMail.find(deleteid)
   	if quied_email.tomail == current_user.profile.email_address
                 quied_email.deleteto = true
    else
                 quied_email.deletefrom = true
    end     	     
      quied_email.save
   	qpm = quied_email
   	deleteme=true
   	while deleteme
   	     qcm = QueuedMail.find(:first,:conditions=>["replayto = #{qpm.id}"])
   	     if !qcm.blank?
              if qcm.tomail == current_user.profile.email_address
                 qcm.deleteto = true
              else
                 qcm.deletefrom = true
              end     	     
              qcm.save
              qpm = qcm
   	     else
   	        deleteme = false
   	     end 
   	end


	end   
   
   def sent_email
     @quied_email = QueuedMail.find(:all,:conditions=>["frommail = ? ",current_user.profile.email_address])
   end
   
   def inbox
      @quied_email = []
      #got email from others
      @quied_email = QueuedMail.find(:all,:conditions=>["tomail = ? and replayto is null and deleteto is null",current_user.profile.email_address])
	   @read = {}
	  #email sent but replied therefore they should get included in inbox here the sent mail will come first and then its details
		quid_email =  QueuedMail.find(:all,:conditions=>["tomail = ? and replayto is not null and deleteto is null",current_user.profile.email_address])       
    	quid_email.each do |qm|
	     qmc=qm
        while qmc
          #this loop is for just take the parent record  of the children record that means the child records are like the records
          #which are actually sent email but replied they are child and the parent is different which will come in inbox
          #this will work on first time and the next replied will be on click of ubject in view 		                
           if qmc.replayto == nil
            	if qmc.tomail == current_user.profile.email_address and qmc.deleteto != true
					   @quied_email << qmc
					elsif  qmc.tomail != current_user.profile.email_address and qmc.deletefrom != true
					   @quied_email << qmc  
           		end
			  end
	       pqm = QueuedMail.find(:first,:conditions=>[" id = ? ",qmc.replayto])
           qmc=pqm
			          	  
        	  if pqm.blank?
        			qmc = nil
        	  end
       end
    	end
 	   @replay=[]
      @quied_email.each do |quiedemail|
      	rm=QueuedMail.find(:first,:conditions=>["replayto = ?",quiedemail.id])
      	if !rm.blank?
      		@replay<<rm.replayto
      	end
      end
		#the above loop will be reapeated here because i want to know weather the email is read or not
		@replay.uniq!
      @quied_email.uniq!		
		@quied_email.each do |quiedemail|
	      pqm =  quiedemail 		   
		   pqma = quiedemail
         while !pqma.blank?  		   
	           if  pqma.instance_of? Array              
               for  pqm in pqma        		
         			if pqm and pqm.toread == nil and pqm.tomail == current_user.profile.email_address
         	 				@read.merge! "#{quiedemail.id}"=>pqm.toread
		   			end
		   		end
               else
						if pqm and pqm.toread == nil and pqm.tomail == current_user.profile.email_address
         	 				@read.merge! "#{quiedemail.id}"=>pqm.toread
		   			end
   			  end	
					pqma = QueuedMail.find(:all,:conditions=>["replayto = ?",pqm.id])
			end
		end	
      #this read hash is for knowing that if the mail has replay and it is not read
      #also im adding the children value but it might happen that its parent is deleted.therefore in view. im checking that
      #the @quied_email id has related key in the @read hash so that color will be change
   end 
   
   def detail_email
   	 @detail_email = QueuedMail.find(params[:id])
       if  @detail_email.tomail == current_user.profile.email_address  	 
   	 	  @detail_email.toread = true
   	 #else
   	 #    @detail_email.fromread = true
   	 end
   	 @detail_email.save
   	 @replay_email=[]
   	 @replay=[]
   	 dm=@detail_email
   	 findparent = true
   	 while findparent
   	 		  rm = QueuedMail.find(:all,:conditions=>["replayto = ? and tomail = ? and deleteto is null",dm.id,current_user.profile.email_address])
              if rm.blank?
   	 		  rm = QueuedMail.find(:all,:conditions=>["replayto = ? and tomail != ? and deletefrom is null",dm.id,current_user.profile.email_address])
              else
              rm << QueuedMail.find(:all,:conditions=>["replayto = ? and tomail != ? and deletefrom is null",dm.id,current_user.profile.email_address]) 
              end   	 		  
   	 		  rm.flatten!
   	 		  dm=rm
   	 		  if !rm.blank?
   	 		     rmd=[] 
	   	 		  @replay_email << rm
	   	 		  rm.each do |xm|
	   	 		    rmd << QueuedMail.find(:first,:conditions=>["replayto = ?",xm.id]) 
	   	 		  end
	   	 	     if !rmd.blank?
      					rmd.each do |x| @replay<<x end
      			  end
       		  else
   		 		 	findparent=false 
   	 		  end
   	 end
   end    
   
   def reply_email
   		   tomail = params[:email][:tomail].split(",")
	   		QueuedMail.create(:mailer => 'UserMailer', :mailer_method => 'friend_email', :args => [tomail,params[:email][:subject],params[:email][:body]], :priority => 0,:tomail=>params[:email][:tomail],:frommail=>current_user.profile.email_address,:replayto=>params[:id])
				#after creating an email i want to check that if it is deleted from another party then i wanted to undelete it
            undelete_if_required(QueuedMail.find(:last,:conditions=>["frommail = ?",current_user.profile.email_address]))       				
				email= UserMailer.create_friend_email(tomail,params[:email][:subject],current_user.profile.email_address,params[:email][:body])
				UserMailer.deliver(email)
      		flash[:notice]="Replay Has Been Sent"
      		redirect_to "/admin/emails/inbox"
   end
    
end
