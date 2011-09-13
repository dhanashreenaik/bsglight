class AppHomesController < ApplicationController
  #testing the things
#for testing with github
  layout "gallery_promoting"  
  def index
    @app_home = AppHome.find(:all,:limit=>1,:order=>"created_at desc")
    
    columnnameandheader = Columnnameandheader.find(:all,:conditions=>["idoffieldwithtablename = ?",@app_home[0].id.to_s + "apphome"]) if !@app_home.blank?
    @oldlabelvalue={}
    if !columnnameandheader.blank?
	    columnnameandheader.each do |x|   
	      @oldlabelvalue[x.column_name] = x.column_header
	    end
    end  
      
    if params[:id] == "front"
      #render :layout => "front"
      render :action=> "forntindex" ,:layout=>"front"
    else
    end
  end

  def show
    @app_home = AppHome.find(params[:id])
  end

  def new
    @app_home = AppHome.new
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @app_home }
    end
  end

  
  def edit
    
    
    @app_home = AppHome.find(params[:id])
    columnnameandheader = Columnnameandheader.find(:all,:conditions=>["idoffieldwithtablename = ?",@app_home.id.to_s + "apphome"]) if !@app_home.blank?
    @oldlabelvalue={}
    columnnameandheader.each do |x|   
      @oldlabelvalue[x.column_name] = x.column_header
    end
    
  end

  
  def create
    drawing = AppHome.new(params[:app_home])
    drawing.save
    params.to_hash.each do |key,value|
      if key.include? "header"
        columnnameandheader = Columnnameandheader.new
        columnnameandheader.column_name = key.split("header")[1]        
        columnnameandheader.column_header = value
        columnnameandheader.idoffieldwithtablename = (drawing.id.to_s+"apphome")
        columnnameandheader.save
      end 
    end 
    redirect_to   app_homes_path
  end

  
  def update
    @app_home = AppHome.find(params[:id])
    @app_home.update_attributes!(params[:app_home])
    Columnnameandheader.delete_all(["idoffieldwithtablename = ?",@app_home.id.to_s + "apphome"])
    params.to_hash.each do |key,value|
      if key.include? "header"
        columnnameandheader = Columnnameandheader.new
        columnnameandheader.column_name = key.split("header")[1]        
        columnnameandheader.column_header = value
        columnnameandheader.idoffieldwithtablename = (@app_home.id.to_s+"apphome")
        columnnameandheader.save
      end 
    end  
  	redirect_to :action=>"index"
  end

  
  def destroy
    @app_home = AppHome.find(params[:id])
    @app_home.destroy
    redirect_to :action=>"index"
  end
end
