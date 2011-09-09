class FrommailsController < ApplicationController
  # GET /frommails
  # GET /frommails.xml
  def index
    @frommails = Frommail.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @frommails }
    end
  end

  # GET /frommails/1
  # GET /frommails/1.xml
  def show
    @frommail = Frommail.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @frommail }
    end
  end

  # GET /frommails/new
  # GET /frommails/new.xml
  def new
    @frommail = Frommail.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @frommail }
    end
  end

  # GET /frommails/1/edit
  def edit
    @frommail = Frommail.find(params[:id])
  end

  # POST /frommails
  # POST /frommails.xml
  def create
    @frommail = Frommail.new(params[:frommail])

    respond_to do |format|
      if @frommail.save
        format.html { redirect_to(@frommail, :notice => 'Frommail was successfully created.') }
        format.xml  { render :xml => @frommail, :status => :created, :location => @frommail }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @frommail.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /frommails/1
  # PUT /frommails/1.xml
  def update
    @frommail = Frommail.find(params[:id])

    respond_to do |format|
      if @frommail.update_attributes(params[:frommail])
        format.html { redirect_to(@frommail, :notice => 'Frommail was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @frommail.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /frommails/1
  # DELETE /frommails/1.xml
  def destroy
    @frommail = Frommail.find(params[:id])
    @frommail.destroy

    respond_to do |format|
      format.html { redirect_to(frommails_url) }
      format.xml  { head :ok }
    end
  end
end
