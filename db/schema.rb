# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20110818131339) do

  create_table "acts_as_xapian_jobs", :force => true do |t|
    t.string  "model",    :null => false
    t.integer "model_id", :null => false
    t.string  "action",   :null => false
  end

  add_index "acts_as_xapian_jobs", ["model", "model_id"], :name => "index_acts_as_xapian_jobs_on_model_and_model_id", :unique => true

  create_table "app_homes", :force => true do |t|
    t.string   "houres"
    t.text     "openings"
    t.text     "staff"
    t.text     "costs"
    t.string   "gallery_planlink"
    t.text     "bookings"
    t.string   "bsgproposallink"
    t.text     "opening_night"
    t.string   "staffed"
    t.text     "mailing_list_number"
    t.string   "mailing_list_desc"
    t.string   "invitation"
    t.text     "advertising"
    t.text     "sales"
    t.text     "your_obligations"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "article_files", :force => true do |t|
    t.integer  "article_id"
    t.string   "articlefile_file_name",    :limit => 100
    t.string   "articlefile_content_type", :limit => 20
    t.integer  "articlefile_file_size"
    t.datetime "articlefile_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "article_files", ["article_id"], :name => "index_article_files_on_article_id"

  create_table "articles", :force => true do |t|
    t.integer  "user_id"
    t.string   "title",                                             :null => false
    t.text     "description",                                       :null => false
    t.string   "state",           :limit => 15
    t.text     "body"
    t.integer  "viewed_number",                 :default => 0
    t.integer  "comments_number",               :default => 0
    t.integer  "rates_average",                 :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "published",                     :default => false
    t.string   "source",                        :default => "form"
  end

  add_index "articles", ["user_id"], :name => "index_articles_on_user_id"

  create_table "artworks", :force => true do |t|
    t.integer  "user_id"
    t.string   "title",                                            :null => false
    t.text     "description",                                      :null => false
    t.string   "medium"
    t.integer  "height"
    t.integer  "width"
    t.integer  "depth"
    t.string   "edition_name"
    t.integer  "edition_number"
    t.integer  "price"
    t.boolean  "is_purchasable"
    t.string   "image_file_name",    :limit => 100
    t.string   "image_content_type", :limit => 20
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.string   "state",              :limit => 15
    t.integer  "viewed_number",                     :default => 0
    t.integer  "comments_number",                   :default => 0
    t.integer  "rates_average",                     :default => 0
    t.integer  "published",                         :default => 0
    t.string   "source"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "exhibition_id"
    t.boolean  "sold"
    t.integer  "sold_number"
  end

  add_index "artworks", ["user_id"], :name => "index_artworks_on_user_id"

  create_table "artworks_competitions", :force => true do |t|
    t.integer  "artwork_id"
    t.integer  "competition_id"
    t.string   "state"
    t.integer  "mark"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "image_name"
    t.integer  "competitions_users_id"
    t.boolean  "sold"
    t.string   "avatar_file_name"
    t.string   "avatar_content_type"
    t.integer  "avatar_file_size"
    t.datetime "avatar_updated_at"
    t.string   "artworkurl_file_name"
    t.string   "artworkurl_content_type"
    t.integer  "artworkurl_file_size"
    t.datetime "artworkurl_updated_at"
    t.string   "prize_detail"
  end

  add_index "artworks_competitions", ["artwork_id"], :name => "index_artworks_competitions_on_artwork_id"
  add_index "artworks_competitions", ["competition_id"], :name => "index_artworks_competitions_on_competition_id"

  create_table "artworks_exhibitions", :force => true do |t|
    t.integer  "artwork_id"
    t.integer  "exhibition_id"
    t.integer  "exhibitions_users"
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "artworks_exhibitions", ["artwork_id"], :name => "index_artworks_exhibitions_on_artwork_id"
  add_index "artworks_exhibitions", ["exhibition_id"], :name => "index_artworks_exhibitions_on_exhibition_id"

  create_table "audios", :force => true do |t|
    t.integer  "user_id"
    t.string   "title",                                                 :null => false
    t.text     "description",                                           :null => false
    t.string   "audio_file_name",    :limit => 100
    t.string   "audio_content_type", :limit => 20
    t.integer  "audio_file_size"
    t.datetime "audio_updated_at"
    t.string   "state",              :limit => 15
    t.integer  "viewed_number",                     :default => 0
    t.integer  "comments_number",                   :default => 0
    t.integer  "rates_average",                     :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "published",                         :default => false
    t.string   "source",                            :default => "form"
  end

  add_index "audios", ["user_id"], :name => "index_audios_on_user_id"

  create_table "audits", :force => true do |t|
    t.integer  "auditable_id"
    t.string   "auditable_type"
    t.integer  "user_id"
    t.string   "user_type"
    t.string   "username"
    t.string   "action"
    t.text     "changes"
    t.integer  "version",        :default => 0
    t.datetime "created_at"
  end

  add_index "audits", ["auditable_id", "auditable_type"], :name => "auditable_index"
  add_index "audits", ["created_at"], :name => "index_audits_on_created_at"
  add_index "audits", ["user_id", "user_type"], :name => "user_index"

  create_table "bookmarks", :force => true do |t|
    t.integer  "user_id"
    t.integer  "feed_source_id"
    t.string   "title",                                               :null => false
    t.text     "description",                                         :null => false
    t.string   "state",           :limit => 15
    t.string   "link",            :limit => 1024
    t.string   "enclosures"
    t.string   "authors"
    t.string   "copyright",       :limit => 10
    t.string   "categories"
    t.integer  "viewed_number",                   :default => 0
    t.integer  "comments_number",                 :default => 0
    t.integer  "rates_average",                   :default => 0
    t.datetime "date_published"
    t.datetime "last_updated"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "published",                       :default => false
    t.string   "source",                          :default => "form"
  end

  add_index "bookmarks", ["feed_source_id"], :name => "index_bookmarks_on_feed_source_id"
  add_index "bookmarks", ["user_id"], :name => "index_bookmarks_on_user_id"

  create_table "booksshops", :force => true do |t|
    t.text     "bookshopdetails"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "bottomlines", :force => true do |t|
    t.text     "bottomline"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "categories", :force => true do |t|
    t.string   "name"
    t.string   "state"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "cms_files", :force => true do |t|
    t.integer  "user_id"
    t.string   "title",                                                   :null => false
    t.text     "description",                                             :null => false
    t.string   "cmsfile_file_name",    :limit => 100
    t.string   "cmsfile_content_type", :limit => 20
    t.integer  "cmsfile_file_size"
    t.datetime "cmsfile_updated_at"
    t.string   "state",                :limit => 15
    t.integer  "viewed_number",                       :default => 0
    t.integer  "comments_number",                     :default => 0
    t.integer  "rates_average",                       :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "published",                           :default => false
    t.string   "source",                              :default => "form"
  end

  add_index "cms_files", ["user_id"], :name => "index_cms_files_on_user_id"

  create_table "columnnameandheaders", :force => true do |t|
    t.string   "column_header"
    t.string   "column_name"
    t.string   "idoffieldwithtablename"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "comments", :force => true do |t|
    t.text     "text",                           :null => false
    t.string   "state",            :limit => 15
    t.integer  "parent_id"
    t.integer  "user_id"
    t.integer  "commentable_id"
    t.string   "commentable_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "comments", ["commentable_id"], :name => "index_comments_on_commentable_id"
  add_index "comments", ["commentable_type"], :name => "index_comments_on_commentable_type"
  add_index "comments", ["user_id"], :name => "index_comments_on_user_id"

  create_table "competitions", :force => true do |t|
    t.integer  "user_id"
    t.integer  "timing_id"
    t.string   "title",                                                :null => false
    t.text     "description",                                          :null => false
    t.string   "type"
    t.date     "submission_deadline"
    t.integer  "prizes_total_amount"
    t.text     "prizes_detail"
    t.integer  "judge_id"
    t.string   "commission"
    t.string   "limit_size"
    t.boolean  "auction_activated"
    t.text     "message_for_subscribers"
    t.string   "state",                   :limit => 15
    t.integer  "viewed_number",                         :default => 0
    t.integer  "comments_number",                       :default => 0
    t.integer  "rates_average",                         :default => 0
    t.integer  "published",                             :default => 0
    t.string   "source"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "location"
    t.integer  "no_of_entry"
    t.string   "framing"
    t.text     "entry_fees"
    t.string   "format"
    t.string   "delivery"
    t.string   "collection"
    t.string   "insurance"
    t.text     "return_of_artwork"
    t.string   "exhibition_date"
    t.string   "cjudges"
    t.text     "how_did_you_here"
    t.text     "notes"
    t.text     "openstatemsg"
    t.text     "publishfinalmsg"
  end

  add_index "competitions", ["user_id"], :name => "index_competitions_on_user_id"

  create_table "competitions_subscriptions", :force => true do |t|
    t.integer  "competition_id"
    t.integer  "maximum_works_number"
    t.string   "description"
    t.float    "price"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "competitions_subscriptions", ["competition_id"], :name => "index_competitions_subscriptions_on_competition_id"

  create_table "competitions_users", :force => true do |t|
    t.integer  "user_id"
    t.integer  "competitions_subscription_id"
    t.integer  "competition_id"
    t.string   "state"
    t.float    "price"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
    t.string   "email"
    t.string   "suburb"
    t.integer  "post_code"
    t.string   "here_prize"
    t.string   "others"
    t.string   "total_entry"
    t.string   "payment_type"
    t.string   "card_name"
    t.string   "card_number"
    t.string   "exp_date"
    t.text     "biography"
    t.string   "return_of_artwork"
    t.string   "bank_account"
    t.string   "fworktitle"
    t.string   "fworkmedium"
    t.string   "fworksize"
    t.string   "fworkprice"
    t.string   "fworkimage"
    t.string   "sworktitle"
    t.string   "sworkmedium"
    t.string   "sworksize"
    t.string   "sworkprice"
    t.string   "sworkimage"
    t.string   "tworktitle"
    t.string   "tworkmedium"
    t.string   "tworksize"
    t.string   "tworkprice"
    t.string   "tworkimage"
    t.string   "foworktitle"
    t.string   "foworkmedium"
    t.string   "foworksize"
    t.string   "foworkprice"
    t.string   "foworkimage"
    t.string   "fiworktitle"
    t.string   "fiworkmedium"
    t.string   "fiworksize"
    t.string   "fiworkprice"
    t.string   "fiworkimage"
    t.string   "siworktitle"
    t.string   "siworkmedium"
    t.string   "siworksize"
    t.string   "siworkprice"
    t.string   "siworkimage"
    t.string   "seworktitle"
    t.string   "seworkmedium"
    t.string   "seworksize"
    t.string   "seworkprice"
    t.string   "seworkimage"
    t.string   "eworktitle"
    t.string   "eworkmedium"
    t.string   "eworksize"
    t.string   "eworkprice"
    t.string   "eworkimage"
    t.string   "nworktitle"
    t.string   "nworkmedium"
    t.string   "nworksize"
    t.string   "nworkprice"
    t.string   "nworkimage"
    t.string   "teworktitle"
    t.string   "teworkmedium"
    t.string   "teworksize"
    t.string   "teworkprice"
    t.string   "teworkimage"
    t.string   "address"
    t.string   "bsb_no"
    t.string   "at_end_work"
    t.boolean  "confirm"
    t.string   "varification_code"
    t.boolean  "fsold"
    t.boolean  "ssold"
    t.boolean  "tsold"
    t.boolean  "fosold"
    t.boolean  "fisold"
    t.boolean  "sisold"
    t.boolean  "sesold"
    t.boolean  "eisold"
    t.boolean  "nsold"
    t.boolean  "tesold"
    t.integer  "fworkedname"
    t.integer  "sworkedname"
    t.integer  "tworkedname"
    t.integer  "foworkedname"
    t.integer  "fiworkedname"
    t.integer  "siworkedname"
    t.integer  "seworkedname"
    t.integer  "eiworkedname"
    t.integer  "niworkedname"
    t.integer  "teworkedname"
    t.integer  "fworkednumber"
    t.integer  "sworkednumber"
    t.integer  "tworkednumber"
    t.integer  "foworkednumber"
    t.integer  "fiworkednumber"
    t.integer  "siworkednumber"
    t.integer  "seworkednumber"
    t.integer  "eiworkednumber"
    t.integer  "niworkednumber"
    t.integer  "teworkednumber"
  end

  add_index "competitions_users", ["competition_id"], :name => "index_competitions_users_on_competition_id"
  add_index "competitions_users", ["user_id"], :name => "index_competitions_users_on_user_id"

  create_table "comptartworks", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "contacts_workspaces", :force => true do |t|
    t.integer  "workspace_id"
    t.integer  "contactable_id"
    t.string   "contactable_type", :limit => 50
    t.string   "state",            :limit => 15
    t.string   "sha1_id",          :limit => 40
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "contacts_workspaces", ["contactable_id"], :name => "index_contacts_workspaces_on_contactable_id"
  add_index "contacts_workspaces", ["contactable_type"], :name => "index_contacts_workspaces_on_contactable_type"
  add_index "contacts_workspaces", ["workspace_id"], :name => "index_contacts_workspaces_on_workspace_id"

  create_table "credit_cards", :force => true do |t|
    t.integer  "user_id"
    t.string   "type_of_card"
    t.string   "first_name"
    t.string   "last_name"
    t.integer  "number",             :limit => 8
    t.date     "expiring_date"
    t.integer  "verification_value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "credit_cards", ["user_id"], :name => "index_credit_cards_on_user_id"

  create_table "data_people", :force => true do |t|
    t.integer  "person_id"
    t.integer  "workspace_id"
    t.string   "origin"
    t.string   "type_data"
    t.text     "data"
    t.string   "state"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "drawings", :force => true do |t|
    t.text     "drawingdetails"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "elements", :force => true do |t|
    t.string   "name",       :limit => 50
    t.string   "bgcolor",    :limit => 10
    t.string   "template"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "emaillabels", :force => true do |t|
    t.string   "labelname"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "exhi_artworks", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "exhibitions", :force => true do |t|
    t.integer  "user_id"
    t.string   "title",                                        :null => false
    t.text     "description",                                  :null => false
    t.string   "state",           :limit => 15
    t.integer  "viewed_number",                 :default => 0
    t.integer  "comments_number",               :default => 0
    t.integer  "rates_average",                 :default => 0
    t.integer  "published",                     :default => 0
    t.string   "source"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "exhibitions", ["user_id"], :name => "index_exhibitions_on_user_id"

  create_table "exhibitions_users", :force => true do |t|
    t.integer  "user_id"
    t.integer  "exhibition_id"
    t.datetime "invited_at"
    t.string   "state"
    t.float    "price"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "exhibitions_users", ["exhibition_id"], :name => "index_exhibitions_users_on_exhibition_id"
  add_index "exhibitions_users", ["user_id"], :name => "index_exhibitions_users_on_user_id"

  create_table "feed_items", :force => true do |t|
    t.integer  "feed_source_id"
    t.string   "guid",           :limit => 50
    t.string   "title"
    t.text     "description"
    t.string   "authors"
    t.string   "enclosures"
    t.string   "link",           :limit => 1024
    t.string   "categories"
    t.string   "copyright",      :limit => 10
    t.datetime "date_published"
    t.datetime "last_updated"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "feed_items", ["feed_source_id"], :name => "index_feed_items_on_feed_source_id"

  create_table "feed_sources", :force => true do |t|
    t.integer  "user_id"
    t.string   "etag"
    t.string   "version",         :limit => 20
    t.string   "encoding",        :limit => 20
    t.string   "language",        :limit => 50
    t.string   "title",                                          :null => false
    t.text     "description",                                    :null => false
    t.string   "state",           :limit => 10
    t.string   "url",             :limit => 1024
    t.string   "link",            :limit => 1024
    t.string   "authors"
    t.string   "categories"
    t.string   "copyright",       :limit => 10
    t.integer  "ttl"
    t.string   "image"
    t.integer  "viewed_number",                   :default => 0
    t.integer  "comments_number",                 :default => 0
    t.integer  "rates_average",                   :default => 0
    t.datetime "last_updated"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "feed_sources", ["user_id"], :name => "index_feed_sources_on_user_id"

  create_table "folders", :force => true do |t|
    t.integer  "creator_id"
    t.string   "title",                                            :null => false
    t.string   "description",                      :default => "", :null => false
    t.string   "state",             :limit => 15
    t.string   "available_items"
    t.string   "logo_file_name",    :limit => 100
    t.string   "logo_content_type", :limit => 50
    t.integer  "logo_file_size"
    t.string   "available_types"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "folders", ["creator_id"], :name => "index_folders_on_creator_id"

  create_table "frommails", :force => true do |t|
    t.string   "frommail"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "frontendpics", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "front_end_pics_file_name"
    t.string   "front_end_pics_content_type"
    t.integer  "front_end_pics_file_size"
    t.datetime "front_end_pics_updated_at"
    t.boolean  "selectpic"
  end

  create_table "galleries", :force => true do |t|
    t.integer  "user_id"
    t.string   "title",                                        :null => false
    t.text     "description",                                  :null => false
    t.integer  "price"
    t.string   "state",           :limit => 15
    t.integer  "viewed_number",                 :default => 0
    t.integer  "comments_number",               :default => 0
    t.integer  "rates_average",                 :default => 0
    t.integer  "published",                     :default => 0
    t.string   "source"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "galleries", ["user_id"], :name => "index_galleries_on_user_id"

  create_table "groupings", :id => false, :force => true do |t|
    t.integer  "group_id"
    t.integer  "groupable_id"
    t.string   "groupable_type"
    t.integer  "user_id"
    t.integer  "contacts_workspace_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "groupings", ["contacts_workspace_id"], :name => "index_groupings_on_contacts_workspace_id"
  add_index "groupings", ["group_id"], :name => "index_groupings_on_group_id"
  add_index "groupings", ["groupable_id"], :name => "index_groupings_on_groupable_id"
  add_index "groupings", ["groupable_type"], :name => "index_groupings_on_groupable_type"
  add_index "groupings", ["user_id"], :name => "index_groupings_on_user_id"

  create_table "groups", :force => true do |t|
    t.integer  "user_id"
    t.string   "title"
    t.text     "description"
    t.string   "state",           :limit => 15
    t.integer  "workspace_id"
    t.integer  "comments_number",               :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "rates_average",                 :default => 0
    t.integer  "viewed_number",                 :default => 0
    t.boolean  "published",                     :default => false
    t.string   "source",                        :default => "form"
  end

  add_index "groups", ["user_id"], :name => "index_groups_on_user_id"
  add_index "groups", ["workspace_id"], :name => "index_groups_on_workspace_id"

  create_table "groups_newsletters", :force => true do |t|
    t.integer  "newsletter_id"
    t.integer  "group_id"
    t.datetime "sent_on"
  end

  add_index "groups_newsletters", ["group_id"], :name => "index_groups_newsletters_on_group_id"
  add_index "groups_newsletters", ["newsletter_id"], :name => "index_groups_newsletters_on_newsletter_id"

  create_table "groupshowartworks", :force => true do |t|
    t.integer  "groupshow_id"
    t.integer  "user_id"
    t.string   "artworkurl"
    t.string   "title"
    t.string   "medium"
    t.integer  "size1"
    t.integer  "size2"
    t.integer  "size3"
    t.integer  "price"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "sold"
    t.integer  "editionname"
    t.integer  "editionumber"
    t.string   "artworkurl_file_name"
    t.string   "artworkurl_content_type"
    t.integer  "artworkurl_file_size"
    t.datetime "artworkurl_updated_at"
  end

  create_table "groupshows", :force => true do |t|
    t.integer  "user_id"
    t.string   "title",         :null => false
    t.text     "description",   :null => false
    t.date     "starting_date"
    t.date     "ending_date"
    t.text     "note"
    t.string   "gallery_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "groupshows", ["user_id"], :name => "index_groupshows_on_user_id"

  create_table "images", :force => true do |t|
    t.integer  "user_id"
    t.string   "title",                                                 :null => false
    t.text     "description",                                           :null => false
    t.string   "image_file_name",    :limit => 100
    t.string   "image_content_type", :limit => 20
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.string   "state",              :limit => 15
    t.integer  "viewed_number",                     :default => 0
    t.integer  "comments_number",                   :default => 0
    t.integer  "rates_average",                     :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "published",                         :default => false
    t.string   "source",                            :default => "form"
  end

  add_index "images", ["user_id"], :name => "index_images_on_user_id"

  create_table "invoices", :force => true do |t|
    t.integer  "creator_id"
    t.integer  "client_id"
    t.string   "purchasable_type"
    t.integer  "purchasable_id"
    t.string   "number"
    t.string   "title",                          :null => false
    t.text     "description",                    :null => false
    t.string   "state",            :limit => 15
    t.string   "payment_medium"
    t.string   "billing_address"
    t.string   "shipping_address"
    t.date     "deadline"
    t.float    "original_amount"
    t.float    "final_amount"
    t.datetime "sent_at"
    t.datetime "validated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "note"
  end

  add_index "invoices", ["client_id"], :name => "index_invoices_on_client_id"

  create_table "items_folders", :force => true do |t|
    t.integer  "folder_id",     :null => false
    t.integer  "itemable_id",   :null => false
    t.string   "itemable_type", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "items_folders", ["folder_id"], :name => "index_items_folders_on_folder_id"
  add_index "items_folders", ["itemable_id"], :name => "index_items_folders_on_itemable_id"
  add_index "items_folders", ["itemable_type"], :name => "index_items_folders_on_itemable_type"

  create_table "items_websites", :force => true do |t|
    t.integer  "website_id",    :null => false
    t.integer  "itemable_id",   :null => false
    t.string   "itemable_type", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "items_websites", ["itemable_id"], :name => "index_items_websites_on_itemable_id"
  add_index "items_websites", ["itemable_type"], :name => "index_items_websites_on_itemable_type"
  add_index "items_websites", ["website_id"], :name => "index_items_websites_on_website_id"

  create_table "items_workspaces", :force => true do |t|
    t.integer  "workspace_id",  :null => false
    t.integer  "itemable_id",   :null => false
    t.string   "itemable_type", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "items_workspaces", ["itemable_id"], :name => "index_items_workspaces_on_itemable_id"
  add_index "items_workspaces", ["itemable_type"], :name => "index_items_workspaces_on_itemable_type"
  add_index "items_workspaces", ["workspace_id"], :name => "index_items_workspaces_on_workspace_id"

  create_table "keywordings", :id => false, :force => true do |t|
    t.integer  "keywordable_id"
    t.string   "keywordable_type", :limit => 40
    t.integer  "keyword_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "keywordings", ["keyword_id"], :name => "index_keywordings_on_keyword_id"
  add_index "keywordings", ["keywordable_id"], :name => "index_keywordings_on_keywordable_id"
  add_index "keywordings", ["keywordable_type"], :name => "index_keywordings_on_keywordable_type"
  add_index "keywordings", ["user_id"], :name => "index_keywordings_on_user_id"

  create_table "keywords", :force => true do |t|
    t.integer  "user_id"
    t.string   "name",       :limit => 40
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "keywords", ["user_id"], :name => "index_keywords_on_user_id"

  create_table "links", :force => true do |t|
    t.string   "link_name"
    t.string   "link_src"
    t.boolean  "approve"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "mailfolders", :force => true do |t|
    t.integer  "user_id"
    t.integer  "parent_id"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "menus", :force => true do |t|
    t.string   "name"
    t.string   "url"
    t.string   "parent_id"
    t.integer  "website_id"
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "message_copies", :force => true do |t|
    t.integer  "recipient_id"
    t.integer  "message_id"
    t.integer  "mailfolder_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "deleted"
    t.integer  "emaillabel_id"
    t.boolean  "labeled"
    t.boolean  "flag"
  end

  create_table "messages", :force => true do |t|
    t.integer  "author_id"
    t.string   "subject"
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "flag"
    t.boolean  "deletedm"
    t.boolean  "deletedmt"
    t.string   "deletefrom"
    t.string   "deleteto"
    t.string   "deletefromt"
    t.string   "deletetot"
  end

  create_table "newsletteremails", :force => true do |t|
    t.integer  "user_id"
    t.integer  "newsletter_id"
    t.boolean  "emailsend"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "newsletters", :force => true do |t|
    t.string   "title"
    t.text     "news_letter_content"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "notification_filters", :force => true do |t|
    t.string   "name"
    t.string   "group"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "notification_subscriptions", :force => true do |t|
    t.integer  "user_id"
    t.integer  "notification_filter_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "order_lines", :force => true do |t|
    t.integer  "order_id"
    t.string   "orderable_type"
    t.integer  "orderable_id"
    t.integer  "number"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "imagename"
  end

  add_index "order_lines", ["order_id"], :name => "index_order_lines_on_order_id"

  create_table "orders", :force => true do |t|
    t.integer  "creator_id"
    t.integer  "client_id"
    t.string   "number"
    t.string   "title"
    t.float    "total_amount"
    t.string   "state",        :limit => 15
    t.datetime "completed_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "orders", ["client_id"], :name => "index_orders_on_client_id"

  create_table "pages", :force => true do |t|
    t.integer  "user_id"
    t.string   "title",                                             :null => false
    t.text     "description",                                       :null => false
    t.string   "state",           :limit => 15
    t.text     "body"
    t.string   "page_title"
    t.string   "page_type",       :limit => 50
    t.string   "menu_title",      :limit => 50
    t.string   "title_sanitized"
    t.integer  "viewed_number",                 :default => 0
    t.integer  "comments_number",               :default => 0
    t.integer  "rates_average",                 :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "published",                     :default => false
    t.string   "source",                        :default => "form"
  end

  create_table "payments", :force => true do |t|
    t.integer  "user_id"
    t.integer  "invoice_id"
    t.integer  "credit_card_id"
    t.string   "state"
    t.string   "note"
    t.integer  "amount_in_cents"
    t.string   "currency"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "payments", ["user_id"], :name => "index_payments_on_user_id"

  create_table "people", :force => true do |t|
    t.string   "first_name",    :limit => 40
    t.string   "last_name",     :limit => 40
    t.string   "web_page",      :limit => 100
    t.string   "gender",        :limit => 6
    t.text     "notes"
    t.string   "email",         :limit => 50,  :null => false
    t.string   "primary_phone", :limit => 25
    t.string   "mobile_phone",  :limit => 25
    t.string   "fax",           :limit => 25
    t.string   "street",        :limit => 40
    t.string   "city",          :limit => 40
    t.string   "postal_code",   :limit => 10
    t.string   "country",       :limit => 50
    t.string   "company",       :limit => 40
    t.string   "job_title",     :limit => 40
    t.integer  "user_id"
    t.boolean  "newsletter"
    t.string   "salutation",    :limit => 5
    t.string   "origin",        :limit => 10
    t.date     "date_of_birth"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "people", ["user_id"], :name => "index_people_on_user_id"

  create_table "periods", :force => true do |t|
    t.date     "starting_date"
    t.date     "ending_date"
    t.string   "state",         :limit => 15
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "permissions", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.string   "type_permission"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "permissions", ["name"], :name => "index_permissions_on_name"

  create_table "permissions_roles", :id => false, :force => true do |t|
    t.integer "permission_id"
    t.integer "role_id"
  end

  add_index "permissions_roles", ["permission_id"], :name => "index_permissions_roles_on_permission_id"
  add_index "permissions_roles", ["role_id"], :name => "index_permissions_roles_on_role_id"

  create_table "profiles", :force => true do |t|
    t.integer  "user_id"
    t.string   "salutation",         :limit => 5
    t.string   "first_name",         :limit => 50,                     :null => false
    t.string   "middle_name",        :limit => 50
    t.string   "last_name",          :limit => 50,                     :null => false
    t.string   "gender",             :limit => 6
    t.date     "birth_date"
    t.string   "nationality",        :limit => 50
    t.boolean  "getting_newsletter",                :default => false
    t.string   "state"
    t.string   "email_address",      :limit => 100
    t.string   "address"
    t.string   "suburb",             :limit => 70
    t.string   "zip_code",           :limit => 10
    t.string   "city",               :limit => 50
    t.string   "country_state",      :limit => 50
    t.string   "country",            :limit => 50
    t.string   "phone_number",       :limit => 25
    t.string   "website"
    t.text     "biography"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "studios"
    t.string   "notices"
  end

  add_index "profiles", ["user_id"], :name => "index_profiles_on_user_id"

  create_table "profiles_categories", :force => true do |t|
    t.integer  "profile_id"
    t.string   "category_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "profiles_categories", ["category_id"], :name => "index_profiles_categories_on_category_id"
  add_index "profiles_categories", ["profile_id"], :name => "index_profiles_categories_on_profile_id"

  create_table "profiles_containers", :force => true do |t|
    t.integer  "profile_id"
    t.string   "container_type"
    t.integer  "container_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "promoting_stuffs", :force => true do |t|
    t.string   "title"
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "link"
  end

  create_table "queued_mails", :force => true do |t|
    t.string   "mailer"
    t.string   "mailer_method"
    t.text     "args"
    t.integer  "priority",      :default => 0
    t.integer  "sending_tries", :default => 0
    t.datetime "created_at"
    t.string   "frommail"
    t.string   "tomail"
    t.integer  "replayto"
    t.boolean  "deletefrom"
    t.boolean  "deleteto"
    t.boolean  "toread"
    t.boolean  "fromread"
  end

  create_table "ratings", :force => true do |t|
    t.integer  "rating"
    t.integer  "user_id"
    t.integer  "rateable_id"
    t.string   "rateable_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ratings", ["rateable_id"], :name => "index_ratings_on_rateable_id"
  add_index "ratings", ["rateable_type"], :name => "index_ratings_on_rateable_type"
  add_index "ratings", ["user_id"], :name => "index_ratings_on_user_id"

  create_table "roles", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.string   "type_role"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "roles", ["name"], :name => "index_roles_on_name"

  create_table "saved_searches", :force => true do |t|
    t.string   "title"
    t.string   "description"
    t.string   "q"
    t.string   "field"
    t.string   "order"
    t.text     "containers"
    t.string   "items"
    t.integer  "limit"
    t.datetime "created_at_after"
    t.datetime "created_at_before"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "saved_searches", ["user_id"], :name => "index_saved_searches_on_user_id"

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "signatures", :force => true do |t|
    t.integer  "frommail_id"
    t.string   "signlabel"
    t.string   "signature"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "studio_and_mailing_lists", :force => true do |t|
    t.string   "first_name",    :limit => 50,  :null => false
    t.string   "last_name",     :limit => 50,  :null => false
    t.string   "email_address", :limit => 100
    t.string   "address"
    t.string   "suburb",        :limit => 70
    t.string   "zip_code",      :limit => 10
    t.string   "phone_number",  :limit => 25
    t.boolean  "studio"
    t.boolean  "mailing_list"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tempraryinboxes", :force => true do |t|
    t.string   "fromemail"
    t.string   "subject"
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "timings", :force => true do |t|
    t.string   "objectable_type"
    t.integer  "objectable_id"
    t.string   "note"
    t.integer  "period_id"
    t.date     "starting_date"
    t.date     "ending_date"
    t.time     "starting_time"
    t.time     "ending_time"
    t.string   "places_id"
    t.string   "state"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "timings_places", :force => true do |t|
    t.string  "objekt_type"
    t.integer "objekt_id"
    t.integer "timing_id"
  end

  create_table "user_groups", :force => true do |t|
    t.integer  "user_id"
    t.string   "title",                                        :null => false
    t.text     "description",                                  :null => false
    t.string   "state",           :limit => 15
    t.integer  "viewed_number",                 :default => 0
    t.integer  "comments_number",               :default => 0
    t.integer  "rates_average",                 :default => 0
    t.integer  "published",                     :default => 0
    t.string   "source"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "user_groups", ["user_id"], :name => "index_user_groups_on_user_id"

  create_table "user_groups_users", :force => true do |t|
    t.integer  "user_group_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "usergroupshows", :force => true do |t|
    t.integer "user_id"
    t.integer "groupshow_id"
    t.string  "state"
  end

  create_table "usernamefortests", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "login",                     :limit => 40,  :null => false
    t.string   "email",                     :limit => 50,  :null => false
    t.string   "avatar_file_name",          :limit => 100
    t.string   "avatar_content_type",       :limit => 50
    t.integer  "avatar_file_size"
    t.datetime "avatar_updated_at"
    t.datetime "last_connected_at"
    t.string   "state",                     :limit => 15
    t.string   "u_layout",                  :limit => 30
    t.integer  "u_per_page"
    t.string   "u_language",                :limit => 10
    t.string   "crypted_password",          :limit => 40
    t.string   "salt",                      :limit => 40
    t.datetime "activated_at"
    t.string   "activation_code",           :limit => 40
    t.string   "password_reset_code",       :limit => 40
    t.integer  "system_role_id"
    t.string   "remember_token",            :limit => 40
    t.datetime "remember_token_expires_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["login"], :name => "index_users_on_login", :unique => true
  add_index "users", ["system_role_id"], :name => "index_users_on_system_role_id"

  create_table "users_containers", :force => true do |t|
    t.integer  "containerable_id",   :null => false
    t.string   "containerable_type", :null => false
    t.integer  "role_id",            :null => false
    t.integer  "user_id",            :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users_containers", ["containerable_id"], :name => "index_users_containers_on_containerable_id"
  add_index "users_containers", ["containerable_type"], :name => "index_users_containers_on_containerable_type"
  add_index "users_containers", ["role_id"], :name => "index_users_containers_on_role_id"
  add_index "users_containers", ["user_id"], :name => "index_users_containers_on_user_id"

  create_table "videos", :force => true do |t|
    t.integer  "user_id"
    t.string   "title",                                                 :null => false
    t.text     "description",                                           :null => false
    t.string   "video_file_name",    :limit => 100
    t.string   "video_content_type", :limit => 20
    t.integer  "video_file_size"
    t.datetime "video_updated_at"
    t.string   "state",              :limit => 15
    t.integer  "viewed_number",                     :default => 0
    t.integer  "comments_number",                   :default => 0
    t.integer  "rates_average",                     :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "published",                         :default => false
    t.string   "source",                            :default => "form"
  end

  add_index "videos", ["user_id"], :name => "index_videos_on_user_id"

  create_table "website_urls", :force => true do |t|
    t.string  "name"
    t.integer "website_id"
  end

  create_table "websites", :force => true do |t|
    t.integer  "creator_id"
    t.string   "title",                                                                 :null => false
    t.string   "description",                         :default => "",                   :null => false
    t.string   "state",                :limit => 15
    t.string   "available_items"
    t.string   "logo_file_name",       :limit => 100
    t.string   "logo_content_type",    :limit => 50
    t.integer  "logo_file_size"
    t.string   "available_types"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "contact_email"
    t.integer  "home_page_id"
    t.integer  "mail_page_id"
    t.integer  "gallery_page_id"
    t.integer  "intro_page_id"
    t.string   "favicon_file_name"
    t.string   "favicon_content_type"
    t.string   "favicon_file_size"
    t.string   "layout_file_name"
    t.string   "layout_content_type"
    t.string   "layout_file_size"
    t.string   "sitemap_file_name"
    t.string   "sitemap_content_type"
    t.string   "sitemap_file_size"
    t.string   "body_size"
    t.string   "website_state",                       :default => "under_construction"
    t.string   "template",                            :default => "default"
  end

  add_index "websites", ["creator_id"], :name => "index_websites_on_creator_id"

  create_table "workspaces", :force => true do |t|
    t.integer  "creator_id"
    t.string   "title",                                            :null => false
    t.string   "description",                      :default => "", :null => false
    t.string   "state",             :limit => 15
    t.string   "available_items"
    t.string   "logo_file_name",    :limit => 100
    t.string   "logo_content_type", :limit => 50
    t.integer  "logo_file_size"
    t.string   "available_types"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "body"
  end

  add_index "workspaces", ["creator_id"], :name => "index_workspaces_on_creator_id"
  add_index "workspaces", ["state"], :name => "index_workspaces_on_state"

end
