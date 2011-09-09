class Admin::ContentController < Admin::ApplicationController
  
  # Action rendering the content tabs page for items
  #
	# This action is retrieving the items list of the type given by the 'item_type' parameters (HTTP parameters).
	# If this prameters is not given it will select automatically the first type available.
	# It is so rendering the 'items/index.html.erb' view template.
	#
	# Usage URL :
	# - GET /content
	# - GET /content?item_type=article
  def index
    params[:item_type] ||= get_allowed_item_types(current_container).first.pluralize
    params_hash = setting_searching_params(:from_params => params)
    params_hash.merge!({:skip_pag => true, :by => 'created_at-asc'}) if params[:format] && params[:format] != 'html'
    @paginated_objects = params[:item_type].classify.constantize.get_da_objects_list(params_hash)
    # get the number of items.
    @total_objects_count = params[:item_type].classify.constantize.matching_user_with_permission_in_containers(@current_user, 'show', current_container ? [current_container.class.to_s+'-'+current_container.id.to_s] : nil).uniq.size
    @ordering_filters = ['created_at', 'comments_number', 'viewed_number', 'rates_average', 'title']
    #generate the correct address for ITEM PAGINATION
	  @ajax_url = '/admin/content/'
		respond_to do |format|
		  format.html
		  format.xml { render :xml => @paginated_objects }
		  format.json { render :json => @paginated_objects }
			format.js { render :template => "admin/content/ajax_index.js.erb", :layout => false}
		  format.atom { render :template => "generic_for_items/index.atom.builder", :layout => false }
	  end
  end

end
