class Admin::OrdersController < Admin::ApplicationController

	acts_as_ajax_validation

	def index
		if @current_user.has_system_role('admin')
			@current_objects = Order.all
		else
			@current_objects = @current_user.orders
		end
	end

	def show
		@current_object = Order.find(params[:id])

	end

	def show_cart
		@current_object = Order.new_from_cart(session[:cart], @current_user)
		render :template => "admin/orders/show.html.erb"
		
	end

	def add_to_cart
		objekt = { "#{params[:orderable_type]}_#{params[:orderable_id]}" => params[:number]}
		
		if session[:cart].merge!(objekt)
    
			flash[:notice] = "Product added to the cart"
		else
			flash[:error] = "Error ading product to the cart"
		end
		redirect_to "/admin/profiles/#{current_user.id}"
	end 

	def remove_from_cart
		session[:cart].delete("#{params[:orderable_type]}_#{params[:orderable_id]}")
    	redirect_to show_cart_admin_orders_url
	end

	def complete_order
		order = Order.complete_from_cart(session[:cart], @current_user)
		redirect_to invoicing_admin_invoices_url(:purchasable_type => order.class.to_s, :purchasable_id => order.id,:show_layout=>false)
	end

end
