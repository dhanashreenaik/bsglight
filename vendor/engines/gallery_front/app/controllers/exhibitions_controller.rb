class ExhibitionsController < ApplicationController

	layout 'front'

  def current
  	do_the_job_for(:current)
    do_the_job_for_groupshow_current(:current)
    #do_the_job_for_competition_current(:current)
 	end

	def past
		do_the_job_for(:past)
	end

	def future
    do_the_job_for(:future)
    do_the_job_for_groupshow_future(:future)
	end

	def next
    do_the_job_for(:next)
    do_the_job_for_groupshow_next(:next)
    #do_the_job_for_competition_next(:next)
	end

#	def submit_form
#
#	end
#
#	def submit_works
#		params[:submission]
#	end


	private

	def do_the_job_for(which)
		@artists = []
    exhibitions=Exhibition.send(which)

  
    if !(exhibitions=Exhibition.send(which)).empty? && !(@artists=ExhibitionsUser.all(:include => [:user => [:profile]], :conditions => { :exhibition_id => exhibitions.map{|e| e.id}, :state => 'published'}).map{ |e| e.user.profile}.uniq.sort {|x,y| x.full_name <=> y.full_name } ).empty?
			#raise @current_exposing_artists.map{ |e| e.id }.inspect
			#raise @artists.inspect
			if params[:id]
				@profile = Profile.find(params[:id])
			else
				@profile = @artists.rand
			end
			@exhibitions = @profile.user.exhibitions.send(which).uniq
			if params[:exhib_id]
				@exhibition = Exhibition.find(params[:exhib_id])
			else
				@exhibition = @exhibitions.rand
			end
    else
    end
   
    @artists.uniq!
     params[:which] = "#{which.to_s}/artists"
    # respond_to do |format|
    #       format.html { render :template => 'exhibitions/show.html.erb' }
    # end
	end
  
  def do_the_job_for_groupshow_current(which)
      currentgroupshow = Groupshow.find(:all,:conditions=>["starting_date <= '#{Time.now.strftime('%Y-%m-%d')}' and ending_date >= '#{Time.now.strftime('%Y-%m-%d')}'"])
      @groupshowartworks = []
      currentgroupshow.each do |cgs|
        cgs.groupshowartworks.each  do |gsa|
            @groupshowartworks << gsa
            @artists<<gsa.user.profile
        end
      end
       @artists.uniq!
       if @profile.blank? 
         @profile = @artists.rand
       end
     params[:which] = "#{which.to_s}/artists"
     respond_to do |format|
           format.html { render :template => 'exhibitions/show.html.erb' }
     end
  end
  def do_the_job_for_competition_current(which)
      competition = Competition.find(:all,:conditions=>["state = 'open'"])
      @competitionuser = []
      competition.each do |cp|
        @competitionuser << CompetitionsUser.find(:all,:conditions=>["competition_id = #{cp.id}"])
      end
      @competitionuser.flatten!
      @competitionuser.each do |cu|
        @artists << cu.user.profile
      end
      @artists.uniq!
      if @profile.blank? 
        @profile = @artists.rand
      end
       params[:which] = "#{which.to_s}/artists"
        respond_to do |format|
            format.html { render :template => 'exhibitions/show.html.erb' }
        end
  end
  
  def do_the_job_for_groupshow_future(which)
         currentgroupshow = Groupshow.find(:all,:conditions=>["starting_date >= '#{Time.now.strftime('%Y-%m-%d')}'"])
        @groupshowartworks = []
         currentgroupshow.each do |cgs|
            cgs.groupshowartworks.each  do |gsa|
              @groupshowartworks << gsa
              @artists<<gsa.user.profile
            end
         end
        @artists.uniq!
        if @profile.blank? 
            @profile = @artists.rand
        end
        params[:which] = "#{which.to_s}/artists"
        respond_to do |format|
            format.html { render :template => 'exhibitions/show.html.erb' }
        end
  end
  
  def do_the_job_for_groupshow_next(which)
         currentgroupshow = Groupshow.find(:all,:conditions=>["starting_date >= '#{Time.now.strftime('%Y-%m-%d')}' and  ending_date < '#{(Time.now + 2505600).strftime('%Y-%m-%d')}' "])
         @groupshowartworks = []
         currentgroupshow.each do |cgs|
            cgs.groupshowartworks.each  do |gsa|
              @groupshowartworks << gsa
              @artists<<gsa.user.profile
            end
         end
     @artists.uniq!
     params[:which] = "#{which.to_s}/artists"
     respond_to do |format|
           format.html { render :template => 'exhibitions/show.html.erb' }
     end
  end
  
  def do_the_job_for_competition_next(which)
    if @profile.blank? 
      @profile = @artists.rand
    end
    @artists.uniq!
        params[:which] = "#{which.to_s}/artists"
        respond_to do |format|
            format.html { render :template => 'exhibitions/show.html.erb' }
        end
  end


end
