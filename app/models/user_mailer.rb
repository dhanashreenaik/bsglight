
class UserMailer < ActionMailer::Base

	# Library included to get the application configuration methods
	include BlankConfiguration

	require 'open-uri'

  # Return the current set sa_application_url in Superadministration
	def daurl
		return get_configuration['sa_application_url']
   end

	# Return the current set sa_application_name in Superadministration
	def site_name
		return get_configuration['sa_application_name']
	end

  # Return the current set sa_application_email in Superadministration
	def contact_email
		return get_configuration['sa_contact_email']
	end

  # Send Notification Mail to User after Sign-Up is Completed
	def signup_notification(user)
		setup_email(user)
		   subject self.site_name+" : "+I18n.t('mailer.signup_notification.subject')
		   body :url => self.daurl+"/admin/activate/#{user.activation_code}",
			:site => self.site_name,
			:user_login => user.login,
			:user_password => user.password
  end
  
  def admin_register_user(user)
      setup_email(user)
      subject "Notification Of Registration To Bsgart.com"
      body :password => user.password,:email=>user.email
  end
  
  
    def artwork_status(artworks_competition,current_user)
              setup_email(current_user)
              subject self.site_name+" : "+ "Artwork submites Status"
              body :name=>current_user.profile.full_name,
              :status=>artworks_competition.state,
              :title => (artworks_competition.competitions_user.send artworks_competition.image_name),
              :competionname =>   artworks_competition.competition.title            
    end
     
    def send_winner_email(artworks_competition,current_user)
   			  setup_email(current_user)
              subject self.site_name+" : "+ "Winner Of Competition"
              body :name=>current_user.profile.full_name,
              :mark=>artworks_competition.mark,
              :title => (artworks_competition.competitions_user.send artworks_competition.image_name),
              :competionname =>   artworks_competition.competition.title            
    end
    def login_notification(tomail,subject,frommail,ebody,user)
	 		       setup_email(user)
					     subject self.site_name+" : Login Details"
			     		  body :url => self.daurl+"/Login",
			     		  :site => self.site_name,
			     			:user_email => user.email,
			     			:user_password => user.password	
	 end       
    

   def friend_email(toemail,subject,frommail,ebody)
      recipients toemail
      from frommail
      reply_to frommail 
      subject subject
      sent_on Time.now
      body :ebody=>ebody
      content_type "text/html"
   end


	# Send Reset Password Notification Mail to User
  def reset_notification(user)
		setup_email(user)
		subject self.site_name+" : "+I18n.t('mailer.reset_notification.subject')
		body :url => self.daurl+"/admin/reset_password/#{user.password_reset_code}",
			:user_login => user.login,
			:site => self.site_name
  end

  # Send Request for Workspace Administration to Administrator
	def ws_administrator_request(admin, user, type, msg)
		setup_email(User.find(admin))
		from User.find(user).email
		subject self.site_name+" : "+type
		body :msg => msg
  end

  # Send Newsletter to Subscribed Users
  def send_newsletter(to,sha1_id,from, newsletter_subject, description, newsletter_body)
    recipients to
    from from
		subject newsletter_subject
		body :description => description, :newsletter_body => newsletter_body, :site => self.site_name,:sha1_id => sha1_id,:url => self.daurl
    sent_on Time.now
    content_type "text/html"
  end

  # Send Newsletter to Subscribed Users
  def send_back_office_updates(to,member_type,from, newsletter_subject,audit_id ,user_id)
    audit = Audit.find(audit_id)
    object = audit.auditable_type.classify.constantize.find(audit.auditable_id) rescue nil
    recipients to
    from from
		subject newsletter_subject
		body :audit =>audit, 
		     :object => object ,
		     :user =>User.find(user_id),
		     :site => self.site_name,
		     :member_type => member_type,
		     :email => to,
		     :url => self.daurl
    sent_on Time.now
    content_type "text/html"
  end

	# Send contact form update from website	
	def contact_notification(website, email)
		recipients website.contact_email
    from email["email"]
    sent_on Time.now
		subject website.title +" : "+email["subject"]
		body :first_last => email["first_name"]+" "+email["last_name"],
			:body => email["body"],
			:phone => email["primary_phone"]
	end
    
	def send_invitation(event, user)
		setup_email(user)
		subject "Invitation to the #{event.class.to_s.downcase} '#{event.title}'"
		place=" "
		event.timing.galleries.each {|x| place << x.title + " "}
		body :timing => event.timing.period_name, :site => self.site_name,:name=>user.profile.full_name,:user_password => user.password	,:places=>place
	end

	def validate_payment(event, user)
		setup_email(user)
		subject "Confirmation of your subscription for the #{event.class.to_s.downcase} '#{event.title}'"
	end

	def send_invoice(invoice, user)
	    setup_email(user)
	    subject "invoice#{invoice.number}"
        content_type    "multipart/alternative"
        part  "text/html" do |p|
        p.body render_message("user_mailer/send_invoice.html.erb",:invoice=>invoice)
        p.transfer_encoding "base64"
       end
       attachment "application/pdf" do |a|
        a.body = File.read("#{RAILS_ROOT}/public/pdf_invoice/#{invoice.id}invoice.pdf")
        a.filename = "invoice.pdf"
        end
  end
  
  def send_invoice_groupshow(invoice, user)
	    setup_email(user)
	    subject "invoice#{invoice.number}"
        content_type    "multipart/alternative"
        part  "text/html" do |p|
        p.body render_message("user_mailer/send_invoice_groupshow.html.erb",:invoice=>invoice)
        p.transfer_encoding "base64"
       end
       attachment "application/pdf" do |a|
        a.body = File.read("#{RAILS_ROOT}/public/pdf_invoice/#{invoice.id}invoice.pdf")
        a.filename = "invoice.pdf"
        end
  end
  
  def send_invoice_forchangenote(user,invoice,esignature,ebody,esubject)
    
        setup_email(user)
        subject esubject
        content_type    "multipart/alternative"
        part  "text/html" do |p|
          p.body render_message("user_mailer/send_invoice_forchangenote.html.erb",:ebody=>ebody.to_s+esignature.to_s)
          p.transfer_encoding "base64"
        end
        attachment "application/pdf" do |a|
          a.body = File.read("#{RAILS_ROOT}/public/pdf_invoice/#{invoice.id}invoice.pdf")
          a.filename = "invoice.pdf"
        end
  end
 
	def send_invoice_exhibition(tomial,subject,body,invoice, user)
	    setup_email(user)
	    subject "invoice#{invoice.number}"
      content_type    "multipart/alternative"
        part  "text/html" do |p|
        p.body render_message("user_mailer/send_invoice_exhibition.html.erb",:invoice=>invoice)
        p.transfer_encoding "base64"
       end
       logger.info "im sending the email this is from email method"
       logger.info "#{RAILS_ROOT}/public/pdf_invoice/#{invoice.id}invoice.pdf"
       attachment "application/pdf" do |a|
        a.body = File.read("#{RAILS_ROOT}/public/pdf_invoice/#{invoice.id}invoice.pdf")
        a.filename = "invoice.pdf"
       end
  end

  def send_emailnewsletter(titlenewsletter,newsletterbody,user)
      recipients user.profile.email_address
      from "mark@bsgart.com"
      
    	subject titlenewsletter

      body :htmlbody => newsletterbody
      sent_on Time.now
      content_type "text/html"
  end
	
  
	
	
	
	def payment_confirmation(payment, user)
		setup_email(user)
		subject "Payment confirmation of the invoice #{payment.invoice.title}"
		body :site => self.site_name
	end

	def newsletter_notification(user)
		setup_email(user)
		subject "Subscription to the BSG newsletter"
		body :site => self.site_name, :first_name => user.profile.first_name
	end

	def results_notification(user, competition, place)
		setup_email(user)
		subject "You have been classified for the competition '#{competition.title}' on BSG website"
		body :site => self.site_name, :first_name => user.profile.first_name, :prizes => competition.prizes_detail,
			:place => place
	end

	def  studio_notification(fromwhomeemailaddress,fromwhomename)
		recipients "studios@bsgart.com.au"
      	from "mark@bsgart.com.au"
      	sent_on Time.now
		subject "Studio Enquiry Made  on BSG website"
		@fromwhomename = fromwhomename
		@fromwhomeemailaddress = fromwhomeemailaddress
		
	end
	
	def mailing_list_notification(fromwhomeemailaddress,fromwhomename)
	    recipients "subs@bsgart.com.au"
    	from "mark@bsgart.com.au"
      	sent_on Time.now
		subject "Mailing List Enquiry Made  on BSG website"
		@fromwhomename = fromwhomename
		@fromwhomeemailaddress = fromwhomeemailaddress
	end
  
  def website_role_change(useremail,fullname ,rolename,exhibitiontitle)
        recipients "test@pragtech.co.in"
    	from "mark@bsgart.com.au"
      	sent_on Time.now
		subject "Please Accept The Invitation For Artist"
		@fromwhomename = "BSG Admin"
                @exhibitiontitle = exhibitiontitle
  end

  protected
	# Method setting some default value for emails
    def setup_email(user)
      recipients user.email
      from self.contact_email
      sent_on Time.now
    end
		
end
