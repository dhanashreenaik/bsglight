# This module is defining the different methods and actions required by an Object controller to acts like an Item.
# It is so defining the mixin method that will include all these required methods and actions inside this Object controller.
#
module ActsAsContainer
  module ControllerMethods

    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      def acts_as_container &block
				# Declaration of the AjaxValidation plugin
				acts_as_ajax_validation

				acts_as_searchable

        make_resourceful do
          actions :all, :except => [:index]

          # Inclusion of the block if a block is found
          self.instance_eval(&block) if block_given?

          before :show do
            
            params[:id] ||= params["#{@current_object.class.to_s.downcase}_id".to_sym]
            # Just for the first load of the show, means without item selected
            current_container.class.to_s.underscore == "website" ? params[:item_type] = "pages" : params[:item_type] ||= get_allowed_item_types(@current_object).first.to_s.pluralize
            if !params[:item_type].blank?
              @paginated_objects = []
              @paginated_objects = params[:item_type].classify.constantize.get_da_objects_list(setting_searching_params(:from_params => params))
              if params[:item_type] == 'exhibitions'
                  @paginated_objects << Groupshow.find(:all,:order => "created_at DESC")
              end  
              @paginated_objects.flatten!
              
              @paginated_objects.sort! { |x,y| y.created_at <=> x.created_at } 
              
              @total_objects_count = params[:item_type].classify.constantize.matching_user_with_permission_in_containers(@current_user, 'show', [current_object.class.to_s.underscore+'-'+current_object.id.to_s]).uniq.size
              @ordering_filters = ['created_at','comments_number', 'viewed_number', 'rates_average', 'title']
              #generate the correct address for ITEM IN WORKSPACe PAGINATION
              #@ajax_url = "/admin/#{current_container.class.to_s.underscore.pluralize}/#{current_container.id}/ajax_content/" + params[:item_type]
							@ajax_url = container_path(@current_object)+'?item_type='
            end
          end

          before :new do
            @roles = Role.of_type('container')
          end

          before :edit do
            @current_object = current_model.find(params[:id], :include => {:users_containers => :user})
            @roles = Role.of_type('container')
            @users = []
            @users = User.all.collect!{|u| {:login => u.login, :email => u.email} }.to_json
          end

          before :create do
            params[:id] ||= params[:workspace_id]
            @current_object.creator = @current_user
          end
          
          after :create do
            UsersContainer.create(:user_id => @current_user.id, :containerable_id => @current_object.id, :containerable_type => @current_object.class.to_s, :role_id => Role.find_by_name('co_admin').id)
            flash[:notice] =I18n.t("#{@current_object.label_name}.new.flash_notice")
          end
          
          after :create_fails do
            @roles = Role.of_type('container')
            flash.now[:error] =I18n.t("#{@current_object.label_name}.new.flash_error")
          end

          before :update do
            # Hack. Permit deletion of all assigned users (with roles).
            #params["workspace"]["existing_user_attributes"] ||= {}
          end
          
          after :update do
            flash[:notice] =I18n.t("#{@current_object.label_name}.edit.flash_notice")
          end
          
          after :update_fails do
            @roles = Role.of_type('container')
            flash.now[:error] =I18n.t("#{@current_object.label_name}.edit.flash_error")
          end

          response_for :destroy do |format|
            format.html { redirect_to containers_path(@current_object.class.to_s) }
          end

          response_for :new, :create_fails do |format|
						format.html { render(:template => (File.exists?(RAILS_ROOT+'/app/views/'+params[:controller]+'/new.html.erb') ? params[:controller]+'/new.html.erb' : 'containers/new.html.erb')) }
					end

					response_for :edit, :update_fails do |format|
						format.html { render(:template => (File.exists?(RAILS_ROOT+'/app/views/'+params[:controller]+'/edit.html.erb') ? params[:controller]+'/edit.html.erb' : 'containers/edit.html.erb')) }
					end

          response_for :show do |format|
            format.html{render(:template => (File.exists?(RAILS_ROOT+'/app/views/'+params[:controller]+'/show.html.erb') ? params[:controller]+'/show.html.erb' : 'containers/show.html.erb'))}
						format.js { render :template => "admin/content/ajax_index.js.erb", :layout => false}
            format.xml { render :xml => @current_object }
            format.json { render :json => @current_object }
            format.atom { render :template => "items/index.atom.builder", :layout => false }
          end
        end

        
        # Inclusion of the instance methods inside the mixin method
        include ActsAsContainer::ControllerMethods::InstanceMethods
      end
    end

    module InstanceMethods

      def current_object
        @current_object ||= @container =
          if params[:id]
          params[:controller].split('/')[1].classify.constantize.find(params[:id])
        elsif p_id = params["#{params[:controller].split('/')[1].singularize}_id".to_sym]
          params[:controller].split('/')[1].classify.constantize.find(p_id.to_i)
        else
          nil
        end
      end
      
      def current_objects
        params[:container_type] = params[:controller].split('/')[1].singularize
        params_hash = setting_searching_params(:from_params => params)
        params_hash.merge!({:skip_pag => true}) if params[:format] && params[:format] != 'html'
        @current_objects ||= @paginated_objects = params[:controller].split('/')[1].classify.constantize.get_da_objects_list(params_hash)
        #Workspace.allowed_user_with_permission(@current_user, 'workspace_show')
      end

      def index
        current_objects
        if !request.xhr?
          @no_div = false
          respond_to do |format|
            format.html {render :template => "containers/index.html.erb"}
            format.xml { render :xml => @paginated_objects }
            format.json { render :json => @paginated_objects }
            format.atom {render :template => "containers/index.atom.builder", :layout => false }
          end
        else
          @no_div = true
          render :partial => 'containers/index', :layout => false
        end
      end

      # Action to insert user field with role to the workspace (used with AJAX call)
      #
      # This action is just updating the form, not saving the entry.
      #
      # Usage URL :
      # POST /workspaces/add_new_user
      def add_new_user
        controller = params[:controller].split('/')[1]
        @current_object ||= controller.classify.constantize.find(params[:id])
        @user = User.find_by_login(params[:user_login])
        @uw = @current_object.users_containers.new(:role_id => params[:role_id].to_i, :user_id => @user.id)
        render :update do |page|
          if @user
            page.insert_html :bottom, 'users', :partial => 'containers/user',  :object => @uw
          else
            page.call "alert","No user exist with #{params[:user_login]}"
          end
        end
      end
    end
  end
end
