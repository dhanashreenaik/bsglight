class DrawingsController < ApplicationController
	layout "gallery_promoting"  
  def index
    @drawing = Drawing.find(:all,:limit=>1,:order=>"created_at desc")
    if params[:id] == "front"
        #render :layout => "front"
        render :action=> "forntindex" ,:layout=>"front"
    else
      
    end
  end

  def show
    @drawing = Drawing.find(params[:id])
  end

  def new
    @drawing = Drawing.new
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @drawing }
    end
  end

  
  def edit
    @drawing = Drawing.find(params[:id])
  end

  
  def create
    drawing = Drawing.new(params[:drawing])
    drawing.save
    redirect_to   drawings_path
  end

  
  def update
    @drawing = Drawing.find(params[:id])
    @drawing.update_attributes!(params[:drawing])
	redirect_to :action=>"index"
 
  end

  
  def destroy
        @drawing = Drawing.find(params[:id])
        @drawing.destroy
         redirect_to :action=>"index"
  end
end
