class MailingListsController < ApplicationController
  	layout "gallery_promoting_mail" 
  # GET /mailing_lists
  # GET /mailing_lists.xml
  def index
    @mailing_lists = MailingList.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @mailing_lists }
    end
  end

  # GET /mailing_lists/1
  # GET /mailing_lists/1.xml
  def show
    @mailing_list = MailingList.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @mailing_list }
    end
  end

  # GET /mailing_lists/new
  # GET /mailing_lists/new.xml
  def new
    @mailing_list = MailingList.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @mailing_list }
    end
  end

  # GET /mailing_lists/1/edit
  def edit
    @mailing_list = MailingList.find(params[:id])
  end

  # POST /mailing_lists
  # POST /mailing_lists.xml
  def create
    @mailing_list = MailingList.new(params[:mailing_list])

    respond_to do |format|
      if @mailing_list.save
        format.html { redirect_to(@mailing_list, :notice => 'MailingList was successfully created.') }
        format.xml  { render :xml => @mailing_list, :status => :created, :location => @mailing_list }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @mailing_list.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /mailing_lists/1
  # PUT /mailing_lists/1.xml
  def update
    @mailing_list = MailingList.find(params[:id])

    respond_to do |format|
      if @mailing_list.update_attributes(params[:mailing_list])
        format.html { redirect_to(@mailing_list, :notice => 'MailingList was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @mailing_list.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /mailing_lists/1
  # DELETE /mailing_lists/1.xml
  def destroy
    @mailing_list = MailingList.find(params[:id])
    @mailing_list.destroy

    respond_to do |format|
      format.html { redirect_to(mailing_lists_url) }
      format.xml  { head :ok }
    end
  end
  
  def show_studio_mail
    
     @allstudiouser = StudioAndMailingList.find(:all,:conditions=>"studio = true")
     @emailsendarray = []
     @usernames = []
     @allstudiouser.each do |su|
       @emailsendarray << su.email_address
       @usernames <<  su.first_name + " " + su.last_name  
     end
     
     @frommail = Frommail.find(:all)
  end
  
  #currently the studio email and mailing list email are not shown under sent email the technical reason is they are not 
  #users from the database
  def send_studio_email
    @message = params[:message]
    @messagebody =  params[:message][:body] + "<br/><font color='#FF0080'>" + params[:signature].to_s+"</font>"
    all_the_recipient = params[:message][:email].split(',')
    someusersfailed = true
    all_the_recipient.each do |rec|
        begin
          EmailSystem::deliver_email_notification(rec,params[:message][:subject],@messagebody)
        rescue => exc
          p "this is exception i got"
          p exc
          someusersfailed = false
        end
    end
    if someusersfailed
      flash[:notice] = "Please Try Again"
      redirect_to "/admin/show_studio_mail"
    else
      flash[:notice] = "Message sent."
      redirect_to :back 
    end
  end
  
  def show_mailing_mail
     @allstudiouser = StudioAndMailingList.find(:all,:conditions=>"mailing_list = true")
     @emailsendarray = []
     @usernames = []
     @allstudiouser.each do |su|
       @emailsendarray << su.email_address
       @usernames <<  su.first_name + " " + su.last_name  
     end
     
     @frommail = Frommail.find(:all)
  end
  
  
  def send_mailing_email
    @message = params[:message]
    @messagebody =  params[:message][:body] + "<br/><font color='#FF0080'>" + params[:signature].to_s+"</font>"
    all_the_recipient = params[:message][:email].split(',')
    someusersfailed = true
    
    all_the_recipient.each do |rec|
    begin
      EmailSystem::deliver_email_notification(rec,params[:message][:subject],@messagebody)
    rescue => exc
    
      logger.info exc
      someusersfailed = false
    end
    end
    
   if someusersfailed 
    flash[:notice] = "Message sent."
    redirect_to :back
   else
    flash[:notice] = "Some Email Is Not Get Sent"
    redirect_to :back
   end
      
  end
  
end
