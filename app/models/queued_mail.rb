# == Schema Information
# Schema version: 20181126085723
#
# Table name: queued_mails
#
#  id            :integer(4)      not null, primary key
#  mailer        :string(255)
#  mailer_method :string(255)
#  args          :text
#  priority      :integer(4)      default(0)
#  created_at    :datetime
#

# require 'user_mailer'

class QueuedMail < ActiveRecord::Base
	
  serialize :args

  # Method to send emailw with descending priority
	#
	# It will find all mails by priority and deliver mails.
	# After sending the mails will be destroyed.
  # 
  # Usage :
  # QueuedMail.send_email
  def self.send_emails
    self.find(:all, :order=> "priority desc, id desc", :limit => 20).each do |mail|
      mail.send_email
    end
		return true
  end

  # Method to add a email to the queue
	#
	# It will add the mails to queue to call send_newsletter with priority 0.
	#
	# Parameters:
  # - mailer: UserMailer
  # - method: 'send_newsletter'
  # - args: 'newsletter object arguments like email,member,from_email,subject,description,body
  # - priority: 0
	# - send_now: Boolean allowing to send synchronly
	#
  # Usage :
  # QueuedMail.add("UserMailer","send_newsletter", args, 0)
  def self.add(mailer, method, args, priority, send_now=false,tomail=nil,frommail=nil)
    tmp = QueuedMail.create(:mailer => mailer.to_s, :mailer_method => method.to_s, :args => args, :priority => priority,:tomail=>tomail,:frommail=>frommail)
		if send_now
			tmp.send_email
		end
		return tmp
  end

	def send_email
  	mailer_class = self.mailer.constantize
    mailer_method = ("deliver_" + self.mailer_method).to_sym
		#raise self.args.inspect
    if mailer_class.send(mailer_method, *self.args)
			#self.destroy
		logger.info "i have sent the email"	
    else
      logger.info "the email is not get sent the method returns false"
		end
	rescue Exception => exc
    logger.info "this is exception for email sending"
    logger.info exc
    logger.info "this is exception for email sending"
  		self.sending_tries = self.sending_tries + 1
		
		if self.sending_tries > 5 || self.created_at > Time.now + 3.hours
			self.destroy
		
		else
			# TODO rails bugs ??!!?? why serialize attribute causing problem ?
			#self.save
		end
#		logger.error("Message for the log file #{exc.message}")
	end

end  
