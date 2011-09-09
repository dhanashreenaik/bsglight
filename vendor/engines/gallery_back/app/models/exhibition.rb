class Exhibition < ActiveRecord::Base

  # Method defined in the ActsAsItem:ModelMethods:ClassMethods (see that library fro more information)
  acts_as_item

	has_one :timing, :as => :objectable, :dependent => :delete
	accepts_nested_attributes_for :timing, :allow_destroy => true #, :reject_if => lambda { |a| a[:starting_date].blank? }
	#has_many :timings, :as => :objectable, :dependent => :destroy
	#accepts_nested_attributes_for :timings, :reject_if => lambda { |a| a[:starting_date].blank? }, :allow_destroy => true

	has_many :exhibitions_users, :dependent => :delete_all
	has_many :users, :through => :exhibitions_users
	has_many :artworks_exhibitions, :dependent => :delete_all
	has_many :artworks, :through => :artworks_exhibitions

	#belongs_to :user

#	named_scope :filtering_state_with, lambda { |state|
#		{ :conditions => { :state => state } }
#	}

	named_scope :current, {
			:select => "DISTINCT exhibitions.*",
			:joins => "LEFT JOIN timings ON timings.objectable_id = exhibitions.id AND timings.objectable_type = 'Exhibition'",
			:conditions => "timings.starting_date <= '#{Time.now.strftime('%Y-%m-%d')}' AND timings.ending_date >= '#{Time.now.strftime('%Y-%m-%d')}'"
	}

	named_scope :future, {
			:select => "DISTINCT exhibitions.*",
			:joins => "LEFT JOIN timings ON timings.objectable_id = exhibitions.id AND timings.objectable_type = 'Exhibition'",
			:conditions => "timings.starting_date > '#{Time.now.strftime('%Y-%m-%d')}'"
	}

	named_scope :past, {
			:select => "DISTINCT exhibitions.*",
			:joins => "LEFT JOIN timings ON timings.objectable_id = exhibitions.id AND timings.objectable_type = 'Exhibition'",
			:conditions => "timings.ending_date < '#{Time.now.strftime('%Y-%m-%d')}'"
	}

  named_scope :next, {
			:select => "DISTINCT exhibitions.*",
			:joins => "LEFT JOIN timings ON timings.objectable_id = exhibitions.id AND timings.objectable_type = 'Exhibition'",
			:conditions => "timings.starting_date > '#{Time.now.strftime('%Y-%m-%d')}' AND timings.ending_date < '#{(Time.now + 2505600).strftime('%Y-%m-%d')}'"
      # 1209600 here this value represent the two weeks in seconds need to be replace by proper date method
	}

	named_scope :published, {
			:select => "DISTINCT exhibitions.*",
			:joins => "LEFT JOIN exhibitions_users AS eu ON eu.exhibition_id = exhibitions.id",
			:conditions => "eu.state = 'published'"
	}

	def artworks_list= params
		self.artwork_ids = params.split(',').uniq
  end

end
