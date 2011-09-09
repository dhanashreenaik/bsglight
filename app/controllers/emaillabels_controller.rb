class EmaillabelsController < ApplicationController
  # GET /emaillabels
  # GET /emaillabels.xml
  def index
    @emaillabels = Emaillabel.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @emaillabels }
    end
  end

  # GET /emaillabels/1
  # GET /emaillabels/1.xml
  def show
    @emaillabel = Emaillabel.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @emaillabel }
    end
  end

  # GET /emaillabels/new
  # GET /emaillabels/new.xml
  def new
    @emaillabel = Emaillabel.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @emaillabel }
    end
  end

  # GET /emaillabels/1/edit
  def edit
    @emaillabel = Emaillabel.find(params[:id])
  end

  # POST /emaillabels
  # POST /emaillabels.xml
  def create
    @emaillabel = Emaillabel.new(params[:emaillabel])

    respond_to do |format|
      if @emaillabel.save
        format.html { redirect_to(@emaillabel, :notice => 'Emaillabel was successfully created.') }
        format.xml  { render :xml => @emaillabel, :status => :created, :location => @emaillabel }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @emaillabel.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /emaillabels/1
  # PUT /emaillabels/1.xml
  def update
    @emaillabel = Emaillabel.find(params[:id])

    respond_to do |format|
      if @emaillabel.update_attributes(params[:emaillabel])
        format.html { redirect_to(@emaillabel, :notice => 'Emaillabel was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @emaillabel.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /emaillabels/1
  # DELETE /emaillabels/1.xml
  def destroy
    @emaillabel = Emaillabel.find(params[:id])
    @emaillabel.destroy

    respond_to do |format|
      format.html { redirect_to(emaillabels_url) }
      format.xml  { head :ok }
    end
  end
end
