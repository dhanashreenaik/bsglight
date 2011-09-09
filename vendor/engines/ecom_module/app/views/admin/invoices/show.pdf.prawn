pdf.font "Helvetica"
#pdf.font.size = 12

pdf.text "Invoice : #{@current_object.title}", :size => 14, :style => :bold, :spacing => 8
pdf.text "Client : #{@current_object.client.profile.full_name}", :spacing => 12
pdf.text "Description : #{@current_object.description}", :spacing => 12
pdf.text "Amount : #{@current_object.final_amount.to_s} AUD", :spacing => 12
