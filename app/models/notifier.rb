class Notifier < ActionMailer::Base

def subscription_detail_mail(fromaddress,toaddress,message,toname,competition_name,last_date)
	 from  "mark@bsgart.com.au"
	 recipients       toaddress
	 subject    'Confirmation Of Your Competition Of Artwork'
	 attachments['free_book.pdf'] = File.read('path/to/file.pdf')

	@message = message
	@toname = toname
	@competitionname = competition_name
	@last_date = last_date
end

def studio_enquiry_made(fromwhomename,fromwhomeemailaddress)	  
     from  "mark@bsgart.com.au"
	 recipients "studios@bsgart.com.au"
	 subject    'Studio Enquiry Made'
	@fromwhomename = fromwhomename
	@fromwhomeemailaddress = fromwhomeemailaddress
end

def website_role_change(towhomemail,towhomename,rolename,exhibitionname)
     from  "mark@bsgart.com.au"
	 recipients towhomemail
	 subject    'Request To Submit Exhibition Artwork'
    @towhomemail = towhomemail
    @towhomename = towhomename
    @rolename = rolename
    @exhibitionname = exhibitionname
end

def send_invoice(invoice, user)

     setup_email(user)	 
     subject "#{invoice.title}"
     body :site => "http://173.230.149.35"
    attachment "application/pdf" do |a|
      a.body = File.read("#{RAILS_ROOT}/public/pdf_invoice/#{invoice.id}invoice.pdf")
      a.filename = "invoice.pdf"
    end

	
end


  def setup_email(user)
      recipients user.email
      from "test@pragtech.co.in"
      sent_on Time.now
    end
end
