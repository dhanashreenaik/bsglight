module ApplicationHelper
  
   def checklist(name, collection, value_method, display_method, selected)
    selected ||= []
    
    ERB.new(%{
    <div class="checklist" style="border:1px solid #666; width:20em; height:5em; overflow:auto;margin:51px">
      <% for item in collection %>
        <%= check_box_tag name, item.send(value_method), selected.include?(item.send(value_method)) %> <%=h item.send(display_method) %><br />
      <% end %>
    </div>}).result(binding)
  end
  
  def layout(website)
    if WEBSITE_TEMPLATES.include?(website.template)
      render :file => WEBSITE_TEMPLATES_FOLDER + "/" + website.template + "/layout.html.erb"
    elsif website.template == 'custom' && website.layout_file_name
      render :file => website.layout.path
    else
      render :text => "No Layout Defined"
    end 
  end

	def link_to_remove_fields(name, f)
    f.hidden_field(:_destroy) + link_to_function(name, "remove_fields(this)")
  end

  def link_to_add_fields(name, f, association)
    new_object = f.object.class.reflect_on_association(association).klass.new
    fields = f.fields_for(association, new_object, :child_index => "new_#{association}") do |builder|
      render('admin/'+association.to_s+'/'+association.to_s.singularize + "_fields", :f => builder)
    end
    link_to_function(name, h("add_fields(this, \"#{association}\", \"#{escape_javascript(fields)}\")"))
  end

	def blank_main_div(params, &block)
		params[:hsize] ||= 'sixH'
		if params[:modal]
			top_div = "<div id='modal_window' title='#{params[:title].to_s}'>"+flash_messages_manager(['notice', 'error'], 'modal', false)
		else
			old_top_div = "<div class='itemShowLeft'><div class='itemShowLeftBody'><h2>#{params[:title]}</h2>"
			top_div = "<title>#{params[:title].to_s}</title><div class='objectList small'>
				<div class='blockCornerLeft'></div>
				<div class='blockElementHeader #{params[:hsize]}'>
					
					<span id='item_count'>#{params[:title]}</span>
				</div>
				<div class='blockCornerRight'></div>
				<div class='contentList filtered #{params[:hsize]}'>"
		end
		bottom_div="</div></div>"
		bottom_div+="<script>
				$('.ui-dialog').remove();
				$('#modal_window').dialog({
                  modal: true,
                  width: 600,
                  height: 500
            });
				</script>" if params[:modal]
		if block_given?
			content = capture(&block)
			concat(top_div, block.binding)
			concat(content, block.binding)
			concat(bottom_div, block.binding)
		else
			top_div+bottom_div
		end

	end

	def old_school_switching_lists(params)
        return "<div id='select_boxes'>
        	
        	<input type='hidden' name='selectedOptions' id='selectedOptions' value='#{params[:selected_objects].map{ |e| e['id'] }.join(',')}'>
        	
            <div id='left_select_box'>
              <div class='optionAssignmentLabel'>
                 #{I18n.t('general.common_word.remaining')}
                <select id='filter_with' name='filter_with' onchange=\"show_new_selection('#{params[:ajax_url]}', '#{params[:object_id]}');\" >
                  <option value='all'>#{I18n.t('general.common_word.all')}</option>
                  #{params[:filters_options]}
                </select>
              </div>
              <select name='assignedPeople' id='assignedOptions' size='5' multiple class='theatreSelection' >
                #{params[:remaining_objects].map{ |e| content_tag(:option, (params[:field].is_a?(Symbol) ? e.send(params[:field]) : e[params[:field]]), :value => e['id'].to_s) }}
              </select>
              <button class='smallSubmit sendAll' type='button'
				        onclick=\"selectAll($('#assignedOptions'),'assignedOptions')\" >
					      <span>#{I18n.t('general.common_word.select_all')}</span>
			  	    </button>
            </div>
            <div id='left_right_buttons'>
         		  <input type='button' class='sendLeftButton' onclick=\"shiftRight('availableOptions','assignedOptions', 'selectedOptions')\"/>
          		<input type='button' class='sendRightButton' onclick=\"shiftLeft('assignedOptions','availableOptions', 'selectedOptions')\"/>
            </div>
        <div id='right_select_box' >
          <div class='optionAssignmentLabel'>#{I18n.t('general.common_word.selected')}</div>
          <select name='availableOptions' id='availableOptions' size='5' multiple >
            #{params[:selected_objects].map{ |e| '<option value='+e['id'].to_s+'>'+(params[:field].is_a?(Symbol) ? e.send(params[:field]) : e[params[:field]])+'</option>' } }
          </select>
          <button type='button'
					class='smallSubmit sendAll'
					onclick=\"selectAll($('availableOptions'),'availableOptions')\">
					<span>#{I18n.t('general.common_word.select_all')}</span>
				</button>
        </div>
      </div>"
	end

	def blank_form_submit_button(*args)
		options = args.extract_options!
		options[:method] ||= 'get'
		options[:class] ||= 'submitButton'
		options[:name] ||=
			if options[:object].new_record?
				I18n.t('general.button.create')
			else
				#I18n.t('general.button.update_and_continue')
				I18n.t('general.button.update')
			end
		if !options[:remote]
			res = "<button class='submitButton' type='submit'>
          <span>#{options[:name]}</span>
        </button>"
			#res = submit_tag options[:name], :class => options[:class]; return false;"
		else
#			res = "<button class='submitButton' type='submit' onclick='#{remote_function(:url => options[:url], :update => options[:update], :method => options[:method])+'; return false;'}'>
#          <span>#{options[:name]}</span>
#        </button>"
			# jQuery.ajax({data:jQuery.param(jQuery(this.form).serializeArray()), success:function(request){jQuery('#modal_space').html(request);}, type:'post', url:'/admin/competitions_subscriptions/subscribe'});
			res = submit_to_remote 'da_btn', options[:name], :url => options[:url], :update => options[:update], :class => options[:class]
		end
#		if options[:cancel]
#			res += "<button class='submitButton' type='cancel'>
#          <span>#{ 'Cancel' }</span>
#        </button>"
#		end
		#return "<div class='submitButton'>"+res+"<span>#{options[:name]}</span></div>"
		#raise res.inspect
		return res
	end

#	def blank_action_button(*args, &block)
#		options = args.extract_options!
#		options[:method] ||= 'get'
#		options[:class] ||= 'submitButton'
#		if options[:remote] || options[:function]
#			# ppbb input object
#			options[:function] ||= remote_function(:url => options[:url], :update => options[:update], :method => options[:method])
#					#{ :success => options[:update], :fail => 'error' })
#			res = button_to_function(options[:name], options[:function], :class => options[:class])
#		else
#			res = button_to(options[:name], :action => options[:url], :class => options[:class])
#		end
#		return "<div class='submitButton'>"+res+"<span>#{options[:name]}</span></div>"
#	end

	def blank_action_button(*args, &block)
		options = args.extract_options!
		options[:method] ||= 'get'
		options[:class] ||= 'submitButton'
		if options[:remote] || options[:function]
			# ppbb input object
			options[:function] ||= remote_function(:url => options[:url], :update => options[:update], :method => options[:method])
					#{ :success => options[:update], :fail => 'error' })
			res = link_to_function("<span>#{options[:name]}</span>", options[:function], :class => options[:class])
		else
			res = link_to("<span>#{options[:name]}</span>", options[:url], :class => options[:class])
		end
		return res
	end

	def blank_small_button(name, id)
		return "<button id='submit_button' class='smallSubmit' type='submit'><span>#{ name }</span></button>"
	end

	def exhibition_in_array(exhib)
		users = exhib.exhibitions_users#.all(:include => [:user => [:profile]])
		tmp = []
		return link_to(exhib.title, item_path(exhib))+"<br />(
			#{(tmp=users.dup).size},
			#{(tmp=users.dup).delete_if{ |e| e.state != 'invited'}.size},
			#{(tmp=users.dup).delete_if{ |e| e.state != 'refused'}.size},
			#{(tmp=users.dup).delete_if{ |e| e.state != 'accepted'}.size},
			#{(tmp=users.dup).delete_if{ |e| e.state != 'validated' || e.state != 'unpublished'}.size},
			#{(tmp=users.dup).delete_if{ |e| e.state != 'published'}.size}
		)<br />#{users.map{ |e| @current_user.has_system_role('admin') ? link_to(e.user.profile.full_name, admin_profile_url(e.user.profile.id)) : e.user.profile.full_name}.join(', ') }"
	end

	def exhibition_in_array_gallery(exhib)
		users = exhib.exhibitions_users  if  exhib#.all(:include => [:user => [:profile]])
		tmp = []
		return link_to(exhib.title, item_path(exhib))  if exhib
	end
        def exhibition_user_in_array_gallery(exhib)
		users = exhib.exhibitions_users if exhib#.all(:include => [:user => [:profile]])
		tmp=users.dup if tmp 
		tmp=users.dup.delete_if{ |e| e.state != 'invited'}  if tmp
		tmp=users.dup.delete_if{ |e| e.state != 'refused'}  if tmp
		tmp=users.dup.delete_if{ |e| e.state != 'accepted'}  if tmp
		tmp=users.dup.delete_if{ |e| e.state != 'validated' || e.state != 'unpublished'}  if tmp
		tmp=users.dup.delete_if{ |e| e.state != 'published'}  if tmp
		return "<br/>"+
		users.map{ |e| @current_user.has_system_role('admin') ? "<br>" + link_to(e.user.profile.full_name, admin_profile_url(e.user.profile.id))  : "<br>" + e.user.profile.full_name }.join(', ') + "<br/>"  if users
		
	end
	def flash_messages_manager(types=['notice', 'error', 'warning'], klass=nil, close=true)
		res = ''
		types.each do |msg|
			res += content_tag(:div, flash[msg.to_sym].to_s+(close ? "<a href='#' id='error_closing'>Close</a>" : ''), :class => klass ? klass+'_'+msg : msg, :id => msg, :style => "#{'display:none' unless flash[msg.to_sym]}")
		end
		return res
	end

	def blank_list_element(parameters, &block)
		concat(
      render( :partial => "admin/blank_lists/list_element",
        :locals => {  :date => parameters[:date],
          :title => parameters[:title],
          :block => block }))
	end

#	def easy_html_table(*args)
#		options = args.extract_options!
#		raise "Objects list" unless !options[:objects].nil?
#		raise ""
#
#
#		if block_given?
#			content = capture(&block)
#			concat(top_div, block.binding)
#			concat(content, block.binding)
#			concat(bottom_div, block.binding)
#		else
#			top_div+bottom_div
#		end
#
#
#	end

end
