class BooksshopsController < ApplicationController
  # GET /booksshops
  # GET /booksshops.xml
  	layout "gallery_promoting"  
  def index
    @bookshop = Booksshop.find(:all,:limit=>1,:order=>"created_at desc")
    if params[:id] == "front"
        #render :layout => "front"
        render :action=> "forntindex" ,:layout=>"front"
    else
      
    end
  end

  # GET /booksshops/1
  # GET /booksshops/1.xml
  def show
    @bookshop = Booksshop.find(params[:id])
  end

  # GET /booksshops/new
  # GET /booksshops/new.xml
  def new
    @bookshop = Booksshop.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @booksshop }
    end
  end

  # GET /booksshops/1/edit
  def edit
    @bookshop = Booksshop.find(params[:id])
  end

  # POST /booksshops
  # POST /booksshops.xml
  def create
    bookshop = Booksshop.new(params[:bookshop])
    bookshop.save
    redirect_to   booksshops_path
  end

  # PUT /booksshops/1
  # PUT /booksshops/1.xml
  def update
    @bookshop = Booksshop.find(params[:id])
    @bookshop.update_attributes!(params[:bookshop])
	redirect_to :action=>"index"
 
  end

  # DELETE /booksshops/1
  # DELETE /booksshops/1.xml
  def destroy
        @bookshop = Booksshop.find(params[:id])
        @bookshop.destroy
         redirect_to :action=>"index"
  end
end
