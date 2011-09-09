 require 'rubygems'
 require 'nokogiri'
class Admin::NewslettersController < ApplicationController
  # GET /admin_newsletters
  # GET /admin_newsletters.xml
  layout "gallery_promoting"
 
  def index
    @newsletters = Newsletter.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @admin_newsletters }
    end
  end

  # GET /admin_newsletters/1
  # GET /admin_newsletters/1.xml
  def show
    @newsletter = Newsletter.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @newsletter }
    end
  end

  # GET /admin_newsletters/new
  # GET /admin_newsletters/new.xml
  def new
    @newsletter = Newsletter.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @newsletter }
    end
  end

  # GET /admin_newsletters/1/edit
  def edit
    @newsletter = Newsletter.find(params[:id])
  end

  # POST /admin_newsletters
  # POST /admin_newsletters.xml
  def create
    @newsletter = Newsletter.new(params[:newsletter])
    respond_to do |format|
      if @newsletter.save
        format.html { redirect_to("/admin/newsletters/"+@newsletter.id.to_s, :notice => 'Newsletter was successfully created.') }
        format.xml  { render :xml => @newsletter, :status => :created, :location => @newsletter }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @newsletter.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /admin_newsletters/1
  # PUT /admin_newsletters/1.xml
  def update
    @newsletter = Newsletter.find(params[:id])

    respond_to do |format|
      if @newsletter.update_attributes(params[:newsletter])
        format.html { redirect_to(@newsletter, :notice => 'Admin::Newsletter was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @newsletter.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /admin_newsletters/1
  # DELETE /admin_newsletters/1.xml
  def destroy
    @newsletter = Newsletter.find(params[:id])
    @newsletter.destroy

    respond_to do |format|
      format.html { redirect_to(admin_newsletters_url) }
      format.xml  { head :ok }
    end
  end
  
  def send_news_letter
    params[:categoryid].split(",").each do |cid|
       prfilecategory = ProfilesCategory.find(:all,:conditions=>["category_id = ?",cid])
        prfilecategory.each do |prct|
          newlem = Newsletteremail.new
          newlem.user_id = prct.profile.user.id
          newlem.newsletter_id = params[:newsletter]
          newlem.save
        end
    end
    #in future i think i need to call this method by cron tab but currently as discussed with amit sir im sending email  immedietly
    send_news_letter_category_wise
    flash[:notice] = "Email Sent To Users"
    redirect_to "/admin/profiles"
  end
  def send_news_letter_category_wise
       nlm = Newsletteremail.find(:all,:conditions=>["emailsend is null"])
       for nl in nlm
         begin
         nlc=nl.newsletter.news_letter_content
          doc = Nokogiri::HTML(nlc)
          doc.xpath('//img').each do |node|
            cip= node.get_attribute('src')
            node.set_attribute('src',"http://#{request.host_with_port}/"+cip)
          end
          email= UserMailer.create_send_emailnewsletter(nl.newsletter.title,doc.to_html,nl.user)
          UserMailer.deliver(email)
         rescue
         end  
         nl.emailsend = true
         nl.save
       end
   #    render :nothing=>true 
  end
  
  
end
