# This controller is managing the different actions relative to the Group item.
#
# It is not using the mixin function called 'acts_as_item' from the ActsAsItem::ControllerMethods::ClassMethods,
# because the item is linked only to one workspace.
# By the way, it is not list with the content but in an other section called 'Contacts management'.
# TODO find a soltuion to manage item linked to just ONE workspace (with workspace_id field)
#

class Admin::GroupsController < Admin::ApplicationController

	# Method defined in the ActsAsItem:ControllerMethods:ClassMethods (see that library fro more information)
  acts_as_item do
		#Filter calling the encoder method of ConverterWorker with parameters
    before :new, :edit, :create, :update do
			get_contacts_lists
    end

		before :create, :update do
			@current_object.contacts_workspace_ids = params[:selectedOptions].split(',')
		end
  end
  
	#skip_before_filter :is_logged?, :only => [:unsubscribe]

	# Method to replace HTML for Assigned Options with Filter
  #
  # Usage URL:
  #
  # /people/filter?group_id=1
  def filtering_contacts
    group = Group.find(params[:object_id]) unless params[:object_id].blank?
    options = ""
		#raise current_workspace.contacts_workspaces.map{ |e| e.to_group_member(@current_user.id) }.delete_if{ |e| e['email'].first != params[:start_with] && params[:start_with] != "all"}.inspect
    current_workspace.contacts_workspaces(:all, :include => [:contactable]).map{ |e| e.to_group_member(@current_user.id) }.delete_if{ |e| e['email'].first.upcase != params[:filter_with] && params[:filter_with] != "all"}.each do |mem|
      if group.nil? || !group.contacts_workspaces.map{ |e| e.to_group_member(@current_user.id) }.include?(mem)
        options = options+ "<option value = '#{mem['id'].to_s}'>#{mem['email']}</option>"
      end
    end
    render :update do |page|
      page.replace_html 'assignedOptions' ,:text => options
    end
  end

  # Export members of the group to .csv file format
  #
  # This function is linked to an url and allows to generate and download the cvs file.
  def export_to_csv
    group = Group.find(params[:id])
    outfile = "group_people_" + Time.now.strftime("%m-%d-%Y") + ".csv"
		send_data(group.export_to_csv,
      :type => 'text/csv; charset=iso-8859-1; header=present',
      :disposition => "attachment; filename=#{outfile}")
  end

	protected

	def get_contacts_lists
		@workspace = @current_user.private_workspace
		selected_contacts = @current_object.contacts_workspaces.all(:include => [:contactable])
		remaining_contacts = @workspace ? (@workspace.contacts_workspaces.all(:include => [:contactable]) - selected_contacts) : []
		@selected_members = selected_contacts.map{ |e| e.to_group_member(@current_user.id) } || []
		@remaining_members = remaining_contacts.map{ |e| e.to_group_member(@current_user.id) } || []
	end

end