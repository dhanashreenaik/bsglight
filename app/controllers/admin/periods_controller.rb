class Admin::PeriodsController < Admin::ApplicationController
  # GET /periods
  # GET /periods.xml
  def index
    @periods = Period.all
		@period = params[:id] ? Period.find(params[:id]) : Period.new

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @periods }
    end
  end

  # POST /periods
  # POST /periods.xml
  def create
    @period = Period.new(params[:period])

    respond_to do |format|
      if @period.save
        flash[:notice] = 'Period was successfully created.'
        format.html { redirect_to admin_periods_url }
        format.xml  { render :xml => @period, :status => :created, :location => @period }
      else
				@periods = Period.all
        format.html { render :action => "index" }
        format.xml  { render :xml => @period.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /periods/1
  # PUT /periods/1.xml
  def update
    @period = Period.find(params[:id])

    respond_to do |format|
      if @period.update_attributes(params[:period])
        flash[:notice] = 'Period was successfully updated.'
        format.html { redirect_to(@period) }
        format.xml  { head :ok }
      else
        @periods = Period.all
        format.html { render :action => "index" }
        format.xml  { render :xml => @period.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /periods/1
  # DELETE /periods/1.xml
  def destroy
    @period = Period.find(params[:id])
    @period.destroy

    respond_to do |format|
      format.html { redirect_to admin_periods_url }
      format.xml  { head :ok }
    end
  end
end
