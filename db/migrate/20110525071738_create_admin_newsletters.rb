class CreateAdminNewsletters < ActiveRecord::Migration
  def self.up
    create_table :newsletters ,:force=>true do |t|
      t.string  :title
      t.text    :news_letter_content
      t.timestamps
    end
  end

  def self.down
    drop_table :newsletters
  end
end
