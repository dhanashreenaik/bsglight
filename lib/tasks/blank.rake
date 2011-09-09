namespace :blank do

  desc "Install Blank Application"
	task :install => :environment do
    p "Installing required gems"
    Rake::Task['gems:install'].invoke
    p "Creating Database"
		Rake::Task['db:create'].invoke
    p "Migrating"
		Rake::Task['db:migrate'].invoke
    p "Setting Up Default Settings"
		Rake::Task['blank:pump'].invoke
#    p "Setting Other Settings"
#    Rake::Task['blank:init'].invoke
	end

	desc "Initialize Blank Application"
	task :init => :environment do
		system("rake captcha:generate COUNT=10")
		#Rake::Task['captcha:generate'].invoke
    p "Starting Delayed_Job"
    system("ruby script/delayed_job start")
    p "Creating Cron Schedules"
    system("whenever --update-crontab blank -s environment=#{RAILS_ENV}")
    Rake::Task['blank:xapian_rebuild'].invoke
    p "Installed Blank Application Sucessfully."
	end

	desc "Initializing Blank Engine"
	task :update => :environment do
		Rake::Task['gems:install'].invoke
		Rake::Task['db:migrate'].invoke
		Rake::Task['blank:xapian_rebuild'].invoke
	end

	desc "Building Xapian indexes"
	task :xapian_rebuild => :environment do
		p "Building Xapian indexes"
		system("rake xapian:rebuild_index models='#{ITEMS.map{ |e| e.camelize }.join(' ')} User #{CONTAINERS.map{ |e| e.camelize }.join(' ')}' RAILS_ENV=#{RAILS_ENV}")
		p "Done"
	end

  desc "Create Basic Settings for BLANK"
  task(:pump => :environment) do
		Rake::Task['blank:create_roles'].invoke
    Rake::Task['blank:create_permissions'].invoke
		Rake::Task['blank:load_permissions'].invoke
    Rake::Task['blank:create_users'].invoke
    Rake::Task['blank:create_workspaces'].invoke
    #Rake::Task['blank:css'].invoke
    p "Populate database with test data y/n"
    if STDIN.gets.chomp == 'y'
      Rake::Task['db:populate'].invoke
    end
  end

	desc "From drop to pump"
	task(:pumper => :environment) do
		Rake::Task['db:drop'].invoke
		Rake::Task['db:create'].invoke
		Rake::Task['db:migrate'].invoke
		Rake::Task['blank:pump'].invoke
	end

	### Pump subtasks

  desc "Creating roles"
  task(:create_roles => :environment) do
    p "Creating roles ..."
    Role.create_if_not_there(:name =>'superadmin', :description => 'SuperAdministration', :type_role =>'system') if !Role.exists?(:name => 'superadmin')
    Role.create_if_not_there(:name =>'admin', :description => 'Administration', :type_role =>'system') if !Role.exists?(:name => 'admin')
		Role.create_if_not_there(:name =>'user', :description => 'User', :type_role =>'system') if !Role.exists?(:name => 'user')
    Role.create_if_not_there(:name =>'co_admin', :description => 'Container Administrator', :type_role =>'container')if !Role.exists?(:name => 'co_admin')
    Role.create_if_not_there(:name =>'moderator', :description => 'Container Moderator', :type_role =>'container')if !Role.exists?(:name => 'moderator')
    Role.create_if_not_there(:name =>'writer', :description => 'Container Writer', :type_role =>'container')if !Role.exists?(:name => 'writer')
    Role.create_if_not_there(:name =>'reader', :description => 'Container Reader', :type_role =>'container')if !Role.exists?(:name => 'reader')
    p "Done"
	end

	desc "Create permissions"
  task(:create_permissions => :environment) do
    p "Creating permissions ..."
    (['users'] + ITEMS + CONTAINERS).each do |controller|
      ['new','edit', 'show', 'destroy'].each do |action|
        if controller=="users"
          if action == "show" || action == "index"
            Permission.create_if_not_there(:name => controller.singularize + '_' + action,  :type_permission =>'container')
          else
            Permission.create_if_not_there(:name => controller.singularize + '_' + action,  :type_permission =>'system')
          end
        elsif CONTAINERS.include?(controller)
          if action == "new" || action == "index"
            Permission.create_if_not_there(:name => controller.singularize + '_' + action,  :type_permission =>'system')
          else
            Permission.create_if_not_there(:name => controller.singularize + '_' + action,  :type_permission =>'container')
          end
        else
          Permission.create_if_not_there(:name => controller.singularize + '_' + action,  :type_permission =>'container')
        end
      end
    end
    ITEMS.each do |controller|
      ['comment', 'rate', 'tag'].each do |action|
        Permission.create_if_not_there(:name => controller.singularize + '_' + action, :type_permission => 'container')
      end
    end
		CONTAINERS.each do |controller|
			Permission.create_if_not_there(:name => "#{controller}_administrate", :type_permission => 'container')
		end
		Permission.create_if_not_there(:name => 'user_configure', :type_permission => 'system')
		Permission.create_if_not_there(:name => 'workspace_contacts_management', :type_permission => 'container')
    p "Done"
  end

	desc "Load permissions on roles"
	task(:load_permissions => :environment) do
		p "Loading permissions on roles ..."
    @role_admin=Role.find_by_name("admin")
    @role_user=Role.find_by_name("user")
    @role_ws=Role.find_by_name("co_admin")
    @role_mod=Role.find_by_name("moderator")
    @role_red=Role.find_by_name("reader")
    @role_wri=Role.find_by_name("writer")
    # Permissions for SUPERADMIN
    # don't care, checked directly with the role, superadmin is god ... when the application doesn't crash ...
		ActiveRecord::Base.establish_connection
    # Drop All Pervious Links PermissionsRoles;
    sql =["TRUNCATE table permissions_roles;"]
    for i in sql
      query=<<-SQL
        #{i}
      SQL
      ActiveRecord::Base.connection.execute(query)
		end
#    [@role_admin, @role_user, @role_ws, @role_mod, @role_red, @role_wri].each do |e|
#			e.permissions = []
#			e.save
#		end
    # Permissions for ADMIN
    Permission.find(:all).each do |p|
      @role_admin.permissions << p
    end
    
    CONTAINERS.each do |container|
      # Permissions for USER ROLES
      @role_user.permissions << Permission.find_by_name("#{container}_new")
      # Permissions for CONTAINERS ROLES
      Permission.find(:all, :conditions => "name LIKE '#{container}%' AND type_permission='container'").each do |p|
				@role_ws.permissions << p
        @role_mod.permissions << p if p.name != "#{container}_destroy"
      end
      @role_red.permissions << Permission.find(:all, :conditions =>{:name => "#{container}_show"})
      @role_wri.permissions << Permission.find(:all, :conditions =>{:name => "#{container}_show"})
      @role_ws.permissions << Permission.find(:all, :conditions =>{:name => "#{container}_administrate"})
    end
    ITEMS.each do |item|
      ['new', 'edit', 'index', 'show', 'destroy','comment','rate','tag'].each do |action|
        Permission.find(:all, :conditions =>{:name => item + '_' + action}).each do |p|
          #@role_user.permissions << p
          if action=='new'  || action=='edit'
            @role_ws.permissions << p
            @role_mod.permissions << p
            @role_wri.permissions << p
          elsif action=='destroy'
            @role_ws.permissions << p
            @role_mod.permissions << p
          else
            @role_ws.permissions << p
            @role_mod.permissions << p
            @role_wri.permissions << p
            @role_red.permissions << p
          end
        end
      end
    end
		[@role_admin, @role_user, @role_ws, @role_mod, @role_red, @role_wri].each do |e|
			if e.save
				p "Role #{e.name} got permissions and saved"
			else
				p e.errors.inspect
			end
		end
    p "Done"
  end

  desc "Load Users"
  task(:create_users => :environment) do
    @superadmin = Role.find_by_name('superadmin')
    @admin = Role.find_by_name('admin')
    user = Role.find_by_name('user')

		#p "Creating the Superadmin user"
    sauser = User.find(:first, :conditions => {:system_role_id => 1})
    if sauser.nil?
      sql =[ "insert into users(id, login, email, avatar_file_name, avatar_content_type, avatar_file_size, avatar_updated_at, crypted_password, salt, activation_code, activated_at, password_reset_code, system_role_id, created_at, updated_at, remember_token, remember_token_expires_at)"+
				"values(1, 'superadmin', 'contact@test.com', null, null, null, null, 'a2c297302eb67e8f981a0f9bfae0e45e4d0e4317', '356a192b7913b04c54574d18c28d46e6395428ab', null, CURRENT_TIMESTAMP, null, #{@superadmin.id}, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, null, null);",
        "insert into profiles(id, first_name, last_name, created_at, updated_at, user_id)"+
				"values(1, 'Boss', 'Dupond', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 1);"
      ]
      for i in sql
        query=<<-SQL
        #{i}
        SQL
        ActiveRecord::Base.connection.execute(query)
			end
#        p "Enter superadmin username(Press Enter for default username 'superadmin') :- "
#        suser = STDIN.gets.chomp
#        p  "Enter superadmin password(Press Enter for default password 'monkey') :- "
#        spwd = STDIN.gets.chomp
#        @sa_user = User.find(:first, :conditions => {:system_role_id => 1})
#        @sa_user.login = suser unless suser.blank?
#        @sa_user.password = spwd unless spwd.blank?
#        @sa_user.password_confirmation = spwd unless spwd.blank?
#        @sa_user.save(false)
#        p "Setting Username = #{suser} & Password = #{spwd}"
    else
      sauser.system_role_id = @superadmin.id
      sauser.save
    end
		#p "Superadmin created"
    
    p "Creating the Admin user"
    auser = User.find(:first, :conditions => {:system_role_id => 2})
    if auser.nil?
      sql =[ "insert into users(id, login, email, avatar_file_name, avatar_content_type, avatar_file_size, avatar_updated_at, crypted_password, salt, activation_code, activated_at, password_reset_code, system_role_id, created_at, updated_at, remember_token, remember_token_expires_at)"+
				"values(2, 'admin', 'contact@test.com', null, null, null, null, 'a2c297302eb67e8f981a0f9bfae0e45e4d0e4317', '356a192b7913b04c54574d18c28d46e6395428ab', null, CURRENT_TIMESTAMP, null, #{@admin.id}, CURRENT_TIMESTAMP,CURRENT_TIMESTAMP, null, null);",
        "insert into profiles(id, first_name, last_name, created_at, updated_at, user_id)"+
				"values(2, 'Admin', 'Admin', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 2);"
      ]
      for i in sql
        query=<<-SQL
        #{i}
        SQL
        ActiveRecord::Base.connection.execute(query)
			end
        p "Enter admin username(Press Enter for default username 'admin') :- "
        auser = STDIN.gets.chomp
        p  "Enter admin password(Press Enter for default password 'monkey') :- "
        apwd = STDIN.gets.chomp
        a_user = User.find(:first, :conditions => {:system_role_id => 2})
        a_user.login = auser unless auser.blank?
        a_user.password = apwd unless apwd.blank?
        a_user.password_confirmation = apwd unless apwd.blank?
        a_user.save(false)
        p "Setting Username = #{auser} & Password = #{apwd}"

    else
      auser.system_role_id = @admin.id
      auser.save
    end
		
  end

  desc "Default Workspace Creation"
  task(:create_workspaces => :environment) do
    p "Loading Default Configuration for Workspace"
    if File.exist?("#{RAILS_ROOT}/config/customs/sa_config.yml")
      @default_conf = YAML.load_file("#{RAILS_ROOT}/config/customs/sa_config.yml")
    else
      @default_conf = YAML.load_file("#{RAILS_ROOT}/config/customs/default_config.yml")
    end
    p "Done"
		
    p "Creating Default Workspace"
    @superadmin = User.find(:first, :conditions => { :system_role_id => 1 })
    if Workspace.find_by_creator_id_and_state(@superadmin.id, "private").blank?
      @ws = Workspace.new(:creator_id => @superadmin.id, :description => "Archive for #{@superadmin.login}", :title=> "Archive for #{@superadmin.login}", :state => "private", :available_items => @default_conf['sa_items'].to_a)
      @ws.save(false)
      @ws.users_containers.create(:role_id => Role.find_by_name("co_admin").id, :user_id => @superadmin.id)
    end
    
    @aduser = User.find(:first, :conditions => { :system_role_id => 2 })
    if Workspace.find_by_creator_id_and_state(@aduser.id, "private").blank?
      @ws = Workspace.new(:creator_id => @aduser.id, :description => "Archive for Admin", :title=> "Archive for Devil", :state => "private", :available_items => @default_conf['sa_items'].to_a)
      @ws.save(false)
      @ws.users_containers.create(:role_id => Role.find_by_name("co_admin").id, :user_id => @aduser.id )
    end


#    @user = User.find_by_login("quentin")
#    if Workspace.find_by_creator_id_and_state(@user.id, "private").blank?
#      @ws = Workspace.new(:creator_id => @user.id, :description => "Archive for Quentin", :title=> "Archive for Quentin", :state => "private", :available_items => @default_conf['sa_items'].to_a)
#      @ws.save(false)
#      @ws.users_containers.create(:role_id => Role.find_by_name("co_admin").id, :user_id => @user.id )
#    end

    p "Done"
  end

  desc "Default Styles"
  task(:css => :environment) do
    p "Loading Styles if blank ..."
    if Element.find(:all).blank?
      Element.create(:name => "header", :bgcolor =>"#FFFFFF", :template => "current")
      Element.create(:name => "body", :bgcolor => "#FFFFFF", :template => "current")
      Element.create(:name => "footer", :bgcolor => "#666666", :template => "current")
      Element.create(:name => "top", :bgcolor => "#D86C27", :template => "current")
      Element.create(:name => "search", :bgcolor => "#666666", :template => "current")
      Element.create(:name => "ws", :bgcolor => "#FF9933", :template => "current")
      Element.create(:name => "border", :bgcolor => "#D86C27", :template => "current")
      Element.create(:name => "accordion", :bgcolor => "#666666", :template => "current")
      Element.create(:name => "links", :bgcolor => "#6C320C", :template => "current")
      Element.create(:name => "clicked", :bgcolor => "#FF9933", :template => "current")
    end
    p "Done"
  end

  desc "To Recreate generic_items view"
  task :recreate_generic_items_view => :environment do
    puts "Recreating generic_items view...."
    subqueries = Array.new
    ITEMS.map{ |item| item.to_sym }.each do |model|
      table_name = model.to_s.pluralize
      model_name = model.to_s.classify
      subqueries << %{
        SELECT
          '#{model_name}' as item_type,
          id,
          user_id,
          ( SELECT CONCAT_WS(' ', users.login, users.firstname, users.lastname)
            FROM users
            WHERE users.id = #{table_name}.user_id
          ) as user_name,
          title,
          description,
          created_at,
          updated_at,
          comments_number,
          rates_average
        FROM #{table_name} }
    end
    ActiveRecord::Base.connection.execute("CREATE OR REPLACE VIEW generic_items AS #{subqueries.join(' UNION ALL ')}".tr_s(" \n", ' '))
  end

  desc "To generate sha1_id value in contacts_workspace table"
  task(:generate_sha1_id => :environment) do
    puts "------> Generatin sha1_id value"
    for c_w in ContactsWorkspace.find(:all, :conditions => ["sha1_id <=> NULL OR sha1_id = ''"])
      c_w.save
    end
  end
  desc "To create default sa_config.yml"
  task(:create_sa_config => :environment) do
    puts "------> creating sa config"
    default_config = YAML.load_file("#{RAILS_ROOT}/config/customs/default/default_sa_config.yml")
    if File.exist?("#{RAILS_ROOT}/config/customs/sa_config.yml")
      sa_config = YAML.load_file("#{RAILS_ROOT}/config/customs/sa_config.yml")
      non_exists = default_config.map{|k, v| k } - sa_config.map{|k, v| k }
      non_exists.each do |key|
        sa_config.merge!(key => default_config[key])
      end
      un_used = sa_config.map{|k, v| k } - default_config.map{|k, v| k }
      un_used.each do |key|
        sa_config.delete(key)
      end
      new_sa_config = File.new("#{RAILS_ROOT}/config/customs/sa_config.yml", "w+")
      new_sa_config.syswrite(sa_config.to_yaml)
    else
      new_sa_config = File.new("#{RAILS_ROOT}/config/customs/sa_config.yml", "w+")
      new_sa_config.syswrite(default_config.to_yaml)
    end
    puts "------> created sa config"
  end

  desc "To delete dupicate records from join tables"
  task(:delete_duplicates_in_join_tables => :environment) do
    #      model_name = "ItemsWorkspace"
    #      fields_to_check = ['itemable_type', 'itemable_id', 'workspace_id']
    model_fields = {'ItemsWorkspace' => ['itemable_type', 'itemable_id', 'workspace_id']} #, 'UsersWorkspace' => ['user_id', 'workspace_id']}
    model_fields.each do |model_name, fields_to_check|
      model_name.classify.constantize.all.each do |item_w|
        cond = {}
        fields_to_check.each{|f| cond.merge!({f.to_sym => item_w.send(f.to_sym)})}
        tmp = model_name.classify.constantize.find(:all, :conditions => cond)
        if tmp.length > 1
          tmp.delete_if{|i| i.id == item_w.id}.each{|it| it.delete}
        end
      end
    end
  end

  namespace :maintaining do

		desc "To retrieve translation files"
		task(:retrieve_translation => :environment) do
			LANGUAGES.each do |l|
				command_backup =  "mv config/locales/" + l + ".yml tmp/backup/" + Time.now.strftime("%Y%m%d") + "_" + l + ".yml"
				command_get =  "wget " + TRANSLATION_SITE + "/translations/" + PROJECT_NAME + "/" + l + ".yaml -O config/locales/" + l + ".yml"
				system(command_backup)
				system(command_get)
			end
		end

		desc "To Reencode videos"
		task(:video_reencode => :environment) do
			@videos = Video.find(:all, :conditions =>["state = 'uploaded' OR state = 'encoding_error' OR state = 'error'"])
			for video in @videos
				puts "---->Reencoding started for video #{video.id}"
        Delayed::Job.enqueue(EncodingJob.new({:type=>"video", :id => video.id, :enc=>"flv"}))
			end
		end

		desc "To Reencode audios"
		task(:audio_reencode => :environment) do
			@audios = Audio.find(:all, :conditions =>["state = 'uploaded' OR state = 'encoding_error' OR state = 'error'"])
			for audio in @audios
				puts "---->Reencoding started for audio #{audio.id}"
        Delayed::Job.enqueue(EncodingJob.new({:type=>"audio", :id => audio.id, :enc=>"flv"}))
      end

      desc "To set items default values (comments number, ...)"
      task :default_values_for_items => :environment do
        #['article', 'image', 'cms_file', 'video', 'audio', 'publication', 'feed_source', 'bookmark','newsletter','group'].each do |item|
        ITEMS.each do |item|
          puts "Updating for #{item}"
          (item.classify.constantize).all.each do |e|
            puts "Updating #{item} with id = #{e.id}"
            if !e.workspaces.blank?
              if e.comments_number.nil?
                e.comments_number = 0
              end
              if e.rates_average.nil?
                e.rates_average = 0
              end
              if e.viewed_number.nil?
                e.viewed_number = 0
              end
              if e.save(false)
                puts "Updated record #{e.id}"
              else
                puts "Updating Record with id #{e.id} failed"
                puts e.errors.inspect
              end
            else
              puts "Destroying record #{e.id} of type #{item}"
              e.destroy
              puts "Destroyed"
            end
          end
        end
      end
    end
  end

  namespace :cache do
    desc "Clears javascripts/cache and stylesheets/cache"
    task :clear => :environment do
      FileUtils.rm(Dir['public/javascripts/cache/[^.]*'])
      FileUtils.rm(Dir['public/stylesheets/cache/[^.]*'])
    end
  end
end
