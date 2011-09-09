class NewsletterJob

  def perform
    Rails.logger.info "Sending Newsletters at #{Time.now}"
    command=<<-end_command
      ruby script/runner QueuedMail.send_emails
    end_command
    command.gsub!(/\s+/, " ")
    if system(command)
      Delayed::Worker.logger.info "#{Time.now} : Newsletter sending success#{ $?.exitstatus == 0 ? '' : ', but exit status equal to '+exitstatus.to_s }"
    else
      Delayed::Worker.logger.info "#{Time.now} : Newsletter sending failed"
    end
  end
	
end

