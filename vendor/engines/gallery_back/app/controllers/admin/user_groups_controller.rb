class Admin::UserGroupsController < Admin::ApplicationController

	acts_as_item do

		before :new, :edit do
			get_profiles_list
		end

		before :create, :update do
			@current_object.user_ids = params[:selectedOptions].split(',')
		end

	end

	def set_an_exhibition
		@user_group = UserGroup.find(params[:id])
		@current_object = Exhibition.new(
			:title => "Exhibition for '#{@user_group.title}' Group Show",
			:description => @user_group.description,
			:user_ids => @user_group.user_ids,
			:user_id => @current_user.id,
			:workspace_ids => [@current_user.private_workspace.id]
		)
		@current_object.build_timing if @current_object.timing.nil?
		@places = Gallery.all
		@artists = Profile.all
		@keywords = Keyword.all.collect{|k| k.name}.to_json
		@form = 'admin/exhibitions/form'
		respond_to do |format|
      format.html { render(:template => 'generic_for_item/new.html.erb') }
    end
	end

	def filtering_users
		@current_object = !params[:user_group_id].blank? ? UserGroup.find(params[:id]) : UserGroup.new
		get_profiles_list
    options = ""
		#raise current_workspace.contacts_workspaces.map{ |e| e.to_group_member(@current_user.id) }.delete_if{ |e| e['email'].first != params[:start_with] && params[:start_with] != "all"}.inspect
    @remaining_profiles.delete_if{ |e| e.full_name.first.upcase != params[:filter_with] && params[:filter_with] != "all"}.each do |mem|
      options = options+ "<option value = '#{mem.user_id.to_s}'>#{mem.full_name}</option>"
    end
    render :update do |page|
      page.replace_html 'assignedOptions' ,:text => options
    end
	end

	private

	def get_profiles_list
		@selected_profiles = @current_object.users.all(:include => [:profile]).map{ |e| e.profile }#.sort{|x, y| x.full_name <=> y.full_name}
		@remaining_profiles = (User.all(:include => [:profile]).map{ |e| e.profile } - @selected_profiles)#.sort{|x, y| x.full_name <=> y.full_name}
	end

end