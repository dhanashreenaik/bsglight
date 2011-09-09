# This module is defining the different methods required by an Object model to acts like an Item.
# It is so defining the mixin method that will include all these required methods inside this Object model.
#
module ActsAsItem
  module ModelMethods
    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      # Mixin adding initialisation and definition of an item model
      #
      # This method initialize a model by mixin of the specified methods.
      #
      # Usage :
      # app/models/article.rb
      #     class Article < ActiveRecord::Base
      #      acts_as_item
      #     end
      def acts_as_item
				# Mixin method alloing to make easy search on the model (see Authorizable::ModelMethods for more)
				acts_as_authorizable
        # Mixin to add ActsAsRateable methods inside the model
        acts_as_rateable
				# Mixin to add ActsAsKeywordable methods inside the model
				acts_as_keywordable
				# Mixin to add ActsAsCommentable methods inside the model
				acts_as_commentable
				# Mixin method use to get this object search (see Searchable::ModelMethods for more)
				acts_as_searchable :full_text_fields => [:title, :description, :keywords_list],
					:conditionnal_attribute => []
        CONTAINERS.each do |container|
          # Relation N-1 with the 'items' table (Join table)
          has_many "items_#{container.pluralize}".to_sym, :as => :itemable, :dependent => :destroy
          # Relation N-1 getting the Workspace objects through 'item' table
          has_many "#{container.pluralize}".to_sym, :through => "items_#{container.pluralize}".to_sym
        end
				# Relation 1-N with 'users' table
        belongs_to :user
        # Validation of the presence of these fields
        validates_presence_of	:title, :user
        # Valdation of the fact that the item is associated to one or more workspaces throught items table
        validates_presence_of :workspace_ids, :message => I18n.t('item.common_word.select_at_least_one_workspace') #"Sélectionner au moins un espace de travail"
        
        # Validation of fields not in format of
        validates_not_format_of :title, :description, :with => /(#{SCRIPTING_TAGS})/
        
        named_scope :published,
         :conditions => {:published => true}
 

				# Inclusion of the instance methods inside the mixin
        include ActsAsItem::ModelMethods::InstanceMethods
        
      end
      
      # Label is used to return the name of the item type.
      #
      # Usage :
      # <tt>Image.label</tt>
      # will return "Image"
			def label
				I18n.t("general.item.#{self.model_name.underscore}")
			end

    end

    module InstanceMethods

      def all_containers
				res = []
				CONTAINERS.each do |cont|
					res << self.send(cont.pluralize.to_sym)
				end
				return res
			end
      # Generally icons are used to enchance visual simplicity to the User.
      #
      # Icon is used to associate every item type with image thumbnail of size 32x32px in default back office view.
      #
      # Usage :
      # <tt>article.icon</tt>
      # will return "/item_icons/article.png
      def icon
        self.class.icon
      end

      # Assign Worksapces to current Item ( One Item can be associated with many Worksapces)
      #
      # Usage :
      # <tt>article.assoicated_workspaces = [workspace1.id, workspace2.id]</tt>
      # will assign workspaces to the item
			# TODO use the generic methods
#      CONTAINERS.each do |container|
#        define_method "associated_#{container.pluralize}=" do |container_ids|
#          tmp = container_ids.uniq
#          if self.id
#            self.send("items_#{container.pluralize}").each do |i|
#              i.delete unless tmp.delete(i.id.to_s)
#            end
#            tmp.each do |cid|
#              "items_#{container.pluralize}".classify.constantize.create("#{container}_id".to_sym => cid, :itemable_id => self.id, :itemable_type => self.class.to_s)
#            end
#          else
#            if !tmp.blank?
#              container_ids.collect { |cid| self.send("items_#{container.pluralize}").build("#{container}_id".to_sym => cid) }
#            end
#          end
#        end
#      end
      
    end
  end
end
