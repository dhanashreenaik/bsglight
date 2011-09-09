class Addeditionnumberandnametocomp < ActiveRecord::Migration
  def self.up
    add_column :competitions_users, :fworkedname, :integer
    add_column :competitions_users, :sworkedname, :integer
    add_column :competitions_users, :tworkedname, :integer
    add_column :competitions_users, :foworkedname, :integer
    add_column :competitions_users, :fiworkedname, :integer
    add_column :competitions_users, :siworkedname, :integer
    add_column :competitions_users, :seworkedname, :integer
    add_column :competitions_users, :eiworkedname, :integer
    add_column :competitions_users, :niworkedname, :integer
    add_column :competitions_users, :teworkedname, :integer
    add_column :competitions_users, :fworkednumber, :integer
    add_column :competitions_users, :sworkednumber, :integer
    add_column :competitions_users, :tworkednumber, :integer
    add_column :competitions_users, :foworkednumber, :integer
    add_column :competitions_users, :fiworkednumber, :integer
    add_column :competitions_users, :siworkednumber, :integer
    add_column :competitions_users, :seworkednumber, :integer
    add_column :competitions_users, :eiworkednumber, :integer
    add_column :competitions_users, :niworkednumber, :integer
    add_column :competitions_users, :teworkednumber, :integer
  end

  def self.down
    remove_column :competitions_users, :fworkedname
    remove_column :competitions_users, :sworkedname
    remove_column :competitions_users, :tworkedname
    remove_column :competitions_users, :foworkedname
    remove_column :competitions_users, :fiworkedname
    remove_column :competitions_users, :siworkedname
    remove_column :competitions_users, :seworkedname
    remove_column :competitions_users, :eiworkedname
    remove_column :competitions_users, :niworkedname
    remove_column :competitions_users, :teworkedname
    remove_column :competitions_users, :fworkednumber
    remove_column :competitions_users, :sworkednumber
    remove_column :competitions_users, :tworkednumber
    remove_column :competitions_users, :foworkednumber
    remove_column :competitions_users, :fiworkednumber
    remove_column :competitions_users, :siworkednumber
    remove_column :competitions_users, :seworkednumber
    remove_column :competitions_users, :eiworkednumber
    remove_column :competitions_users, :niworkednumber
    remove_column :competitions_users, :teworkednumber
  end
end
