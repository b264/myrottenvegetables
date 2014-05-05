class CreateMovies < ActiveRecord::Migration
  #migrate up to this version schema
  def up
    create_table 'movies' do |t|
      t.string 'title'
      t.string 'rating'
      t.text 'description'
      t.datetime 'release_date'
      t.timestamps
    end
  end
  #migrate back, undo this migration
  def down
    drop_table 'movies'
  end
end
