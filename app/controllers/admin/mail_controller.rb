require 'rubygems'
require 'net/imap'
require 'tmail'
class Admin::MailController < ApplicationController
  layout "gallery_promoting_mail"
  auto_complete_for :user, :email
  #before_filter :check_the_email ,:only=>"index"
  
  def check_the_email
     begin
      imap = Net::IMAP.new('imap.gmail.com', 993, true)
      imap.login("kedar.pathak@pragtech.co.in", "kedar123")
      imap.select('Inbox')
      imap.uid_search(["NOT", "SEEN"]).each do |uid|
        mail =  TMail::Mail.parse(imap.uid_fetch(uid, ['RFC822']).first.attr['RFC822'])
        if user = User.find_by_email(mail.from.to_s)
            message = user.sent_messages.new
            message.subject = mail.subject.to_s
            message.prepare_copies("contact@test.com")
            if mail.reply_to.blank? 
              message.body = mail.body.to_s.split("\r\n\r\n")[1]
            else
              message.body = mail.body.to_s.split("\r\n\r\n")[0]
            end
            if !mail.in_reply_to.blank?
              message.body = mail.body.to_s.split("\r\n\r\n")[0]
            end
            message.save
          else
           tempraryinbox = Tempraryinbox.new
           tempraryinbox.fromemail =  mail.from.to_s
           tempraryinbox.subject = mail.subject.to_s
           tempraryinbox.body = mail.body.to_s.split("\r\n\r\n")[1]
           tempraryinbox.save
        end  
      end
    imap.expunge        
  rescue
  end
  end  
  

  

  
  
 def index
    redirect_to new_session_path and return unless logged_in?
    @folder = current_user.inbox
    @created_label = Emaillabel.find(:all)
    
    show
   # render :action => "show"
   if request.xhr?
        render :update do |page|
        page["table_structer_of_email"].replace_html(:partial =>'inbox_messages', :object =>@messages)
        page["show_details"].replace_html ""
        page["ajax_spinner"].visual_effect :hide
        page["selectlabel"].visual_effect :show
      end
   end    
  end

  
  
  def show
    @folder ||= current_user.mailfolders.find(params[:id])
    @messages = @folder.messages.paginate_not_deleted_and_not_labeled :all, :per_page => 10, :page => params[:page],:include => :message, :order => "messages.created_at DESC"
  end
  


  def flag_email
    @message = current_user.received_messages.find(params[:id])
    if @message.flag == true
    @message.update_attribute("flag", false)
    else  
    @message.update_attribute("flag", true)
    end   
    render :nothing=>true
  end    
  
  
  def sent_flag_email
    @message = Message.find(params[:id])
    if @message.flag == true
    @message.update_attribute("flag", false)
    else  
    @message.update_attribute("flag", true)
    end   
    render :nothing=>true
  end  
  

  
  
  
  def show_flag_email
    @folder = Struct.new(:name, :user_id).new("Trash", current_user.id)
    @messages = current_user.received_messages.paginate_flag :all, :per_page => 100, :page => params[:page],
          :include => :message, :order => "messages.created_at DESC",:conditions=>["deleted = ? or deleted is null",false]
    @sent_message_flag = Message.find(:all,:conditions=>["flag = ? and deletedm IS NULL OR deletedm = ?",true,false])      
    render :update do |page|
        page["table_structer_of_email"].replace_html(:partial =>'show_flag_email', :object =>@messages,:locals=>{:sent_message=>@sent_message_flag})
        page["show_details"].replace_html ""
        page["ajax_spinner"].visual_effect :hide
    end      
  end  
  
  



  def show_message
      @message = current_user.received_messages.find(params[:id])
      render :update do |page|
        page["show_details"].replace_html(:partial =>'message_detail', :object =>@message)
        page["ajax_spinner"].visual_effect :hide
    end
  end  
  
  
  def show_unknown_message
      @message = Tempraryinbox.find(params[:id])
      render :update do |page|
        page["show_details"].replace_html(:partial =>'unknown_message_detail', :object =>@message)
        page["ajax_spinner"].visual_effect :hide
    end
  end  
  
  
  
  def unknown_email
    @unknown_message = Tempraryinbox.paginate  :page => params[:page], :order => 'updated_at DESC',:per_page => 10
      if request.xhr?
        render :update do |page|
        page["table_structer_of_email"].replace_html(:partial =>'temprary_messages', :object=>@unknown_message)
        page["selectlabel"].visual_effect :hide
        page["show_details"].replace_html ""
        page["ajax_spinner"].visual_effect :hide
      end
   end    
  end  
  
  def delete_temprary_email
     params.to_hash.each do |key,value|
       if key.include? "delete_message"
         @unknown_message = Tempraryinbox.find(value)
         @unknown_message.destroy
       end
     end
      @unknown_message = Tempraryinbox.paginate  :page => params[:page], :order => 'updated_at DESC',:per_page => 10
           if request.xhr?
        render :update do |page|
        page["table_structer_of_email"].replace_html(:partial =>'temprary_messages', :object=>@unknown_message)
        page["selectlabel"].visual_effect :hide
        page["show_details"].replace_html ""
        page["ajax_spinner"].visual_effect :hide
      end
    else
      redirect_to :action=>"trash_mail"
   end 
  end  
  
  
  
  
  def replay_message_to_unknown
      @message = Tempraryinbox.find(params[:id])
      render :update do |page|
        page["replay_to_all"].replace_html(:partial =>'replay_unknown_message', :object =>@message,:locals=>{:frommail=>@frommail,:replaymessageid=>@original})
        page["ajax_spinner"].visual_effect :hide
        page["selectlabel"].visual_effect :hide
    end
  end  
  
  
  
  
  
  def trash_mail
    @created_label = Emaillabel.find(:all)
    @folder = Struct.new(:name, :user_id).new("Trash", current_user.id)
    @messages = current_user.received_messages.paginate_deleted :all, :per_page => 10, :page => params[:page],
          :include => :message, :order => "messages.created_at DESC"
    @messages_sent_delete = Message.find(:all,:conditions => ["(author_id = ?) and (deletedm IS NOT NULL OR deletedm = ? ) and (deletedmt IS NULL OR deletedmt = ?)",current_user.id, true,false],:order => "created_at DESC",:limit=>2)      
  @messages << @messages_sent_delete
    if request.xhr?
      render :update do |page|
          page["table_structer_of_email"].replace_html(:partial =>'trash_mail_detail', :object =>@messages,:locals=>{:messages_sent_delete => @messages_sent_delete})
          page["show_details"].replace_html ""
          page["ajax_spinner"].visual_effect :hide
          page["selectlabel"].visual_effect :hide
      end   
   end    
  end

  
  def delete_from_trash
     params.to_hash.each do |key,value|
       if key.include? "delete_message_recd"
          @message = current_user.received_messages.find(value)
          @message.destroy
       end
     end
     params.to_hash.each do |key,value|
       if key.include? "delete_message_mail"
          @message = Message.find(value) 
          @message.update_attribute("deletedmt", true)
       end
     end
         @folder = Struct.new(:name, :user_id).new("Trash", current_user.id)
    @messages = current_user.received_messages.paginate_deleted :all, :per_page => 10, :page => params[:page],
          :include => :message, :order => "messages.created_at DESC"

@messages_sent_delete = Message.find(:all,:conditions => ["(author_id = ?) and (deletedm IS NOT NULL OR deletedm = ? ) and (deletedmt IS NULL OR deletedmt = ?)",current_user.id, true,false],:order => "created_at DESC",:limit=>2)      

  @messages << @messages_sent_delete
    if request.xhr?
      render :update do |page|
        page["table_structer_of_email"].replace_html(:partial =>'trash_mail_detail', :object =>@messages,:locals=>{:messages_sent_delete => @messages_sent_delete})
        page["show_details"].replace_html ""
        page["ajax_spinner"].visual_effect :hide
        page["selectlabel"].visual_effect :hide
    end   
    else   
        redirect_to :action=>"trash_mail"
    end  
    
  
    
    
  end  
  
  
  def compose_new_mail
     @message = current_user.sent_messages.build
     @frommail = Frommail.find(:all)
     if request.xhr?
        render :update do |page|
          page["show_details"].replace_html (:partial =>'compose_message', :object =>@message,:locals=>{:frommail=>@frommail})
          page["ajax_spinner"].visual_effect :hide
          page["selectlabel"].visual_effect :hide
      end
   end  
  end  
 
 
  def find_signature_label
      signature = Signature.find(:all,:conditions=>["frommail_id = ?",params[:fromemail]])  
     render :update do |page|
        page["update_label"].replace_html(:partial =>'find_signature_label', :object =>signature)
      end
  end  
 
  def find_signature
     signature = Signature.find(params[:fromemail])  
     render :update do |page|
        #page["show_the_signature"].replace_html(:partial =>'show_the_signature', :object =>signature)
        page.call("set_the_signature",signature.signature)
      end
  end   
 
 
 
 
  def sent_mail
      @created_label = Emaillabel.find(:all)
      @folder = current_user.inbox
      @messages = current_user.sent_messages.paginate :conditions=>["deletedm = ? or deletedm is null",false], :per_page => 10, :page => params[:page], :order => "created_at DESC"
    if request.xhr?  
        render :update do |page|
          page["table_structer_of_email"].replace_html(:partial =>'sent_mail_detail', :object =>@messages)
          page["show_details"].replace_html ""
          page["ajax_spinner"].visual_effect :hide
          page["selectlabel"].visual_effect :hide
      end
    end   
  end
  
  
    def delete_sent_mail

    params.to_hash.each do |key,value|
       if key.include? "delete_message"
          @message = Message.find(value)
          @message.update_attribute("deletedm", true)
       end
     end
      @folder = current_user.inbox
      @messages = current_user.sent_messages.paginate :conditions=>["deletedm = ? or deletedm is null",false], :per_page => 10, :page => params[:page], :order => "created_at DESC"

     if request.xhr?
         render :update do |page|
          page["table_structer_of_email"].replace_html(:partial =>'sent_mail_detail', :object =>@messages)
          page["show_details"].replace_html ""
          page["ajax_spinner"].visual_effect :hide
          page["selectlabel"].visual_effect :hide
       end 
     else  
     redirect_to :action=>"sent_mail"
     end
     
  end 
  
  
  
  
  
  
  
  
  
  def delete_all_email
     params.to_hash.each do |key,value|
       if key.include? "delete_message"
          @message = current_user.received_messages.find(value)
          @message.update_attribute("deleted", true)
       end
     end
      @folder = current_user.inbox
          @messages = @folder.messages.paginate_not_deleted_and_not_labeled :all, :per_page => 10, :page => params[:page],:include => :message, :order => "messages.created_at DESC"
    if request.xhr?  
        render :update do |page|
          page["table_structer_of_email"].replace_html(:partial =>'inbox_messages', :object =>@messages)
          page["show_details"].replace_html ""
          page["ajax_spinner"].visual_effect :hide
          page["selectlabel"].visual_effect :hide
      end
   
    else   
        redirect_to "/admin/mail"
    end  
  
    
  end  
 
 
 
 
 
 
  def show_sent_message
       @message = current_user.sent_messages.find(params[:id])
       render :update do |page|
        page["show_details"].replace_html(:partial =>'message_sent_detail', :object =>@message)
        page["ajax_spinner"].visual_effect :hide
      end
  end  
 
  def show_labeled_email
      @message=current_user.received_messages.paginate :conditions=>["emaillabel_id = ?",params[:id]], :per_page => 10, :page => params[:page], :order => "created_at DESC"
      emaillabel =  Emaillabel.find(params[:id])     
       if request.xhr?
        render :update do |page|
        page["table_structer_of_email"].replace_html(:partial =>'show_labeled_email', :object =>@message,:locals=>{:labelname=>emaillabel})
        page["show_details"].replace_html ""
        page["ajax_spinner"].visual_effect :hide
        page["selectlabel"].visual_effect :hide
       end
   end    
  end   
  

  
 
  
  def create_sent_mail
    if params[:id]
      @original = current_user.received_messages.find(params[:id]) 
    end
    @message = current_user.sent_messages.build(params[:message])
    @message.prepare_copies(params[:user][:email])
    if params[:id]
    @message.body = "<br/>" + @message.body + ">><br/><font color='#FF0080'>" + params[:signature].to_s+"</font>" + "<br/>"+@original.body 
    else
       @message.body =  @message.body + "<br/><font color='#FF0080'>" + params[:signature].to_s+"</font>"
    end  
    all_the_recipient = params[:user][:email].split(',')
   
    EmailSystem::deliver_email_notification(all_the_recipient,@message.subject,@message.body)
    if @message.save
      flash[:notice] = "Message sent."
      redirect_to :action => "index"
    else
      render :action => "new"
    end
  end
  
  
  
  def create_sent_mail_with_original_id
    @original = current_user.received_messages.find(params[:id]) 
    @message = current_user.sent_messages.build(params[:message])
    @message.prepare_copies(params[:user][:email])
    @message.body = @message.body + ">><br/>" + @original.body
    if @message.save
      all_the_recipient = params[:user][:email].split(',')
      EmailSystem::deliver_email_notification(all_the_recipient,@message.subject,@message.body)
      flash[:notice] = "Message sent."
      redirect_to :action => "index"
    else
      render :action => "new"
    end
  end  

  
  
  
 
  def replay_to_all
    @frommail = Frommail.find(:all) 
    @original = current_user.received_messages.find(params[:id])
    subject = @original.subject.sub(/^(Re: )?/, "Re: ")
    body = @original.body.gsub(/^/, "> ")
    recipients = @original.recipients.map(&:id) - [current_user.id] + [@original.author.id] 
    recipients_email = @original.recipients.map(&:email) - [current_user.email] + [@original.author.email] 
    @message = current_user.sent_messages.build(:to => recipients, :subject => subject, :body => body)
    render :update do |page|
        page["replay_to_all"].replace_html(:partial =>'replay_all_message', :object =>@original,:locals=>{:frommail=>@frommail,:recipients_email=>recipients_email})
        page["ajax_spinner"].visual_effect :hide
        page["selectlabel"].visual_effect :hide
    end
  end  
  
  def replay_message
    
    @original = current_user.received_messages.find(params[:id])
    #@frommail = Frommail.find(:all)
    subject = @original.subject.sub(/^(Re: )?/, "Re: ")
    body = @original.body#.gsub(/^/, "> ")
    @message = current_user.sent_messages.build(:to => [@original.author.id], :subject => subject, :body => body)
    render :update do |page|
        page["replay_to_all"].replace_html(:partial =>'replay_message', :object =>@message,:locals=>{:frommail=>@frommail,:replaymessageid=>@original})
      
        page["ajax_spinner"].visual_effect :hide
        page["selectlabel"].visual_effect :hide
    end
    
  end  
  
  def create_sent_mail_with_unknown
      message =  Tempraryinbox.find(params[:id])
      EmailSystem::deliver_email_notification(params[:user][:email],params[:message][:subject],params[:message][:body] + message.body)
      flash[:notice]  = "Your Reply Has Been Sent"
      redirect_to :back
  end  
  
  
  def delete_email
    @message = current_user.received_messages.find(params[:id])
    @message.update_attribute("deleted", true)
    redirect_to "/admin/mail"
  end  
  
 
  
  def delete_sent_mail

    params.to_hash.each do |key,value|
       if key.include? "delete_message"
          @message = Message.find(value)
          @message.update_attribute("deletedm", true)
       end
     end
     @messages = current_user.sent_messages.paginate :conditions=>["deletedm = ? or deletedm is null",false], :per_page => 10, :page => params[:page], :order => "created_at DESC"
     if request.xhr?
        render :update do |page|
          page["table_structer_of_email"].replace_html(:partial =>'sent_mail_detail', :object =>@messages)
          page["show_details"].replace_html ""
          page["ajax_spinner"].visual_effect :hide
          page["selectlabel"].visual_effect :hide
      end

     else  
     redirect_to :action=>"sent_mail"
     end
     
  end  
  
  
  #delete_message_mail will be fetch directly from message table and delete_message_sent will be the received email so they are deleted from message copies
  def delete_show_flag_mail
    params.to_hash.each do |key,value|
       if key.include? "delete_message_mail"
          @message = Message.find(value)
          @message.update_attribute("deletedm", true)
       end
     end
    params.to_hash.each do |key,value|
       if key.include? "delete_message_sent"
          @message = current_user.received_messages.find(value)
          @message.update_attribute("deleted", true)
                  
       end
     end
     
  end  
  
  def create_label
      Emaillabel.create(:labelname=>params[:createlabel])
      flash[:notice] = "Label Is Created"
      redirect_to "/admin/mail"
  end  
  
  def forward_email
    @original = current_user.received_messages.find(params[:id])
    subject = @original.subject.sub(/^(Fwd: )?/, "Fwd: ")
    body = @original.body.gsub(/^/, "> ")
    @message = current_user.sent_messages.build(:subject => subject, :body => body)
     render :update do |page|
        page["replay_to_all"].replace_html(:partial =>'replay_message', :object =>@message,:locals=>{:frommail=>@frommail,:replaymessageid=>@original})
        page["ajax_spinner"].visual_effect :hide
    end
  end  
   
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 def delete_label
   emaillabel = Emaillabel.find(params[:id])
   
   messages = MessageCopy.find(:all,:conditions=>["emaillabel_id = ? ",emaillabel.id])
   for msg in messages
     msg.update_attribute("emaillabel_id", nil)
     msg.update_attribute("labeled", nil)
   end
   emaillabel.destroy 
   ############this is im copying now but need to check what need to delete from this code
   @folder = current_user.inbox
   @created_label = Emaillabel.find(:all)
    show
   # render :action => "show"
   if request.xhr?
        render :update do |page|
        page.redirect_to "/admin/mail"
        
      end
   end    
 end  
 
 
 def moveto
   if params[:selected_label] == "select"
     flash[:notice] = "Please Select The Label To Move To"     
   else  
    emaillabel = Emaillabel.find_by_labelname(params[:selected_label])
     params.to_hash.each do |key,value|
       if key.include? "delete_message"
          @message = current_user.received_messages.find(value)
          @message.update_attribute("emaillabel_id", emaillabel.id)
          @message.update_attribute("labeled", true)
       end
     end
    flash[:notice] = "Email Moved Successfully To #{emaillabel.labelname}"     
   end  
     
    redirect_to "/admin/mail"
 end  
 
 
  def create_temporary_inbox
    #a=User.find(:all)
    #a.each do |x|
    #  m=Mailfolder.new(:user_id=>x.id,:name=>"inbox")
    #  m.save
   # end
#   if user = User.find_by_email('kedar.pathak@pragtech.co.ing')
#       p "yes im in ifififi"  
#       p user
#   else  
#       p "no i did not find the user"
#       p user
#       p "it is nil"
#   end
   
  end   
 
  
 
 
end

