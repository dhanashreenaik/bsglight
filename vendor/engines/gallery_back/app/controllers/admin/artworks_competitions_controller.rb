class Admin::ArtworksCompetitionsController < Admin::ApplicationController

	def update_state
   	@artworks_competition = ArtworksCompetition.find(params[:id])
		@artworks_competition.state = params[:state]
    if params[:state] == "winner"
      @artworks_competition.prize_detail = "winner of #{@artworks_competition.competition.title}"
    end
		@artworks_competition.save
		#redirect_to item_path(@artworks_competition.competition)
    #QueuedMail.add('UserMailer', 'artwork_status',[@artworks_competition,@artworks_competition.competitions_user.user], 0, send_now=true)	

		
		if request.xhr?
      render :nothing=>true
    else
      redirect_to :back
    end
	end

	def set_marks
		ac = nil
		params[:marks_list].delete_if{ |k,v| v.nil? }.each do |k, v|
			ac = ArtworksCompetition.find(k)
			ac.mark = v
			ac.save
		end
		redirect_to item_path(ac.competition)
	end

end
