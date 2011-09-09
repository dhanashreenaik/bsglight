# This controller is managing the different actions relative to the Image item.
#
# It is using a mixin function called 'acts_as_item' from the ActsAsItem::ControllerMethods::ClassMethods,
# so see the documentation of that module for further informations.
#
class Admin::TimingsController < Admin::ApplicationController

	acts_as_ajax_validation

	# Filter restricting the access to only superadministrator user
	before_filter :is_admin?, :except => [:calendar, :index]

	def index
		if params[:event]
			@timings = Timing.all(:conditions =>"objectable_type = '#{params[:event]}' and objectable_id is not null")
    else
			@timings = Timing.all
		end
    mystartexhibition = @timings.map{ |e| e.to_calendar_format_start }
    @timings.map{ |e| mystartexhibition.push(e.to_calendar_format_end) }
    respond_to do |format|
			format.html
     	format.json { render :json => mystartexhibition }
		end
    
  end

	def create
		@timing = Timing.new(params[:timing].merge(:state => 'request'))
		#respond_to do |format|
		@places = Gallery.all
		@current_object = params[:timing][:objectable_type].classify.constantize.find(params[:timing][:objectable_id])
			if @timing.save
				redirect_to item_path(@current_object)
			else
				redirect_to item_path(@current_object)
				#render :show
			end
		#end
	end

	def update_state
		@timing = Timing.find(params[:id])
		@timing.state = params[:new_state]
		if @timing.save
			#render :update
		end
		redirect_to admin_timings_path
	end

	def destroy
		@current_object.find(params[:id])
		@current_object.destroy
		redirect_to admin_timings_path
	end

	def calendar
		if params[:event]
			@daurl = "/admin/timings?format=json&event=#{params[:event]}"
		else
			@daurl = "/admin/timings.json"
		end
	end

end