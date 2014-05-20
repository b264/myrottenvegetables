class CreateMovies < ActiveRecord::Migration
#skeleton created by bash: rails generate migration AddClassic
  #migrate up to this version schema
  def up
    create_table 'movies' do |t|
      t.string 'title'
      t.string 'rating'
      t.text 'description'
      t.datetime 'release_date'
      #add fields to let rails automatically track when records are add/modified
      t.timestamps
    end
  end
  #migrate back, undo this migration
  def down
    drop_table 'movies'
  end
end
