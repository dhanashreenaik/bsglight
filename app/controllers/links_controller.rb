class LinksController < ApplicationController
  # GET /links
  # GET /links.xml
    	layout "gallery_promoting"  
  def index
      if current_user
        if current_user.login == "admin" ||  current_user.login == "superadmin"
            @link = Link.find(:all,:limit=>15,:order=>"created_at desc")
       else
           @link = Link.find(:all, :conditions=>["user_id = ? ",current_user.id] ,  :limit=>15,:order=>"created_at desc")
       end
      else
          @link = Link.find(:all, :conditions=>["approve = ? ",true] ,  :limit=>15,:order=>"created_at desc")
      end 
       
    if params[:id] == "front"
        render :action=> "forntindex" ,:layout=>"front"
    else
    end
  end

  def show
    @link = Link.find(params[:id])
  end
  
  def approve
         @link = Link.find(params[:id])
         @link.approve = true
         @link.save
         redirect_to :action=>"index"
  end 
   


  def new
    @link = Link.new
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @link }
    end
  end

  # GET /links/1/edit
  def edit
    @link = Link.find(params[:id])
  end

  # POST /links
  # POST /links.xml
  def create
    @link = Link.new(params[:link])
     if current_user.login == "admin" ||  current_user.login == "superadmin"
     @link.approve = true
     end

      if @link.save
     redirect_to links_path 
      return
      else
     redirect_to :action=>"new"
     return
      end

  end

  # PUT /links/1
  # PUT /links/1.xml
  def update
    @link = Link.find(params[:id])

    respond_to do |format|
      if @link.update_attributes(params[:link])
        format.html { redirect_to(@link, :notice => 'Link was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @link.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /links/1
  # DELETE /links/1.xml
  def destroy
    @link = Link.find(params[:id])
    @link.destroy

    respond_to do |format|
      format.html { redirect_to(links_url) }
      format.xml  { head :ok }
    end
  end
end
