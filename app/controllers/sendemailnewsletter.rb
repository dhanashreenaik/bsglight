require 'rubygems'
require 'nokogiri'
class Sendemailnewsletter   < ActiveRecord::Base
    nlm = Newsletteremail.find(:all,:conditions=>["emailsend is null"],:limit=>1)
       for nl in nlm
         nlc=nl.newsletter.news_letter_content
          doc = Nokogiri::HTML(nlc)
          doc.xpath('//img').each do |node|
            cip= node.get_attribute('src')
            node.set_attribute('src',"http://localhost:3000"+cip)
          end
          email= UserMailer.create_send_emailnewsletter(nl.newsletter.title,doc.to_html,nl.user)
          UserMailer.deliver(email)
         nl.emailsend = true
         nl.save
       end
end 
