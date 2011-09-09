class Admin::CategoriesController < Admin::ApplicationController

	acts_as_ajax_validation

  # GET /profiles
  # GET /profiles.xml
  def index
    @categories = Category.all
		if params[:id]
			@category = Category.find(params[:id])
		else
			@category = Category.new
		end
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @categories }
    end
  end

  # POST /categorys
  # POST /categorys.xml
  def create
    @category = Category.new(params[:category])
    respond_to do |format|
      if @category.save
        flash[:notice] = 'category was successfully created.'
        format.html { redirect_to admin_categories_path }
        format.xml  { render :xml => @category, :status => :created, :location => @category }
      else
        format.html { render :action => "index" }
        format.xml  { render :xml => @category.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /categorys/1
  # PUT /categorys/1.xml
  def update
    @category = Category.find(params[:id])
    respond_to do |format|
      if @category.update_attributes(params[:category])
        flash[:notice] = 'category was successfully updated.'
        format.html { redirect_to admin_categories_path }
        format.xml  { head :ok }
      else
        format.html { render :action => "index" }
        format.xml  { render :xml => @category.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /categorys/1
  # DELETE /categorys/1.xml
  def destroy
    @category = Category.find(params[:id])
    @category.destroy

    respond_to do |format|
      format.html { redirect_to admin_categories_url }
      format.xml  { head :ok }
    end
  end
end
