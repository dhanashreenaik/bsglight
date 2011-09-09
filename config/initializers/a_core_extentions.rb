module Extentions

	module HashFeatures

				def self.extended(base)
					base.keys.each do |e|
							define_method e do
								base[e]
							end
					end
				end

	end

end

Array.class_eval do
	def sort_with_filter(filter_field, filter_way)
		return self.sort!{|a, b|
        if filter_way == 'asc'
          a.send(filter_field) <=> b.send(filter_field)
        else
          b.send(filter_field) <=> a.send(filter_field)
        end
      }
	end
end

[Role, Permission].each { |e| e.class_eval do
		def self.create_if_not_there(*args)
			if !self.exists?(*args)
				self.create(*args)
			end
		end
	end
}

#module Paperclip
#  class Attachment
#    def width(style = default_style)
#      Paperclip::Geometry.from_file(to_file(style)).width
#    end
#
#    def height(style = default_style)
#      Paperclip::Geometry.from_file(to_file(style)).height
#    end
#  end
#end