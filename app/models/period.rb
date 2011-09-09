class Period < ActiveRecord::Base

	has_many :timings
	validates_presence_of :starting_date, :ending_date

	named_scope :retrieving_actual_period, lambda {
		{ :conditions => "timings.starting_date <= '#{Time.now.strftime('%Y-%m-%d')}' AND timings.ending_date >= '#{Time.now.strftime('%Y-%m-%d')}'" }
	}

	def name
		return "#{I18n.t('general.common_word.from1')} #{I18n.l(self.starting_date, :format => :long)} "+
			"#{I18n.t('general.common_word.to1')} #{I18n.l(self.ending_date, :format => :long)}"
	end

	def short_name
		return "#{I18n.l(self.starting_date, :format => :short)} - #{I18n.l(self.ending_date, :format => :short)}"
	end

	def is_current_period?
		return self.starting_date <= Time.now.to_date && self.ending_date >= Time.now.to_date
	end

end
