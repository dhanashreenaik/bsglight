class ArtistsController < ApplicationController

	layout 'front'

  def show
	 	@artists = []
		if params[:id]
			@profile = Profile.find(params[:id])
		end
		if params[:filter]
			if params[:filter] == 'y-z'
				@artists = Profile.find(:all, :conditions => ["first_name LIKE :filter1 OR first_name LIKE :filter2", { :filter1 => "y%", :filter2 => "z%" }]).delete_if{ |p| p.user.exhibitions.published.empty? }.sort {|x,y| x.full_name <=> y.full_name }
			else
       		@artists = Profile.find(:all, :conditions => ["first_name LIKE :filter", { :filter => "#{params[:filter]}%"}]).delete_if{ |p| p.user.exhibitions.published.empty? }.sort {|x,y| x.full_name <=> y.full_name }
			
			end
			@profile ||= @artists.first
		else
			@profile ||= ExhibitionsUser.all(:conditions => { :state => 'published' }).rand.user.profile if ExhibitionsUser.all(:conditions => { :state => 'published' }).first
			params[:filter] = @profile.first_name.first if @profile
			@artists = Profile.find(:all, :conditions => ["first_name LIKE :filter", { :filter => "#{@profile.first_name.first}%"}]).delete_if{ |p| p.user.exhibitions.published.empty? }.sort {|x,y| x.full_name <=> y.full_name } if @profile
		end
		if @profile
			if (@exhibitions=@profile.user.exhibitions.published.uniq)
				if params[:exhib_id]
					@exhibition = Exhibition.find(params[:exhib_id])
				else
					@exhibition = @exhibitions.rand
				end
			else
				# TODO dddeeerrr
			end
		end
		params[:which] = "artists/#{params[:filter]}"
		respond_to do |format|
			format.html { render :template => 'artists/show.html.erb' }
		end
	end

	def genres
		@genres = Category.all.sort {|x,y| x.name <=> y.name } 
		@artists = []
		if params[:id]
			@profile = Profile.find(params[:id])
		end
		if params[:genre_id]
			@artists = Category.find(params[:genre_id]).profiles.delete_if{ |p| p.user.exhibitions.published.empty? }.sort {|x,y| x.full_name <=> y.full_name }
		else
			@artists = Category.all.rand.profiles.delete_if do |p| 
			    if p.user
        			   p.user.exhibitions.published.empty? 
			    end
			  end  
			  @artists = @artists.sort {|x,y| x.full_name <=> y.full_name }
		end
		@profile ||= @artists.first
		if @profile
			params[:genre_id] ||= @profile.profiles_categories.first.category_id
			if (@exhibitions=@profile.user.exhibitions.published)
				if params[:exhib_id]
					@exhibition = Exhibition.find(params[:exhib_id])
				else
					@exhibition = @exhibitions.first
				end
			else
				# TODO dddeeerrr
			end
		end
		params[:which] = "genres/#{params[:genre_id]}/artists"
	end

	def groups
#		@groups = UserGroup.all.sort {|x,y| x.title <=> y.title }
#		@artists = []
#		if params[:id]
#			@profile = Profile.find(params[:id])
#		end
#		if params[:group_id]
#			@artists = UserGroup.find(params[:group_id]).users.all(:include => [:profile]).delete_if{ |u| u.exhibitions.published.empty? }.map{ |e| e.profile }.sort {|x,y| x.full_name <=> y.full_name }
#		else
#			@artists = UserGroup.all.rand.users.all(:include => [:profile]).delete_if{ |u| u.exhibitions.published.empty? }.map{ |e| e.profile }.sort {|x,y| x.full_name <=> y.full_name }
#		end
#		@profile ||= @artists.first
#		if @profile
#			params[:group_id] ||= @profile.user.user_groups_users.first.user_group_id
#	  		if @exhibitions=@profile.user.exhibitions.published.uniq#.delete_if{ |e| !e.title.include?('Group Show') })
#				if params[:exhib_id]
#					@exhibition = Exhibition.find(params[:exhib_id])
#				else
#					@exhibition = @exhibitions.first
#				end
#			else
#				# TODO dddeeerrr
#			end
#		end
#		params[:which] = "groups/#{params[:group_id]}/artists"
# here i need to find out the groupshow for last two years that is current year. last year and last to last year
#currently im showing the future groupshow first as default
    @groups = Groupshow.find(:all,:conditions=>["starting_date > '#{Date.civil(Time.now.strftime('%Y').to_i,Time.now.strftime('%m').to_i,Time.now.strftime('%d').to_i)}'"])
   # @groups << Groupshow.find(:all,:conditions=>["starting_date > '#{Date.civil((Time.now.strftime('%Y').to_i-1),Time.now.strftime('%m').to_i,Time.now.strftime('%d').to_i)}'"])
   # @groups << Groupshow.find(:all,:conditions=>["starting_date > '#{Date.civil((Time.now.strftime('%Y').to_i-2),Time.now.strftime('%m').to_i,Time.now.strftime('%d').to_i)}'"])
    if params[:id]
       @groups =   Groupshow.find(:all,:conditions=>["YEAR(starting_date) = ? ",params[:id].to_i])
    end
    p @groups
    p "this is i got because of the year as a id"
    @artists = []
  end
  
  def tojoin
    @groups = UserGroup.all
		@artists = []
		if params[:id]
			@profile = Profile.find(params[:id])
		end
		if params[:group_id]
			@artists = UserGroup.find(params[:group_id]).users.all(:include => [:profile]).delete_if{ |u| u.exhibitions.published.empty? }.map{ |e| e.profile }.sort {|x,y| x.full_name <=> y.full_name }
		else
			@artists = UserGroup.all.rand.users.all(:include => [:profile]).delete_if{ |u| u.exhibitions.published.empty? }.map{ |e| e.profile }.sort {|x,y| x.full_name <=> y.full_name }
		end
		@profile ||= @artists.first
		if @profile
			params[:group_id] ||= @profile.user.user_groups_users.first.user_group_id
			if @exhibitions=@profile.user.exhibitions.published.uniq#.delete_if{ |e| !e.title.include?('Group Show') })
				if params[:exhib_id]
					@exhibition = Exhibition.find(params[:exhib_id])
				else
					@exhibition = @exhibitions.first
				end
			else
				# TODO dddeeerrr
			end
		end
    render 'artists/tojoin'
  end

end

