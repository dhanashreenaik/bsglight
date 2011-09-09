# This controller is managing the different actions relative to the Image item.
#
# It is using a mixin function called 'acts_as_item' from the ActsAsItem::ControllerMethods::ClassMethods,
# so see the documentation of that module for further informations.
#
class Admin::ArtworksController < Admin::ApplicationController

before_filter :workspace_id

def  workspace_id
  if params[:artwork]
    params["artwork"]["workspace_ids"]=Workspace.find(:first, :conditions => { :creator_id => current_user.id}).id.to_s
  end  
end



	# Method defined in  the ActsAsItem:ControllerMethods:ClassMethods (see that library fro more information)
	acts_as_item do 
	    after :create do
	    params[:continue] = true
	    end
	    
	    before :new do
	    @exhibition = current_user.exhibitions
	    end
	

	end
		
  # Download the file link to an Image item
  #
	# This function is linked to an url allowing to get the file by downloading
	# (and not trying to open it with the browser)
  def download
    @current_object = Artwork.find(params[:id])
    send_file(RAILS_ROOT+"/public"+@current_object.image.url.split("?")[0], :disposition => 'inline', :stream => false)
  end

end
