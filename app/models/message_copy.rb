class MessageCopy < ActiveRecord::Base
  belongs_to :message
  belongs_to :recipient, :class_name => "User"
  belongs_to :mailfolder
  belongs_to :emaillabel
  delegate   :author, :created_at, :subject, :body, :recipients, :to => :message
  scope_out  :deleted
  scope_out  :not_deleted, :conditions => ["deleted IS NULL OR deleted = ?", false]
  scope_out  :not_deleted_and_not_labeled, :conditions => ["(deleted IS NULL OR deleted = ?) and (labeled IS NULL OR labeled = ?)", false,false]
  scope_out  :flag
  scope_out  :not_labeled, :conditions => ["(deleted IS NULL OR deleted = ? )and (labeled IS NULL OR labeled = ?)", false,false]
  
end
