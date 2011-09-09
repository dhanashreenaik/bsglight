require 'file_path_utils'

namespace :gallery do

	desc "Install"
	task :install => :environment do
		p "Gallery bootstrap"
		Rake::Task['gallery:db:bootstrap'].invoke
		p "Populate database with gallery test data y/n"
		if STDIN.gets.chomp == 'y'
			Rake::Task['gallery:seed'].invoke
			Rake::Task['gallery:give_reader_role_to_artists'].invoke
			Rake::Task['gallery:load_artworks_images'].invoke
		end
	end

	namespace :db do

		desc "Init database"
		task :bootstrap => :environment do
			p "Bootstrap for Gallery application ..."
			u = User.find(:first, :conditions => { :system_role_id => 2 })
			w = Workspace.new(:creator_id => u.id, :title => "Public data", :description => 'Here are all the data shared by the administrator, the competitions for example.', :state => 'public', :available_items => ['competition', 'exhibition', 'gallery', 'users_group'])
			w.save ? (p "Public data workspace created") :	(p "Error creating public data workspace")
			UsersContainer.create(:user_id => u.id, :containerable_type => 'Workspace', :containerable_id => w.id, :role_id => Role.find_by_name('co_admin').id)
			# Artist system role
			r1 = Role.new(:name => 'artist', :description => 'Permissions for an artist.',	:type_role => 'system')
			r1.save ? (p "Role artist created") :	(p "Error creating role artist")
			# Judge system role
			r2 = Role.new(:name => 'judge', :description => 'Permissions for an judge.',	:type_role => 'system')
			r2.save ? (p "Role judge created") :	(p "Error creating judge artist")
			# Competitor system role
			r4 = Role.new(:name => 'competitor', :description => 'Permissions for a competitior.',	:type_role => 'system')
			r4.save ? (p "Role competitor created") :	(p "Error creating role competitor")
			# private_user workspace role
			r3 = Role.new(:name => 'private_user', :description => 'Permissions for an private user.',	:type_role => 'workspace')
			r3.save ? (p "Role Private User created") :	(p "Error creating Private User role")

			p1 = Permission.new(:name => 'competition_subscribe', :description => 'Permission to subscribe to a comptetition', :type_permission => 'container')
			p1.save ? (p "Permission competition_subscribe created") :	(p "Error creating permission competition_subscribe")
			p2 = Permission.new(:name => 'artwork_evaluate', :description => 'Permission to evaluate an artwork', :type_permission => 'container')
			p2.save ? (p "Permission artwork_evaluate created") :	(p "Error creating permission artwork_evaluate")

			r1.permissions << Permission.find_by_name("competition_show")
			r1.permissions << Permission.find_by_name("exhibition_show")
			r1.permissions << Permission.find_by_name("gallery_show")
			r1.permissions << Permission.find_by_name('user_group_show')
			r1.permissions << p1
			r1.save

			r4.permissions << Permission.find_by_name("competition_show")
			r4.save

			r2.permissions << Permission.find_by_name("competition_show")
			#r2.permissions << Permission.find_by_name("exhibition_show")
			#r2.permissions << Permission.find_by_name("gallery_show")
			r2.permissions << Permission.find_by_name('artwork_show')
			#r2.permissions << Permission.find_by_name('user_group_show')
			r2.permissions << p2
			r2.save

			r3.permissions << Permission.find_by_name("workspace_show")
			r3.permissions << Permission.find_by_name("artwork_show")
			r3.permissions << Permission.find_by_name("artwork_new")
			r3.permissions << Permission.find_by_name("artwork_edit")
			r3.permissions << Permission.find_by_name("artwork_destroy")
			r3.save

			admin_role = Role.find_by_name('admin')
			admin_role.permissions << p1
			admin_role.permissions << p2
			admin_role.save

			Category.create(:name => 'Newsletter subscribers')

			p "done !"
		end
	end

	desc "This loads the development data."
	task :seed => :environment do

		require 'populator'
		require 'faker'

		@ws_public = Workspace.find(:first, :conditions => { :state => 'public' })
		@admin = User.find(:first, :conditions => { :system_role_id => 2 })
		@artist_role = Role.find_by_name('artist')
		@ws_admin_role = Role.find_by_name('private_user')

		p "Creating periods ..."
		base = (Time.now - 3.months).to_date
		for i in (1..20)
			Period.create(:starting_date => base, :ending_date => base+14.days)
			base = base+15.days
		end
		p "done !!!"

		p "Creating categories and Group Shows ..."
		Category.create(:name => 'Photographer')
		Category.create(:name => 'Painter')
		Category.create(:name => 'Drawer')
		UserGroup.create(:title => 'Photographer 10a', :user_id => @admin.id, :workspace_ids => [@ws_public.id, @admin.private_workspace.id])
		UserGroup.create(:title => 'Painter 10a', :user_id => @admin.id, :workspace_ids => [@ws_public.id, @admin.private_workspace.id])
		UserGroup.create(:title => 'Drawer 10a', :user_id => @admin.id, :workspace_ids => [@ws_public.id, @admin.private_workspace.id])

		p "Populating the database with gallery data ..."
		Gallery.populate 8 do |gallery|
			gallery.user_id = @admin.id
			gallery.title = "Gallery #{gallery.id} : " + Faker::Lorem.sentence(5)
			gallery.description = Faker::Lorem.sentence(15)
			gallery.price = [1000, 750, 950, 1100, 1500].rand
			ItemsWorkspace.populate 1 do |iws|
				iws.itemable_type = 'Gallery'
				iws.itemable_id = gallery.id
				iws.workspace_id = @ws_public.id
			end
		end

		Competition.populate 2 do |competition|
			competition.user_id = @admin.id
			competition.title = Faker::Lorem.sentence(5)
			competition.description = Faker::Lorem.sentence(15)
			competition.state = 'open'
			competition.submission_deadline = Time.now.to_date+7.days
			Timing.populate 1 do |t|
				t.objectable_type = 'Competition'
				t.objectable_id = competition.id
				t.note = Faker::Lorem.sentence(15)
				t.starting_date = Time.now.to_date+[-2, -1].rand.months
				t.ending_date = t.starting_date+[1,2,3].rand.months
				t.places_id = Gallery.all.rand.id.to_s
			end
			ItemsWorkspace.populate 1 do |iw|
				iw.itemable_type = 'Competition'
				iw.itemable_id = competition.id
				iw.workspace_id = @ws_public.id
			end
			CompetitionsSubscription.populate 3 do |cs|
				cs.competition_id = competition.id
				cs.maximum_works_number = 4
				cs.description = Faker::Lorem.sentence(5)
				cs.price = 50
			end
			CompetitionsSubscription.populate 1 do |cs|
				cs.competition_id = competition.id
				cs.maximum_works_number = 3
				cs.description = Faker::Lorem.sentence(5)
				cs.price = 70
			end
		end

		# Exhibitions creation
		Exhibition.populate 12..14 do |exhibition|
			exhibition.user_id = @admin.id
			exhibition.title = Faker::Lorem.sentence(5)
			exhibition.description = Faker::Lorem.sentence(15)
			# Linking item to container
			ItemsWorkspace.populate 1 do |iw|
				iw.itemable_type = 'Exhibition'
				iw.itemable_id = exhibition.id
				iw.workspace_id = @ws_public.id
			end
			Timing.populate 1 do |t|
				t.objectable_type = 'Exhibition'
				t.objectable_id = exhibition.id
				t.note = Faker::Lorem.sentence(15)
				p = Period.all.rand
				t.period_id = p.id
				t.starting_date = p.starting_date
				t.ending_date = p.ending_date
				t.places_id = Gallery.all.rand.id.to_s
			end
		end

		User.populate 20 do |user|
			user.login = Faker::Internet.user_name
			user.email = Faker::Internet.email
			user.crypted_password = "a2c297302eb67e8f981a0f9bfae0e45e4d0e4317"
			user.salt = "356a192b7913b04c54574d18c28d46e6395428ab"
			user.activated_at = Time.now
			user.system_role_id = @artist_role.id
			# Profile creation
			Profile.populate 1 do |profile|
				profile.first_name = Faker::Name.first_name
				profile.last_name = Faker::Name.last_name
				profile.address = Faker::Address.street_address
				profile.zip_code = Faker::Address.zip_code
				profile.city = Faker::Address.city
				profile.country = ['Australia', 'USA', 'France', 'India'].rand
				profile.phone_number = '+00 912323232399'
				profile.website = 'http://www.'+Faker::Internet.domain_name
				profile.biography = Faker::Lorem.paragraph(10)
				profile.email_address = user.email
				profile.getting_newsletter = [true, false].rand
				profile.user_id = user.id
				ProfilesCategory.populate 1 do |procat|
					procat.profile_id = profile.id
					procat.category_id = Category.all.rand.id
				end
			end
			
			# Public container creation
			Workspace.populate 1 do |container|
				container.creator_id = user.id
				container.title = "workspace"
				container.description = Faker::Lorem.sentence(15)
				container.state = 'private'
				container.available_items = 'artwork,submited_work'
				UsersContainer.populate 1 do |cu|
					cu.containerable_type = "Workspace"
					cu.containerable_id = container.id
					cu.user_id = user.id
					cu.role_id = @ws_admin_role.id
				end
				# Artworks creation
				Artwork.populate 5..12 do |artwork|
					artwork.user_id = user.id
					artwork.title = Faker::Lorem.sentence(5)
					artwork.description = Faker::Lorem.sentence(15)
					artwork.edition_name = Faker::Lorem.words(2)
					artwork.edition_number = [1,2,3,10,50].rand
					artwork.medium = Faker::Lorem.words(3)
					artwork.width = [20,30,40].rand
					artwork.height = [20,30,40].rand
					artwork.depth = [20,30,40,nil,nil].rand
					artwork.price = [100,150,200,250,350,400,550,600,850,1000,1100].rand
					# Linking item to container
					ItemsWorkspace.populate 1 do |iw|
						iw.itemable_type = 'Artwork'
						iw.itemable_id = artwork.id
						iw.workspace_id = container.id
					end
				end
			end

		end

		User.all(:conditions => { :system_role_id => @artist_role.id }) do |u|
			ws = Workspace.find(:conditions => { :creator_id => u.id, :state => 'private' })
			ws.title = "#{u.profile.full_name} workspace"
			ws.save
		end

		User.all.delete_if{ |e| e.id==1 || e.id==2 }.each do |u|

			ExhibitionsUser.populate 4 do |exhib|
				exhib.user_id = u.id
				exh_id = Exhibition.all.rand.id
				exhib.exhibition_id = exh_id
				exhib.state = ['invited', 'accepted', 'validated', 'published', 'published'].rand
				exhib.price = [50, 60, 70, 80].rand
				if u.private_workspace.artworks.first
					ArtworksExhibition.populate 2 do |ae|
						ae.artwork_id = u.private_workspace.artworks.rand.id
						ae.exhibition_id = exh_id
					end
				end
			end
			CompetitionsUser.populate 2 do |comp_sub|
				comp_sub.user_id = u.id
				comsub = CompetitionsSubscription.all.rand
				comp_sub.competition_id = comsub.competition_id
				comp_sub.competitions_subscription_id = comsub.id
				comp_sub.state = ['accepted', 'validated', 'validated'].rand
				comp_sub.price = [50, 60, 70, 80].rand
				if u.private_workspace.artworks.first
					ArtworksCompetition.populate 2 do |ac|
						ac.artwork_id = u.private_workspace.artworks.rand.id
						ac.competition_id = comsub.competition_id
					end
				end
			end
			u.user_groups << UserGroup.all.rand
			u.save

		end

	end

	desc 'Load images for Artwork (medium, for front)'
	task :load_artworks_images => :environment do
		p "Updating image for each artwork ..."
		Artwork.all.each do |artwork|
			if true || artwork.image_file_name.nil?
				file = Dir.glob("test/fixtures_gallery/*.jpeg").rand
				artwork.image_file_name = file_path_import(:model => 'artwork', :id => artwork.id, :file_name => file)
				#raise artwork.image_file_name
				artwork.image_content_type = 'image/jpeg'
				artwork.image_file_size = File.size("#{RAILS_ROOT}/#{file}")
				if artwork.save
					#p "Image updated on Artwork#{artwork.id}"
				else
					p "Error updating image on Artwork #{artwork.id}"
					raise artwork.errors.inspect
				end
			end
		end
		p "done !"
	end

	desc "Give to all artists Reader role inside Public workspace"
	task :give_reader_role_to_artists => :environment do
		p "Linking all artists with Reader role to Public workspace ..."
		ws_public = Workspace.find(:first, :conditions => { :state => 'public' })
		reader_role = Role.find_by_name('reader')
		artist_role = Role.find_by_name('artist')
		User.find(:all, :conditions => { :system_role_id => artist_role.id}).each do |u|
			UsersContainer.create(:containerable_id => ws_public.id, :containerable_type => 'Workspace', :user_id => u.id, :role_id => reader_role.id)
			u.profile.add_to_admin_contacts
		end
		p "done !"
	end

	desc "This drops the db, builds the db, and seeds the data."
	task :reseed => [:environment, 'db:reset', 'db:seed'] do
	end

end
