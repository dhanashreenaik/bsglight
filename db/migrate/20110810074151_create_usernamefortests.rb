class CreateUsernamefortests < ActiveRecord::Migration
  def self.up
    create_table :usernamefortests do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :usernamefortests
  end
end
