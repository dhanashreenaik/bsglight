class Frontendpic < ActiveRecord::Base
   has_attached_file :front_end_pics, :styles => {  :thumb => "100x100>" ,:large=>"600x352"}
                           
                               
end
