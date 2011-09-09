class CreateUsersTable < ActiveRecord::Migration

  def self.up
    create_table :users do |t|
      t.string   :login,               :limit => 40, :null => false
      t.string   :email,               :limit => 50, :null => false
      t.string   :avatar_file_name,    :limit => 100
      t.string   :avatar_content_type, :limit => 50
      t.integer  :avatar_file_size
      t.datetime :avatar_updated_at
      t.datetime :last_connected_at
			t.string   :state, :limit => 15
      t.string   :u_layout,            :limit => 30
      t.integer  :u_per_page
      t.string   :u_language,          :limit => 10
      t.string   :crypted_password,    :limit => 40
      t.string   :salt,                :limit => 40
      t.datetime :activated_at
      t.string   :activation_code,     :limit => 40
      t.string   :password_reset_code, :limit => 40
      t.integer  :system_role_id
      t.string   :remember_token,      :limit => 40
      t.datetime :remember_token_expires_at
      t.timestamps
    end
    add_index :users, :login, :unique => true
    add_index :users, :system_role_id
  end

  def self.down
    drop_table :users
  end
end

