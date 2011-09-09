class PromotingStuffsController < ApplicationController
	
	layout "gallery_promoting"  
	
	
	def new
		@promoting_stuff = PromotingStuff.new
	end	
	
	def create
		promoting_stuff = PromotingStuff.new(params[:promotingstuff])
		promoting_stuff.save!
		redirect_to   promoting_stuffs_path
	end	
	
	def  index
		@promoting_stuff = PromotingStuff.find(:all,:limit=>3,:order=>"created_at desc")
	end	
	
	def edit
		@promotingstuff = PromotingStuff.find(params[:id])
	end	
	def update
		
		@promotingstuff = PromotingStuff.find(params[:id])
		@promotingstuff.update_attributes!(params[:promotingstuff])
		redirect_to :action=>"index"
	end

	def show
		@promoting_stuff = PromotingStuff.find(params[:id])
	end
	
	def destroy
		@promoting_stuff = PromotingStuff.find(params[:id])
		@promoting_stuff.destroy
		redirect_to :action=>"index"
	end	
end
