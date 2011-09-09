ActionController::Routing::Routes.draw do |map|
  

  map.resources :newsletters
  map.resources :frommails
  map.resources :signatures
  map.resources :emaillabels
  map.connect "/show_user_type"	,:controller=>"show_user_type",:action=>"index"
  map.connect "/admin/competitions/create_subscribe_competition"	,:controller=>"competitions",:action=>"create_subscribe_competition"
  map.connect "/add_user_to_groupshow/:id"	,:controller=>"groupshows",:action=>"add_user_to_groupshow"
  map.connect "/addusergroupshow/:id"	,:controller=>"groupshows",:action=>"addusergroupshow"
  map.connect "/shoppingcart/add_to_cart/:id",:controller=>"shoppingcart",:action=>"add_to_cart"
  map.connect "/shoppingcart/show_me_cart/:id",:controller=>"shoppingcart",:action=>"show_me_cart"
  map.connect "/shoppingcart/remove_from_cart",:controller=>"shoppingcart",:action=>"remove_from_cart"
  map.connect "/shoppingcart/show_payment_form",:controller=>"shoppingcart",:action=>"show_payment_form"
  map.connect "/shoppingcart/shopping_cart_payment",:controller=>"shoppingcart",:action=>"shopping_cart_payment"
  map.connect "/shoppingcart/list_of_my_order",:controller=>"shoppingcart",:action=>"list_of_my_order"
  map.connect "/send_news_letter_category_wise",:controller=>"/admin/newsletters",:action=>"send_news_letter_category_wise"
  
  map.connect "/shopping_paypal_cancel/:id" ,:controller=>"shoppingcart",:action=>"paypal_cancel"
  map.connect "/shopping_paypal_return/:id" ,:controller=>"shoppingcart",:action=>"paypal_return"
  
  
  map.connect "admin/groupshows/update/:id",:controller=>"/admin/groupshows",:action=>"update"
  map.connect "admin/groupshows/delete/:id",:controller=>"/admin/groupshows",:action=>"destroy"
  
  map.connect "/admin/competitions/confirm_competition_subscription_details/:id"	,:controller=>"competitions",:action=>"confirm_competition_subscription_details"
  map.connect "/admin/competitions/edit_competition_subscription_details/:id"	,:controller=>"competitions",:action=>"edit_competition_subscription_details"
  map.connect "/admin/competitions/update_subscribe_competition/:id",:controller=>"competitions",:action=>"update_subscribe_competition"
  map.connect "/admin/competitions/add_exhibition_artwork_insamediv",:controller=>"competitions",:action=>"add_exhibition_artwork_insamediv"
  map.connect "/admin/competitions/show_group_show_form/:id",:controller=>"competitions",:action=>"show_group_show_form"
  map.connect "/show_group_payment",:controller=>"competitions",:action=>"show_group_payment"
  map.connect "/upload_the_artwork_to_groupshow",:controller=>"competitions",:action=>"upload_the_artwork_to_groupshow"
  map.connect "/show_upload_groupform/:id",:controller=>"competitions",:action=>"show_upload_groupform"
  map.connect "/edit_groupshow_image/:id",:controller=>"competitions",:action=>"edit_groupshow_image"
  map.connect "/edit_upload_the_artwork_to_groupshow/:id",:controller=>"competitions",:action=>"edit_upload_the_artwork_to_groupshow"
  
  
  
  map.connect "/create_subscribe_competition_front",:controller=>"competitions",:action=>"create_subscribe_competition_front"
  map.connect "/create_subscribe_competition_front_login",:controller=>"competitions",:action=>"create_subscribe_competition_front_login"
  map.connect "/create_subscribe_competition_front_register",:controller=>"competitions",:action=>"create_subscribe_competition_front_register"
  
  
  map.connect "/create_subscribe_competition_front_edit",:controller=>"competitions",:action=>"create_subscribe_competition_front_edit"
  
  

  map.connect "/competitions/upload_exhibition_artwork/:id",:controller=>"competitions",:action=>"upload_exhibition_artwork"
  map.connect "/upload_exhibition_artwork/:id",:controller=>"competitions",:action=>"upload_exhibition_artwork"
  
  map.connect "/competitions/create_exhibition_artwork_insamediv",:controller=>"competitions",:action=>"create_exhibition_artwork_insamediv"
  map.connect "/create_exhibition_artwork_insamediv",:controller=>"competitions",:action=>"create_exhibition_artwork_insamediv"




  map.connect "/competitions/edit_upload_the_artwork_to_competition/:id",:controller=>"competitions",:action=>"edit_upload_the_artwork_to_competition"
  map.connect "/edit_upload_the_artwork_to_competition/:id",:controller=>"competitions",:action=>"edit_upload_the_artwork_to_competition"

  
  
  
  map.connect "/competitions/upload_the_artwork_to_competition/:id",:controller=>"competitions",:action=>"upload_the_artwork_to_competition"
  
  map.connect "/competitions/show_buy_competition_artwork",:controller=>"competitions",:action=>"show_buy_competition_artwork"
  
  
  
  map.connect "/upload_the_artwork_to_competition/:id",:controller=>"competitions",:action=>"upload_the_artwork_to_competition"

  map.connect "/upload_the_biography/:id",:controller=>"competitions",:action=>"upload_the_biography" 
  
  map.connect "/competitions/upload_the_biography/:id",:controller=>"competitions",:action=>"upload_the_biography"
 
  
  map.connect "/test_delete/:id" ,:controller=>"competitions",:action=>"test_delete"
  map.connect "/test_anything/:id" ,:controller=>"competitions",:action=>"test_anything"
  
  
  map.connect "/competitions/upload_exhibition_image/:id",:controller=>"competitions",:action=>"upload_exhibition_image"
  map.connect "/upload_exhibition_image/:id",:controller=>"competitions",:action=>"upload_exhibition_image"
  


  
  map.connect "/competitions/create_exhibition_artwork",:controller=>"competitions",:action=>"create_exhibition_artwork"
  
  map.connect "/create_exhibition_artwork",:controller=>"competitions",:action=>"create_exhibition_artwork"

  map.connect "/competitions/edit_exhibition_image/:id",:controller=>"competitions",:action=>"edit_exhibition_image"
  
  map.connect "/edit_exhibition_image/:id",:controller=>"competitions",:action=>"edit_exhibition_image"

  map.connect "/paypal_return/:id",:controller=>"competitions",:action=>"paypal_return"
  
  map.connect "/paypal_cancel/:id" ,:controller=>"competitions",:action=>"paypal_cancel"
  
  map.connect "/paypal_return_invoice",:controller=>"admin/invoices",:action=>"paypal_return_invoice"
  
  map.connect "/paypal_cancel_invoice",:controller=>"admin/invoices",:action=>"paypal_cancel_invoice"
  
  map.connect "/competitions/add_exhibition_artwork",:controller=>"competitions",:action=>"add_exhibition_artwork"
  map.connect "/add_exhibition_artwork",:controller=>"competitions",:action=>"add_exhibition_artwork"
  
  
  map.connect "/competitions/create_the_payment",:controller=>"competitions",:action=>"create_the_payment"
  map.connect "/competitions/create_the_payment_exhibition",:controller=>"competitions",:action=>"create_the_payment_exhibition"
  
  map.connect "/create_the_payment_exhibition",:controller=>"competitions",:action=>"create_the_payment_exhibition"
  
  
  map.connect "/create_the_payment",:controller=>"competitions",:action=>"create_the_payment"
  map.connect "/competitions/create_login_front",:controller=>"competitions",:action=>"create_login_front"

  
  


  map.connect "/competitions/add_the_artwork",:controller=>"competitions",:action=>"add_the_artwork"
  map.connect "/add_the_artwork",:controller=>"competitions",:action=>"add_the_artwork"
  map.connect "/competitions/add_the_artwork_to_competition",:controller=>"competitions",:action=>"add_the_artwork_to_competition"
  map.connect "/add_the_artwork_to_competition",:controller=>"competitions",:action=>"add_the_artwork_to_competition"
  map.connect "/competitions/edit_images_front",:controller=>"competitions",:action=>"edit_images_front"
  map.connect "/edit_images_front",:controller=>"competitions",:action=>"edit_images_front"
  map.connect "/competitions/add_the_artwork_link",:controller=>"competitions",:action=>"add_the_artwork_link"
  map.connect "/add_the_artwork_link",:controller=>"competitions",:action=>"add_the_artwork_link"
  map.connect "/competitions/delete_old_competitionuserdata",:controller=>"competitions",:action=>"delete_old_competitionuserdata"
  
  map.connect "/admin/exhibitions/submit_exhibition_artwork/:id",:controller=>"admin/exhibitions",:action=>"submit_exhibition_artwork"
  map.connect "/admin/exhibitions/unselect_exhibition_artwork/:id",:controller=>"admin/exhibitions",:action=>"unselect_exhibition_artwork"
  
  map.connect "/admin/exhibitions/send_email_to_selected_user/:id",:controller=>"admin/exhibitions",:action=>"send_email_to_selected_user"
  
  map.connect "/admin/exhibitions/send_email_to_publish_user/:id",:controller=>"admin/exhibitions",:action=>"send_email_to_publish_user"
  
  
  map.connect "/admin/exhibition_selected_user_email/:id",:controller=>"admin/exhibitions",:action=>"exhibition_selected_user_email"
  
  
  
 
  map.connect "/admin/invoices/new/:id",:controller=>"admin/invoices",:action=>"new"
  
  map.connect "/admin/invoices/pay_for_invoice/:id",:controller=>"admin/invoices",:action=>"pay_for_invoice"
  map.connect "/admin/invoices/create_the_payment/:id",:controller=>"admin/invoices",:action=>"create_the_payment"
  
  map.connect "/payment_response" ,:controller=>"admin/payments",:action=>"create"
  map.connect "/admin/mail" ,:controller=>"admin/mail",:action=>"index"
  
  map.connect "/admin/delete_temprary_email" ,:controller=>"admin/mail",:action=>"delete_temprary_email"
  map.connect "/admin/delete_from_trash" ,:controller=>"admin/mail",:action=>"delete_from_trash"
  map.connect "/admin/flag_email" ,:controller=>"admin/mail",:action=>"flag_email"
  map.connect "/admin/show_flag_email" ,:controller=>"admin/mail",:action=>"show_flag_email"
  map.connect "/admin/compose_new_mail" ,:controller=>"admin/mail",:action=>"compose_new_mail"
  map.connect "/admin/create_sent_mail" ,:controller=>"admin/mail",:action=>"create_sent_mail"
  map.connect "/admin/create_sent_mail/:id" ,:controller=>"admin/mail",:action=>"create_sent_mail"
  
  
  
  map.connect "/admin/create_temporary_inbox" ,:controller=>"admin/mail",:action=>"create_temporary_inbox"
  map.connect "/admin/create_sent_mail_with_unknown" ,:controller=>"admin/mail",:action=>"create_sent_mail_with_unknown"  
  map.connect "/admin/show_message" ,:controller=>"admin/mail",:action=>"show_message"
  map.connect "/admin/replay_message" ,:controller=>"admin/mail",:action=>"replay_message"
  map.connect "/admin/replay_to_all" ,:controller=>"admin/mail",:action=>"replay_to_all"
  map.connect "/admin/delete_email",:controller=>"admin/mail",:action=>"delete_email"
  map.connect "/admin/delete_all_email",:controller=>"admin/mail",:action=>"delete_all_email"
  map.connect "/admin/create_label",:controller=>"admin/mail",:action=>"create_label"
  map.connect "/find_signature_label",:controller=>"admin/mail",:action=>"find_signature_label"
  map.connect "/find_signature",:controller=>"admin/mail",:action=>"find_signature"
  map.connect "/admin/flag_mail",:controller=>"admin/mail",:action=>"flag_mail"
  map.connect "/admin/delete_show_flag_mail",:controller=>"admin/mail",:action=>"delete_show_flag_mail"
  map.connect "/admin/delete_label",:controller=>"admin/mail",:action=>"delete_label"
  map.connect "/admin/unknown_email",:controller=>"admin/mail",:action=>"unknown_email"
  map.connect "/auto_complete_for_user_email",:controller=>"admin/mail",:action=>"auto_complete_for_user_email"
  map.connect "/admin/show_unknown_message",:controller=>"admin/mail",:action=>"show_unknown_message"
  map.connect "/admin/replay_message_to_unknown",:controller=>"admin/mail",:action=>"replay_message_to_unknown"
  

  
  map.connect "/admin/forward_email" ,:controller=>"admin/mail",:action=>"forward_email"
  map.connect "/admin/sent_mail" ,:controller=>"admin/mail",:action=>"sent_mail"
  map.connect "/admin/trash_mail" ,:controller=>"admin/mail",:action=>"trash_mail"
  map.connect "/admin/show_sent_message" ,:controller=>"admin/mail",:action=>"show_sent_message"
  map.connect "/admin/moveto" ,:controller=>"admin/mail",:action=>"moveto"
  map.connect "/admin/show_labeled_email" ,:controller=>"admin/mail",:action=>"show_labeled_email"
  map.connect "/admin/sent_flag_email" ,:controller=>"admin/mail",:action=>"sent_flag_email"
  map.connect "/admin/delete_sent_mail" ,:controller=>"admin/mail",:action=>"delete_sent_mail"
  map.connect "/admin/create_sent_mail_with_original_id/:id" ,:controller=>"admin/mail",:action=>"create_sent_mail_with_original_id"
  map.connect "/admin/profiles/compose_user_mail/:id",:controller=>"admin/profiles",:action=>"compose_user_mail"
  map.connect "/admin/profiles/create_sent_mail",:controller=>"admin/profiles",:action=>"create_sent_mail"
  map.connect "/admin/profiles/show_columns/:id",:controller=>"admin/profiles",:action=>"show_columns"
  map.connect "/show_message_sent/:id",:controller=>"admin/profiles",:action=>"show_message_sent"
  map.connect "/show_message_recd/:id",:controller=>"admin/profiles",:action=>"show_message_recd"
  
  
  
  map.resources :periods
  map.resources :people
  # Blank Specific Routes
  # Routes Related to SuperAdministrator
	map.namespace :superadmin do |sa|
		sa.connect '', :controller => 'superadmin/administration', :action => 'show'
		sa.resources :general_settings, :only => [:index, :update], :collection => { :editing => :get, :updating => :put }
		sa.resources :audits, :only => [:index]
		sa.resources :user_interfaces, :only => [:index, :update], :collection => { :editing => :get, :updating => :put, :check_color => :get, :colors_changing => :get }
		sa.resources :tasks, :only => [:index], :collection => { :run_task => :get }
		sa.resources :translations, :only => [:index, :update], :collection => { :updating => :put, :context_switching => :get, :translation_new => :any , :new_project => :any, :new_language => :any, :section_switching => :any }
      sa.resources :mailer_settings, :only => [:index], :collection => { :updating => :put }
		sa.resources :mailing_settings, :only => [:index], :collection => { :updating => :put }
		sa.resources :ecom_settings, :only => [:index], :collection => { :updating => :put }
    # Routes for Roles and Permissions in BA
    sa.resources :roles, :collection => {:validate => :post}
    sa.resources :permissions, :collection => {:validate => :post}
    sa.resources :google_analytics, :only => [:index], :collection => {:updating => :put}
	end
    map.connect "/admin/promoting_stuffs/update/:id",:controller=>"promoting_stuffs",:action=>"update"
    map.resources :promoting_stuffs  , :path_prefix => 'admin'
  
    map.resources :mailing_lists  , :path_prefix => 'admin'
    
    map.connect "/admin/show_studio_mail",:controller=>"mailing_lists",:action=>"show_studio_mail"
    
    map.connect "/admin/send_studio_email",:controller=>"mailing_lists",:action=>"send_studio_email"
    
    map.connect "/admin/send_mailing_email",:controller=>"mailing_lists",:action=>"send_mailing_email"
    
    map.connect "/admin/show_mailing_mail",:controller=>"mailing_lists",:action=>"show_mailing_mail"
  
      
  
    map.connect "/admin/booksshops/update/:id",:controller=>"booksshops",:action=>"update"
    
    map.resources :booksshops  , :path_prefix => 'admin'
    map.connect "/booksshops",:controller=>"booksshops",:action=>"index",:id=>"front"
    
    map.connect "/admin/app_homes/update/:id",:controller=>"app_homes",:action=>"update"
    map.resources :app_homes  , :path_prefix => 'admin'
    map.connect "/app_homes",:controller=>"app_homes",:action=>"index",:id=>"front"
    
    map.connect "/admin/front_end_pics/update/:id",:controller=>"front_end_pics",:action=>"update"
  
    map.connect "/admin/front_end_pics/select_pic/:id",:controller=>"front_end_pics",:action=>"select_pic"  
  
    
    map.resources :front_end_pics  , :path_prefix => 'admin'
    map.connect "/front_end_pics",:controller=>"front_end_pics",:action=>"index"
    
    map.connect "/admin/drawings/update/:id",:controller=>"drawings",:action=>"update"
    map.resources :drawings  , :path_prefix => 'admin'
    map.connect "/drawings",:controller=>"drawings",:action=>"index",:id=>"front"
    map.connect "/admin/links/approve/:id",:controller=>"links",:action=>"approve"
    map.connect "/admin/links/update/:id",:controller=>"links",:action=>"update"
    map.connect "/admin/signature",:controller=>"signatures",:action=>"index"
    map.connect "/add_frommail",:controller=>"signatures",:action=>"add_frommail"
    map.connect "/add_signature",:controller=>"signatures",:action=>"add_signature"

    
    
    map.resources :links  , :path_prefix => 'admin'
    map.resources :bottomline  , :path_prefix => 'admin'
    map.connect "/links",:controller=>"links",:action=>"index",:id=>"front"
    map.connect "/admin/competitions_users/update/:id",:controller=>"competitions_users",:action=>"update"
    map.connect "/admin/competitions_users/destroy/:id",:controller=>"competitions_users",:action=>"destroy"
    map.resources :competitions_users  , :path_prefix => 'admin'
    map.resources :competitions_artworks  , :path_prefix => 'admin'
    
  
  map.namespace :admin do |admin|
    admin.connect "/competitions/open/:id",:controller=>"competitions",:action=>"open"
    admin.connect "/competitions/finalist/:id",:controller=>"competitions",:action=>"finalist"
    admin.connect "/competitions/winner/:id",:controller=>"competitions",:action=>"winner"
    admin.connect "/competitions/send_winner_email/:id",:controller=>"competitions",:action=>"send_winner_email"
    admin.connect "/competitions/send_mail_to_artist/:id",:controller=>"competitions",:action=>"send_mail_to_artist"
    admin.connect "/competitions/send_winner_email/:id",:controller=>"competitions",:action=>"send_winner_email"
    
    admin.connect "/compcreate_sent_mail_to_artist/:id",:controller=>"competitions",:action=>"compcreate_sent_mail_to_artist"
    admin.connect "/competitions/auto_complete_for_profile_email",:controller=>"competitions",:action=>"auto_complete_for_profile_email"
    
    admin.connect "/compfind_signature_label",:controller=>"competitions",:action=>"compfind_signature_label"
    admin.connect "/compfind_signature",:controller=>"competitions",:action=>"compfind_signature"
    
    admin.connect "/profiles/exhibition_payment/:id",:controller=>"profiles",:action=>"exhibition_payment"
    admin.connect "/profiles/exhibition_payment_front/:id",:controller=>"profiles",:action=>"exhibition_payment_front"
    admin.connect "/profiles/edit_password/:id",:controller=>"profiles",:action=>"edit_password"
    admin.connect "/profiles/change_password/:id",:controller=>"profiles",:action=>"change_password"
    admin.connect "/send_news_letter",:controller=>"newsletters",:action=>"send_news_letter"
   
     
    
    # Generated by Restful Authentification
    admin.logout '/logout', :controller => 'sessions', :action => 'destroy'
    admin.login '/login', :controller => 'sessions', :action => 'new'
    admin.signup '/signup/:id', :controller => 'users', :action => 'new'
    admin.activate '/activate/:activation_code', :controller => 'users', :action => 'activate'
    admin.forgot_password '/forgot_password', :controller => 'users', :action => 'forgot_password'
    admin.reset_password '/reset_password/:password_reset_code', :controller => 'users', :action => 'reset_password'
    #admin.promoting_stuff '/promoting_stuff/new', :controller => 'users', :action => 'reset_password'
    #admin.promoting_stuff '/promoting_stuff' ,:controller => 'promoting_stuff', :action => 'index'
    #admin.promoting_stuff '/promoting_stuff/new' ,:controller => 'promoting_stuffs', :action => 'new'
   # admin.promoting_stuff_index '/promoting_stuffs/index' ,:controller => 'promoting_stuffs', :action => 'index'
    
   # admin.resources :promoting_stuffs
    #admin.resource :promoting_stuff
    admin.resources :users, :member => { :locking => :any, :resend_activation_mail_or_activate_manually => :post },
      :collection => {:autocomplete_on => :any, :validate => :any } do |user|
      user.resources :notifications, :only => [:index, :create]
			end
		def profiles_resources(root)
			PROFILES.map{ |e| e.pluralize.to_sym }.each do |e|
				root.resources e, :only => :none, :collection => { :validate => :any }
			end
		end
		profiles_resources(admin)
    # Sessions for managing user sessions
    admin.resource :session
  
    
    # Routes for People
    admin.resources :people, :collection => {:export_people => :any, :import_people => :any, :get_empty_csv => :get, :validate => :any ,:filter => :get }
    # Route for HomePage
    admin.resources :home, :only => [:index], :collection => { :autocomplete_on => :any }
    # Routes for Comments
    admin.resources :comments, :only => [:index, :edit, :update, :destroy], :member => { :change_state => :any, :add_reply => :any}, :collection => {:validate => :post}
    # Routes for ratings
    admin.resources :ratings, :only => [:index]
    # Route for HomePage
    admin.root :controller => 'home', :action => 'index'

    # Items are CMS component types
    # Those items may be scoped to different resources
    def items_resources(parent)
      ITEMS.each do |name|
        member_to_set = {
          :rate => :any,
          :add_comment => :any,
          :redirect_to_content => :any
        }
        member_to_set.merge!({:remove_file => :any}) if name=='article'
        member_to_set.merge!({:get_video_progress => :any}) if name=='video'
        member_to_set.merge!({:get_audio_progress => :any}) if name=='audio'
        member_to_set.merge!({:send_to_a_group => :any}) if name=='newsletter'
				member_to_set.merge!({:submit_artworks => :post}) if name=='exhibition' || name=='competition'
        member_to_set.merge!({:export_to_csv => :any}) if name=='group'
				member_to_set.merge!({:submit => :post}) if name=='submited_work'
				member_to_set.merge!({:set_an_exhibition => :get}) if name=='user_group'
        member_to_set.merge!({:download => :any}) if ['audio', 'video', 'cms_file', 'image'].include?(name)
        collection_to_set = {
          :validate => :post
        }
				collection_to_set.merge!({:filtering_artworks => :get, :index_by_galleries => :get }) if name=='exhibition'
        collection_to_set.merge!({:filtering_contacts => :get}) if name=='group'
				collection_to_set.merge!({:filtering_users => :get}) if name=='user_group'
        parent.resources name.pluralize.to_sym, :member => member_to_set, :collection => collection_to_set
      end
      parent.content '/content/:item_type', :controller => 'content', :action => 'index'
      parent.ajax_content '/ajax_content/:item_type', :controller => 'content', :action => 'ajax_index'
      parent.content_popup '/content_for_popup/:selected_item', :controller => 'content', :action => 'display_item_in_pop_up'
      #TODO delete pop_up, no more used.
    end

    # Newsletter related routes
    admin.unsubscribe_for_newsletter 'admin/unsubscribe_for_newsletter', :controller => 'workspace_contacts', :action => 'unsubscribe'

    # FCKTools route for utilities methods for FCK editor
    admin.connect '/ck_uploads/:item_type', :controller => 'ck_tools', :action => 'upload_from_ck'
    admin.connect '/ck_config', :controller => 'ck_tools', :action => 'config_file'
    admin.connect '/ck_display/tabs/:tab_name', :controller => 'ck_tools', :action => 'tabs'
    admin.connect '/ck_insert/gallery', :controller => 'ck_tools', :action => 'insert_gallery'
    admin.connect '/ajax_item_save/:item_type/:id', :controller => 'ck_tools', :action => "ajax_item_save" 
    admin.connect '/ajax_container_save/:container/:id', :controller => 'ck_tools', :action => "ajax_container_save"
    admin.connect "/emails/sent_mail/:id",:controller=>"emails",:action=>"sent_email"
    admin.connect "/emails/detail_mail/:id",:controller=>"emails",:action=>"detail_email"
    admin.connect "/emails/reply_email/:id",:controller=>"emails",:action=>"reply_email"
    admin.connect "/emails/delete_email/:id",:controller=>"emails",:action=>"delete_email"

    
    # Items created outside any workspace are private or fully public.
    # Items may be acceded by a list that gives all items the user can consult.
    # => (his items, the public items, and items in workspaces he has permissions)
    items_resources(admin)

    CONTAINERS.each do |container|
      admin.resources "#{container.pluralize}".to_sym, :member => { :add_new_user => :any }, :collection => {:validate => :post, :delete_asset => :any} do |con|
        con.resources :subscriptions, :only => [:create, :destroy], :collection => { :request => :any }
        items_resources(con)
        if container == 'workspace'
          con.resources :people, :collection => { :export_people => :any, :import_people => :any, :get_empty_csv => :get, :validate => :post ,:filter => :get }
          con.resources :workspace_contacts, :as => 'contacts', :except => :all, :collection => { :select => [:post, :get], :list => [:post, :get], :subscribe => :get}
        end
        if container == 'website'
          con.resources :analytics, :only => [:index]
          con.resources :menus
        end
        con.resources :zip_uploads
      end
    end
       
		admin.resources :emails, :only => :none, :collection => { :list_all_messages => :get, :display_full_message => :get,:inbox=>:get,:sent_mail=>:get,:compose_mail=>:get,:compose_email=>:post ,:detail_email=>:get}
		
		admin.resources :orders, :collection => { :show_cart => :get, :add_to_cart => :get, :remove_from_cart => :get, :complete_order => :get }
		admin.resources :invoices, :collection => { :validate => :post, :invoicing => :get, :generate_invoice => :post,:create_sent_mail => :post }, :member => { :update_state => :get , :open_update_state => :get,:create_sent_mail => :post}
		admin.resources :payments, :only => [:new, :create, :index]
		admin.resources :credit_cards, :only => :none, :collection => { :validate => :post }
		admin.resources :exhibitions_users, :only => :none, :member => { :send_invitation => :get, :update_state => :get,:delete_user => :post }, :collection => { :set_prices => :post }
    admin.resources :periods, :only => [:index, :create, :update, :destroy], :collection => { :validate => :post }
		admin.resources :profiles,:member => {:update_notices => :put }, :collection => { :validate => :post, :filter => :post }
		admin.resources :categories, :only => [:index, :create, :update, :destroy], :collection => { :validate => :post }
		admin.resources :timings, :only => [:index, :create, :destroy], :collection => { :ajax_remove => :get, :validate => :post, :calendar => :get }, :member => { :update_state => :get }
		admin.resources :competitions_subscriptions, :only => :none, :collection => { :validate => :post, :select => :get, :subscribe => :post , :enter => :get, :submit=> :post}
		#admin.resources :competitions_subscriptions, :only => :none, :collection => { :validate => :post, :select => :get, :subscribe => :post }
		admin.resources :competitions_users, :only => :none, :member => { :update_state => :get, :submit_artworks => :post, :artworks_wizard => :get }
		admin.resources :artworks_competitions, :only => :none, :member => { :update_state => :get }, :collection => { :set_marks => :post }
    # Search related routes
    admin.resources :searches, :collection => { :print_advanced => :any, :validate => :post }
    admin.resources :saved_searches, :only => [:create, :index, :destroy], :member => {:results => :get}, :collection => { :validate => :post }
    admin.resources :groupshows
  # Catch Errors and show custom message, avoid SWW
    admin.error '/admin/error/:status' , :controller => 'home', :action => 'error'
    
  end
  #################################################################################
  
  map.connect '/signup', :controller => 'admin/users', :action => 'new'
  # Add Project Specific Routes here!
  # Website Home
  map.resources :contacts, :only => [:new, :create]

	#### GALLERY FRONT
	map.root :controller => "visitors", :action => 'home_page'
		
	['past', 'current', 'future', 'next' ].each do |e|
		map.connect "/#{e}", :controller => :exhibitions, :action => e
		map.connect "/#{e}/artists/:id", :controller => :exhibitions, :action => e
		map.connect "/#{e}/artists/:id/exhibs/:exhib_id", :controller => :exhibitions, :action => e
	end
#	map.connect '/to_exhib', :controller => :exhibitions, :action => 'submit_form'
#	map.connect '/submiting', :controller => :exhibitions, :action => 'submiting', :conditions => { :method => :post }

	map.connect '/artists', :controller => :artists, :action => 'show'
	map.connect '/artists/:filter', :controller => :artists, :action => 'show'
	map.connect '/artists/:filter/:id', :controller => :artists, :action => 'show'
	map.connect '/artists/:filter/:id/exhibs/:exhib_id', :controller => :artists, :action => 'show'

	map.connect '/genres', :controller => :artists, :action => 'genres'
	map.connect '/genres/:genre_id', :controller => :artists, :action => 'genres'
	map.connect '/genres/:genre_id/artists/:id', :controller => :artists, :action => 'genres'
	map.connect '/genres/:genre_id/artists/:id/exhibs/:exhib_id', :controller => :artists, :action => 'genres'

	map.connect '/groups', :controller => :artists, :action => 'groups'
	map.connect '/groups/:year/:id', :controller => :artists, :action => 'groups'
 	map.connect '/groups/:group_id', :controller => :artists, :action => 'groups'
	map.connect '/groups/:group_id/artists/:id', :controller => :artists, :action => 'groups'
	map.connect '/groups/:group_id/artists/:id/exhibs/:exhib_id', :controller => :artists, :action => 'groups'
  map.connect '/tojoin', :controller => :artists, :action => 'tojoin'
  map.connect '/tojoin/:group_id', :controller => :artists, :action => 'tojoin'

	map.connect '/competitions', :controller => :competitions, :action => 'show'
	map.connect '/competitions/:competition_id', :controller => :competitions, :action => 'show'
  map.connect '/admin/competitions/change_state/:competition_id', :controller => 'admin/competitions', :action => 'change_state'
  map.connect '/admin/competitions/group_selection/:competition_id', :controller => 'admin/competitions', :action => 'group_selection'
	map.connect '/subscribe/:id', :controller => :visitors, :action => 'new'
	map.connect '/mailing_list', :controller => :visitors, :action => 'mailing_list'
	map.connect '/adding_profile', :controller => :visitors, :action => 'adding_profile'
	map.connect '/studios', :controller => :visitors, :action => 'studios'
	
	map.connect '/login/:id', :controller => :visitors, :action => 'login'
	map.connect '/logout/:id', :controller => 'admin/sessions', :action => 'destroy'
	
  map.connect '/site/:site_title', :controller => 'websites', :action => 'index'
  map.connect '/site/:site_title/:title_sanitized', :controller => 'websites', :action => 'index'
  map.connect '/:title_sanitized', :controller =>'websites', :action => 'index'
  map.resources :websites, :only => [:index, :update]
  
  
end
