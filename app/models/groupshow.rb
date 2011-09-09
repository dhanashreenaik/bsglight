class Groupshow < ActiveRecord::Base
  has_many :groupshowartworks,:dependent => :delete_all
  has_many :usergroupshow ,:dependent => :delete_all

end
