class Timing < ActiveRecord::Base

	# Polymorphic relation definition
  belongs_to :objectable, :polymorphic => true

	belongs_to :period

#	has_many :timings_places, :as => :objekt
#	has_many :galleries, :through => :timings_places, :source => :objekt, :source_type => 'Gallery', :class_name => 'Gallery'

	named_scope :filtering_state_with, lambda { |state|
		{ :conditions => { :state => state } }
	}

	#named_scope :to_calendar_format,
	
	validates_presence_of :starting_date, :ending_date

	def to_calendar_format_start
		# JSON powa
    
		return {
				:title => self.objectable ? self.objectable.title : "problem with timing #{self.id}",
				:start => self.starting_date,
				#:end => self.ending_date,
				:url => self.objectable ? "/admin/#{self.objectable_type.downcase.pluralize}/#{self.objectable_id}" : '#',
				:className => [ self.objectable_type.downcase ]
			}
	end
  
  def to_calendar_format_end
		# JSON powa
    
		return {
				:title => self.objectable ? self.objectable.title : "problem with timing #{self.id}",
				:start => self.ending_date,
				#:end => self.ending_date,
				:url => self.objectable ? "/admin/#{self.objectable_type.downcase.pluralize}/#{self.objectable_id}" : '#',
				:className => [ self.objectable_type.downcase ]
			}
	end
  
  

	def gallery_ids= param
		self.places_id = param.join(',')
	end

	def galleries
		return (self.places_id.nil? ? [] : self.places_id.split(',').map{ |e| Gallery.find(e) })
	end

	def period_name
		return self.ending_date ? "#{I18n.t('general.common_word.from1')} #{I18n.l(self.starting_date, :format => :long)} "+
			"#{I18n.t('general.common_word.to1')} #{I18n.l(self.ending_date, :format => :long)}" : "Date : #{I18n.l(self.starting_date, :format => :long)}"
	end

	def period_id= param
		per = Period.find(param)
		self.period = per
		self.starting_date = per.starting_date
		self.ending_date = per.ending_date
	end

end
