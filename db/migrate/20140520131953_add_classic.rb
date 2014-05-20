class AddClassic < ActiveRecord::Migration
#skeleton created by bash: rails generate migration AddClassic
  def up
    add_column :movies, :classic, :boolean, default: false
  end
  def down
    remove_column :movies, :classic
  end
end
