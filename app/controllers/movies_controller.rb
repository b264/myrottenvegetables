class MoviesController < ApplicationController
  def index
    #starwars = Movie.create!(:title => 'Star Wars', :release_date => '25/4/1977', :rating => 'PG')
    @movies = Movie.all
  end
  def create
  end
  def new
  end
  def edit
  end
  def show
  end
  def update
  end
  def destroy
  end
end
