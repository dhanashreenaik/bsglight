class CompetitionsUser < ActiveRecord::Base

  belongs_to :competitions_subscription
	belongs_to :user
	belongs_to :competition

	has_many :artworks_competitions,:foreign_key=>"competitions_users_id"
	has_many :artworks, :through => :artworks_competitions
	
	has_many :invoices, :as => :purchasable, :dependent => :delete_all

	validates_presence_of :price

  attr_accessible :card_number4
  attr_reader     :card_number4
  attr_writer     :card_number4
  #for competition whenever the payment is done at that time the user is validated and admin will entitled to 
  #select his sartwork. and after payment the invoice is get sent. this case is only for competition.
  #after the image is added the reference  is get added to artwork competition thanks kedar.so when updating
  # 
#	def save_image(competitions_user)
#		image_array = #['fworkimage','sworkimage','tworkimage','foworkimage','fiworkimage','siworkimage','seworkimage','eworkimage','nworkimage','teworkimage']
#		for imagename in image_array
#		if  !competitions_user[imagename].blank?
#				self.save
#				dataname=self.id.to_s+competitions_user[imagename].original_filename
#				name=dataname.split(".")[1]
#				isitimage=name =~ /jpg|jpeg|gif|png/
#					if  isitimage
#						if  imagename == "fworkimage"
#						self.fworkimage = dataname
#						elsif imagename == "sworkimage"
#						self.sworkimage = dataname	
#						elsif imagename == "tworkimage"
#						self.tworkimage = dataname	
#						elsif imagename == "foworkimage"
#						self.foworkimage = dataname	
#						elsif imagename == "fiworkimage"
#						self.fiworkimage = dataname	
#						elsif imagename == "siworkimage"
#						self.siworkimage = dataname	
#						elsif imagename == "seworkimage"
#						self.seworkimage = dataname
#						elsif imagename == "eworkimage"
#						self.eworkimage = dataname			
#						elsif imagename == "nworkimage"
#						self.nworkimage = dataname	
#						elsif imagename == "teworkimage"
#						self.teworkimage = dataname	
#						end
#						directory = "public/system/gallery"
#						# create the file path
#						path = File.join(directory, dataname)
#						# write the file
#						File.open(path, "wb") { |f| f.write(competitions_user[imagename].read) }
#				             #this if else is for when updating the image its state shold be unselected
#	                            if (ArtworksCompetition.find(:first,:conditions=>["competition_id = ? and #image_name = ? and  competitions_users_id = ?",self.competition_id,imagename,self.id]).blank?)
#                                else
#                                	 ac=ArtworksCompetition.find(:first,:conditions=>["competition_id = ? and #image_name = ? and  competitions_users_id = ?",self.competition_id,imagename,self.id])
#                                	 ac.state="unselected"
#                                	 ac.mark=0
#                                	 ac.save                       
#                                end
#                           
#					else
#					end
#			else
#			end#if end		
#		end	#for end
		
		
#	end	
	

#	def save_image(competitions_user)
#		image_array =['1workimage','2workimage','3workimage','4workimage','5workimage','6workimage','7workimage','8workimage','9workimage','10workimage']
#		for imagename in image_array
#		if  !competitions_user[imagename].blank?
#				self.save
#				dataname=self.id.to_s+competitions_user[imagename].original_filename
#				name=dataname.split(".")[1]
#				isitimage=name =~ /jpg|jpeg|gif|png/
#					if  isitimage
#						if  imagename == "1workimage"
#						self.fworkimage = dataname
#						elsif imagename == "2workimage"
#						self.sworkimage = dataname	
#						elsif imagename == "3workimage"
#						self.tworkimage = dataname	
#						elsif imagename == "4workimage"
#						self.foworkimage = dataname	
#						self.fiworkimage = dataname	
#						elsif imagename == "6workimage"
#						self.siworkimage = dataname	
#						elsif imagename == "7workimage"
#						self.seworkimage = dataname
#					elsif imagename == "8workimage"
#						self.eworkimage = dataname			
#				elsif imagename == "9workimage"
#						self.nworkimage = dataname	
#						elsif imagename == "10workimage"
#						self.teworkimage = dataname	
#						end
#						directory = "public/system/gallery"
#						# create the file path
#						path = File.join(directory, dataname)
#						# write the file
#						File.open(path, "wb") { |f| f.write(competitions_user[imagename].read) }
#				             #this if else is for when updating the image its state shold be unselected
#	                            if (ArtworksCompetition.find(:first,:conditions=>["competition_id = ? and image_name = ? and  competitions_users_id = ?",self.competition_id,imagename,self.id]).blank?)
#                                else
#                                	 ac=ArtworksCompetition.find(:first,:conditions=>["competition_id = ? and image_name = ? and  competitions_users_id = ?",self.competition_id,imagename,self.id])
#                                	 ac.state="unselected"
#                                	 ac.mark=0
#                                	 ac.save                       
#                                end
#                           
#					else
#					end
#			else
#			end#if end		
#		end	#for end
#		
#		
#	end	



	def save_image(competitions_user,i)
		image_array =[:fworkimage=,:sworkimage=,:tworkimage=,:foworkimage=,:fiworkimage=,:siworkimage=,:seworkimage=,:eworkimage=,:nworkimage=,:teworkimage=]

		if  !competitions_user["workimage"].blank?
				self.save
				dataname=self.id.to_s+competitions_user["workimage"].original_filename
				name=dataname.split(".")[1]
				isitimage=name =~ /jpg|jpeg|gif|png|JPG|JPEG|GIF|PNG|tiff/
					if  isitimage
						self.send(image_array[i],dataname)
					end
						directory = "public/system/gallery"
						# create the file path
						path = File.join(directory, dataname)
						# write the file
						File.open(path, "wb") { |f| f.write(competitions_user["workimage"].read) }
			             #this if else is for when updating the image its state shold be unselected
	                           if (ArtworksCompetition.find(:first,:conditions=>["competition_id = ? and image_name = ? and  competitions_users_id = ?",self.competition_id,image_array[i].to_s,self.id]).blank?)
                             else
                             	 ac=ArtworksCompetition.find(:first,:conditions=>["competition_id = ? and image_name = ? and  competitions_users_id = ?",self.competition_id,image_array[i].to_s,self.id])
                             	 ac.state="unselected"
                             	 ac.mark=0
                             	 ac.save  
                             end
                           
	else
    
	end
  
	end	















	def find_price(competition_id)
	    compeition = Competition.find(competition_id)
        j=1
        amount=0
	    competition.entry_fees.each do |x|
           amount = amount + x.split("works")[1].split(/\r/)[0].split("$")[1].to_i
           if j ==  self.total_entry.to_i
             break;
             return amount;
           end
           j=j+1
	    end
	  	    return amount 
	end
	
	
	def find_price_total_entry(competition_id,total_entry)
	    compeition = Competition.find(competition_id)
        j=1
        amount=0
	    competition.entry_fees.each do |x|
           amount = amount + x.split("works")[1].split(/\r/)[0].split("$")[1].to_i
           if j ==  total_entry
             break;
             return amount;
           end
           j=j+1
	    end
	    return amount 
	end
	
	
	def generate_invoice(user=nil, invoicing_info={})
	   if (invoice = Invoice.find(:first,:conditions=>["client_id = ? and purchasable_id = ? and purchasable_type = ?",self.user_id,self.id,"CompetitionsUser"]).blank?)
	    		invoice = Invoice.new(
		    		:purchasable_type => self.class.to_s,
		    		:purchasable_id => self.id,
		    		:client_id => self.user_id,
		    		:description => "Invoice for the subscription to the competition '#{self.competition.title}'",
		    		:deadline => Time.now.to_date + 7.days,
		    		:original_amount => find_price(self.competition_id),
		    		:final_amount => find_price(self.competition_id),
		    		:payment_medium => invoicing_info['payment_medium'].to_s ,
		    		:billing_address => self.user.profile.full_address_for_invoice,
		    		:shipping_address =>self.user.profile.full_address_for_invoice,
		    		:state => 'created'
		            )
		        invoice.generate_number
		        invoice.title= "Invoice #{invoice.number}"
		        if invoice.save
		        	return invoice
		        else
	    		end
	    else
	        generate_invoice_update(self.user_id,self.id)
	    end
	end
	
	def generate_invoice_extra_entry(user=nil, invoicing_info={})
	   invoice = Invoice.find(:last,:conditions=>["client_id = ? and purchasable_id = ? and purchasable_type = ?",self.user_id,self.id,"CompetitionsUser"])
	     total_amount = 0
		self.invoices.each {|x| total_amount = total_amount + x.final_amount}
	   more_amount = self.find_price(self.competition_id)  - total_amount
	    		invoice = Invoice.new(
		    		:purchasable_type => self.class.to_s,
		    		:purchasable_id => self.id,
		    		:client_id => self.user_id,
		    		:description => "Invoice for the subscription to the competition '#{self.competition.title}'",
		    		:deadline => Time.now.to_date + 7.days,
		    		:original_amount => more_amount,
		    		:final_amount => more_amount,
		    		:payment_medium => invoicing_info['payment_medium'].to_s ,
		    		:billing_address => self.user.profile.full_address_for_invoice,
		    		:shipping_address =>self.user.profile.full_address_for_invoice,
		    		:state => 'created'
		            )
		        invoice.generate_number
		        invoice.title= "Invoice #{invoice.number}"
		        if invoice.save
		        	return invoice
		        else
	    		end
	
	       
	       
	end
	#whenever user changes his total entry this will automatically get changed. so if user maked down the entry like from 
	#5-2 then this will also get changed
	def  submit_artwork(competitionuser = "",i=0)
    
    if !competitionuser["workimage"].blank?
		image_array = ['fworkimage','sworkimage','tworkimage','foworkimage','fiworkimage','siworkimage','seworkimage','eworkimage','nworkimage','teworkimage']	
 	       for totalentry in 0...self.total_entry.to_i
	            if (ArtworksCompetition.find(:first,:conditions=>["competition_id = ? and image_name = ? and  competitions_users_id = ?",self.competition_id,image_array[totalentry],self.id]).blank?)
                  if !(self.send image_array[totalentry]).blank?
                    ArtworksCompetition.create(:competition_id=>self.competition_id,:image_name=>image_array[totalentry],:competitions_users_id =>self.id,:avatar=>competitionuser["workimage"])
                  end
              else#here i need to update the image
                 artc = ArtworksCompetition.find(:first,:conditions=>["competition_id = ? and image_name = ? and  competitions_users_id = ?",self.competition_id,image_array[i],self.id])
                 if !artc.blank?
                    artc.update_attribute('avatar',competitionuser["workimage"]);
                 else#in else it will come when first time enter into compe user select 10 entry but enter 2 entry so artwork compeition is not created so here it gets created
                    ArtworksCompetition.create(:competition_id=>self.competition_id,:image_name=>image_array[i],:competitions_users_id =>self.id,:avatar=>competitionuser["workimage"])     
                 end   
              end
         end
    end     
    
	end
	    	
	def  generate_invoice_update(competitions_user_user_id,competitions_user_id)
	        invoice = Invoice.find(:first,:conditions=>["client_id = ? and purchasable_id = ? and purchasable_type = ?",competitions_user_user_id,competitions_user_id,"CompetitionsUser"])
	        if invoice
	        invoice.original_amount = find_price(self.competition_id)
			invoice.final_amount = find_price(self.competition_id)	
			invoice.save
      return invoice
			else
			generate_invoice
			end
	end	
  def generate_invoice_with_price()
		invoice = Invoice.new(
				:purchasable_type => self.class.to_s,
				:purchasable_id => self.id,
				:client_id => user.id,
				:description => "Invoice for the subscription to the competition '#{self.competition.title}'",
				:deadline => Time.now.to_date + 7.days,
				:original_amount => self.price,
				:final_amount => self.price,
				:payment_medium => invoicing_info['payment_medium'],
				:billing_address => invoicing_info['billing_address'],
				:shipping_address => invoicing_info['shipping_address'],
				:state => 'created'
		)
		invoice.generate_number
		invoice.title= "Invoice #{invoice.number}"
		if invoice.save
			self.state == 'accepted'
			self.save
			return invoice
		else
			raise invoice.errors.inspect
			raise "Invoice generation problem"
		end
	end

	
	
	def title
		return "Subscription to the competition '#{self.competition.title}'"
	end

end
