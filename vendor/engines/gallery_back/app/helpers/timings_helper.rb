module TimingsHelper

	def add_timing_fields(*args)
		options = args.extract_options!
		render :partial => 'admin/timings/timing_fields', :locals => options
	end

end
