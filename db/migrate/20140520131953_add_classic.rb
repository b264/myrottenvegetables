class AddClassic < ActiveRecord::Migration
  def up
    add_column :movies, :classic, :boolean, default: false
  end
  def down
    remove_column :movies, :classic
  end
end
