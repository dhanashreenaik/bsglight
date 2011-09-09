class BottomlineController < ApplicationController
  layout "gallery_promoting"  
  def index
      if current_user
        if current_user.login == "admin" ||  current_user.login == "superadmin"
            @bottomline = Bottomline.find(:first)
        end 
      end
  end
  
  def update
    @bottomline = Bottomline.find(:first)
    if @bottomline
      
    else 
    @bottomline =   Bottomline.new
    end
    @bottomline.bottomline = params[:bottomline]
    @bottomline.save
    
    redirect_to :action=>"index"
  end
  
end