class StudioAndMailingList < ActiveRecord::Base

  
 validates_presence_of :first_name,:message=>"Please Enter First Name"
 validates_presence_of :last_name,:message=>"Please Enter Last Name"
 validates_format_of   :email_address,    :with => RE_EMAIL_OK,:message=>"Please Check The Format Of Email" 
 validates_presence_of :address,:message=>"Please Enter Address" 
 validates_presence_of :suburb,:message=>"Please Enter Suburb" 
 validates_presence_of :zip_code,:message=>"Please Enter Zip Code"
 validates_length_of   :phone_number, :in => 7..20, :allow_blank => false,:message=>"Please Enter Valid Phone Number"
end
