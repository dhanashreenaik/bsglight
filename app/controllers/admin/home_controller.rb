class Admin::HomeController < Admin::ApplicationController

  # HomePage of the Blank Application
  #
  # Root page ('/')
  #
  
  def index
  if current_user.login != "admin"  
    redirect_to "/"
  end
#    @latest_items = GenericItem.consultable_by(current_user.id).latest
    @latest_users = get_objects_list_with_search('user', 'created_at-desc', 5)
#    @latest_feeds = current_user.feed_items.latest
    @latest_ws = get_objects_list_with_search('workspace', 'created_at-desc', 5)
#		@accordion = [@latest_items,@latest_users,@latest_feeds,@latest_ws]
  end

  # Autocomplete on the specified model
  #
  # This function is link to an url and execute an AJAX request to get different choice
	# generated by the autocompletion algorithm.
  # You have to set a get parameter named 'object_name' to do it.
	def autocomplete_on
		conditions = if params[:name]
       ["name LIKE :name", { :name => "%#{params['name']}%"} ]
     else
       {}
     end
		 @objects = params[:model_name].classify.constantize.find(:all, :conditions => conditions)
		 render :text => '<ul>'+ @objects.map{ |e| '<li>' + e.name + '</li>' }.join(' ')+'</ul>'
	end
	
	def error
	  
	end

end

