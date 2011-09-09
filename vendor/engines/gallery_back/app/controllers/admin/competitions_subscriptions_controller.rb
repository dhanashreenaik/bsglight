class Admin::CompetitionsSubscriptionsController < Admin::ApplicationController

	acts_as_ajax_validation

	def select
		@competition = Competition.find(params[:competition_id])
		if cu=CompetitionsUser.find(:first, :conditions => { :competition_id => @competition.id, :user_id => @current_user.id})
			if cu.state.nil?
				cu.destroy
				render :partial => 'admin/competitions_subscriptions/select', :layout => false
			else
				flash[:error] = "Already subscribed for that competition, please refresh the page"
				render :text => @template.blank_main_div(:title => 'System error', :hsize => 'sixH', :modal => true), :layout => false
			end
		else
			render :partial => 'admin/competitions_subscriptions/select', :layout => false
		end
	end

	def subscribe
		if params[:selection] && params[:selection][:cs_id] && cs=CompetitionsSubscription.find(params[:selection][:cs_id])
			if cu=CompetitionsUser.create(
				:user_id => @current_user.id,
				:competitions_subscription_id => cs.id,
				:competition_id => cs.competition.id,
				:price => cs.price,
				:state => 'created'
			)
			#flash[:notice] = "Subscription succeeded"
				#redirect_to invoicing_admin_invoices_url(:purchasable_type => cu.class.to_s, :purchasable_id => cu.id)
				@order = cu
				session[:purchasable] = @order
				flash[:notice] = "Subscription selected"
				render :partial => 'admin/invoices/invoicing', :layout => false
	#			render :partial => 'admin/competitions_subscriptions/select', :layout => false
	#			redirect_to artworks_wizard_admin_competitions_user_path(cu.id)
			else
				flash[:error] = "Subscription failed"
				render :text => @template.blank_main_div(:title => 'System error', :hsize => 'sixH', :modal => true), :layout => false
			end
		else
			flash[:error] = "Please select a subscription"
			render :partial => 'admin/competitions_subscriptions/select', :layout => false
		end

	end
	acts_as_item do
	def enter
		@places = Gallery.all
		@current_object.build_timing if @current_object.timing.nil?
		@judges = User.find(:all, :conditions => "system_role_id=1 OR system_role_id=2")
		@current_object.competitions_subscriptions.build if @current_object.competitions_subscriptions.empty?
	#@my_subscription=CompetitionsUser.find(:first, :include => [:competitions_subscription], :conditions => { :user_id => @current_user.id, :competition_id => @current_object.id })
		if CompetitionsUser.exists?(:user_id => @current_user.id)
		end	
	end
	end

	def submit

	end
end
