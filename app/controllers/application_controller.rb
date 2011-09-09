class ApplicationController < ActionController::Base

	# Configuration
  include BlankConfiguration
  # Library used by the 'restful_authentcation' (and providing 'current_user' method)
	include AuthenticatedSystem
  # Captcha Management
	include YacaphHelper
	# Mixin used to specify the controller you want to manage with ExceptionNotification (all the controllers here)
	include ExceptionNotifiable if BlankConfiguration::ConfigFile.open('sa_config.yml').hash['sa_exception_notifier_activated'] == 'true'

  before_filter :get_configuration
	
	helper :yacaph, :websites

	# Filter checking authentication with 'is_logged' method
  before_filter :logged_in?






def create_pdf(invoice_id="",invoice_number="",invoice_date="",invoice_full_address = " " ,invoice_user_fullname = " " ,invoice_competition_title="",invoice_full_amount="",note="",amount_due="",paid="",exhibitionpdf=false,finish_date=Time.now.strftime("%d %b %Y"),deposit_required="")#{invoice.sent_at.strftime("%d %b %Y")}   #{invoice.user.profile.full_address}
				
				       headers, body = nil, nil  
               dir = File.expand_path(File.dirname(__FILE__))
               Prawn::Document.generate("#{RAILS_ROOT}/public/pdf_invoice/#{invoice_id}invoice.pdf", :page_layout => :landscape) do
               bsg = "#{RAILS_ROOT}/public/images/bsgpdf.png"  
               image bsg, :at => [10,540] ,:width=>100,:height=>100
               invoice = "#{RAILS_ROOT}/public/images/invoice.png"  
               image invoice, :at => [384,530] 
               box = Prawn::Text::Box.new("INVOICE NO:",:width=>80,:height=>20,:overflow=>:ellipses,:at=>[450, 490],:align=>:left,:document=>self,:style=>:bold)
               box.render
               number = invoice_number
               box = Prawn::Text::Box.new(number,:width   => 80,:height   => 20, :overflow => :ellipses, :at => [530, 490], :align    => :left, :document => self)
               box.render
               box = Prawn::Text::Box.new("DATE:",    :width    => 80,:height   => 20, :overflow => :ellipses, :at => [485, 475], :align    => :left, :document => self,:style=>:bold)
               box.render
               box = Prawn::Text::Box.new("#{invoice_date}",    :width    => 80,:height   => 20, :overflow => :ellipses, :at => [525, 475], :align    => :left, :document => self)
               box.render
               box = Prawn::Text::Box.new("Brunswick Street Gallery 322 Brunswick St,Fitzroy 0419 390 478 mark@bsgart.com.au www.bsgart.com.au ",    :width    => 140,:height   => 100, :overflow => :ellipses, :at => [10, 390], :align    => :left, :document => self)
               box.render
               box = Prawn::Text::Box.new("ABN:  35 108 985 002",    :width    => 140,:height   => 20, :overflow => :ellipses, :at => [10, 315], :align    => :left, :document => self)
               box.render
               box = Prawn::Text::Box.new("Bill To :-",    :width    => 130,:height   => 100, :overflow => :ellipses, :at => [250, 380], :align    => :left,:style=>:bold, :document => self)
               fill_color("80b2ff")
               box.render
               
               box = Prawn::Text::Box.new("#{invoice_user_fullname},",    :width    => 130,:height   => 100, :overflow => :ellipses, :at => [250, 365], :align    => :left, :document => self)
               fill_color("000000")
               box.render
               
               box = Prawn::Text::Box.new("#{invoice_full_address}",    :width    => 130,:height   => 100, :overflow => :ellipses, :at => [250, 350], :align    => :left, :document => self)
               fill_color("000000")
               box.render
               
               box = Prawn::Text::Box.new("Ship To :-",    :width    => 130,:height   => 100, :overflow => :ellipses, :at => [400, 380], :align    => :left,:style=>:bold ,:document => self)
               fill_color("80b2ff")
               box.render
               
               
               box = Prawn::Text::Box.new("#{invoice_user_fullname},",    :width    => 130,:height   => 100, :overflow => :ellipses, :at => [400, 366], :align    => :left, :document => self)
               fill_color("000000")
               box.render
               
               box = Prawn::Text::Box.new("#{invoice_full_address}",    :width    => 130,:height   => 100, :overflow => :ellipses, :at => [400, 350], :align    => :left, :document => self)
               fill_color("000000")
               box.render
               
               move_down 250
               if exhibitionpdf
                 
                 if deposit_required.blank?  
                   table [["#{invoice_competition_title}","#{invoice_date}", "#{finish_date}","$#{invoice_full_amount}"],
                        ],
                      :position => :left,
                      :style => :bold,
                      :headers => ['Description', 'Start Date', 'End Date', 'Price'],
                      :column_widths => { 0 => 330, 1 => 120, 2 => 120, 3 => 50},
                      :border=>:none,
                      :border_width       => 0,
                      :header_color => '0147FA',
                      :header_text_color  => "ffffff"
                 else
                   table [["#{invoice_competition_title}","#{invoice_date}", "#{finish_date}","$#{invoice_full_amount}"],
                        ["","", "Deposit Required  $#{deposit_required}",""],],
                      :position => :left,
                      :style => :bold,
                      :headers => ['Description', 'Start Date', 'End Date', 'Price'],
                      :column_widths => { 0 => 330, 1 => 120, 2 => 120, 3 => 50},
                      :border=>:none,
                      :border_width       => 0,
                      :header_color => '0147FA',
                      :header_text_color  => "ffffff"
                 end  
               else
                 
                 table [["#{invoice_competition_title}","#{invoice_date}","#{finish_date}" ,"$#{invoice_full_amount}"],],
                      :position => :left,
                      :style => :bold,
                      :headers => ['Description', 'Start Date', 'End Date', 'Price'],
                      :column_widths => { 0 => 330, 1 => 120, 2 => 120, 3 => 50},
                      :border=>:none,
                      :border_width       => 0,
                      :header_color => '0147FA',
                      :header_text_color  => "ffffff"
               end
               
            fill_color("e6f0ff")
            #fill_and_stroke_rectangle([8,-11],440,21)
            #fill_and_stroke_rectangle([8,14],440,18)
            #box = Prawn::Text::Box.new("Notes:",    :width    => 600,:height   => 100, :overflow => :ellipses, :at => [20, 20], :align    => :left, :document => self,:style=>:bold)
            #fill_color("000000")
            #box.render
            #fill_color("ffffff")
            
            box = Prawn::Text::Box.new("#{note}",:width=>420,:height=>17,:overflow=>:shrink_to_fit,:at=>[10, 10],:align=>:left,:document => self)
            fill_color("000000")
            box.render
            
            #box = Prawn::Text::Box.new("PAYMENT CAN BE MADE:",:width=>300,:height=>50,:overflow=>:ellipses,:at=>[10,178],:align=> :left, :document => self,:style=>:bold)
            #fill_color("000000")
            #box.render
            box = Prawn::Text::Box.new("Payment can be made online at http://173.230.149.35/login, paypal account mark@bsgart.com.au, or by direct debit to BSG, CBA, BSB 063 212  Account No 1017 2051 with your name on the transaction.",:width=>425,:height=>30,:overflow=>:shrink_to_fit,:at=>[10,-13],:align=> :left, :document => self)
            fill_color("000000")
            box.render
            fill_color("0147FA")
            stroke_color("0147FA")
            fill_and_stroke_rectangle([460,65],140,20)
            box = Prawn::Text::Box.new("TOTAL",:width => 50,:height=> 13,:overflow => :ellipses, :at => [462, 60],:align => :left, :document => self)
            fill_color("ffffff")
            box.render
            box = Prawn::Text::Box.new("$#{invoice_full_amount}",:width => 100,:height => 13, :overflow => :ellipses, :at => [495, 60], :align => :right,:document => self)
            fill_color("ffffff")
            box.render
            fill_color("0147FA")
            fill_and_stroke_rectangle([460,40],140,20)
            box = Prawn::Text::Box.new("GST (inc)",:width => 80,:height => 13, :overflow => :ellipses, :at => [462, 35], :align    => :left, :document => self)
            fill_color("ffffff")
            box.render
            fill_color("0147FA")
            box = Prawn::Text::Box.new("$#{(invoice_full_amount*10/100).to_i}", :width => 100,:height => 13, :overflow => :ellipses, :at => [495, 35], :align => :right, :document => self)
            fill_color("ffffff")
            box.render
            fill_color("0147FA")
            fill_and_stroke_rectangle([460,15],140,20)
            box = Prawn::Text::Box.new("PAID", :width => 50,:height => 13, :overflow => :ellipses, :at => [462, 13], :align => :left, :document => self)
            fill_color("ffffff")
            box.render
            fill_color("0147FA")
            if paid.blank?
              box = Prawn::Text::Box.new("$#{invoice_full_amount}", :width => 100,:height => 13, :overflow => :ellipses, :at => [495, 13], :align => :right, :document => self)
            else
              box = Prawn::Text::Box.new("$#{paid}", :width => 100,:height => 13, :overflow => :ellipses, :at => [495, 13], :align => :right, :document => self)
            end
            
            fill_color("ffffff")
            box.render
            fill_color("0147FA")
            
            fill_and_stroke_rectangle([460,-10],140,20)
            box = Prawn::Text::Box.new("AMOUNT DUE", :width => 100,:height => 13, :overflow => :ellipses, :at => [462, -13], :align => :left, :document => self)
            fill_color("ffffff")
            box.render
            fill_color("0147FA")
            if amount_due.blank?
             box = Prawn::Text::Box.new("$#{invoice_full_amount.to_i - invoice_full_amount}",:width => 60,:height => 13, :overflow => :ellipses, :at => [535, -13], :align => :right, :document => self)
            else  
             box = Prawn::Text::Box.new("$#{amount_due}",:width => 60,:height => 13, :overflow => :ellipses, :at => [535, -13], :align => :right, :document => self)
            end
            
            fill_color("ffffff")
            box.render
            fill_color("0147FA")
              
              
           #fill_and_stroke_rectangle([490,42],120,13)
           # box = Prawn::Text::Box.new("GST:#{(invoice_full_amount*10/100).to_i}",    :width    => 220,:height   => 13, :overflow => :shrink_to_fit, :at => [490, 25], :align    => :left, :document => self)
           # fill_color("ffffff")
           # box.render
           # fill_color("0147FA")
           # fill_and_stroke_rectangle([490,26],120,13)
          end#do end
          logger.info "the pdf is get generated #{invoice_id}"
end	#method end


end

