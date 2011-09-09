class <%= class_name %> < ActiveRecord::Base

	acts_as_item

  def self.label
    "<%= class_name %>"
  end

end
