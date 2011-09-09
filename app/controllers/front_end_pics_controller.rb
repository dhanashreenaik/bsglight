class FrontEndPicsController < ApplicationController
    layout "gallery_promoting"  
    def index
          @front_end_pics = Frontendpic.find(:all,:order=>"created_at desc")
    end
    def new
          @front_end_pics = Frontendpic.new
    end
    def update
          @front_end_pics = Frontendpic.find(params[:id])
          @front_end_pics.update_attributes(params[:front_end_pic])
    end
    def select_pic
          @front_end_pics = Frontendpic.find(params[:id])
          @front_end_pics.selectpic = params[:select]
          @front_end_pics.save
        render :nothing=>true
    end
    def create
           front_end_pics = Frontendpic.new(params[:front_end_pic])    
           if params[:show_in_front] == "1"
              front_end_pics.selectpic = true 
           else
             front_end_pics.selectpic = false 
           end
           front_end_pics.save
           redirect_to :action=>"index"
    end
    def destroy
        front_end_pics = Frontendpic.find(params[:id])
        front_end_pics.destroy
        redirect_to :back    
    end
end

