class MoviesController < ApplicationController
  def index
    #starwars = Movie.create!(:title => 'Star Wars', :release_date => '25/4/1977', :rating => 'PG')
    @movies = Movie.all
  end
  def create
    
  end
  def new
    @movie= Movie.new
  end
  def edit
    @movie= Movie.find_by_id(params[:id])
  end
  def show
    @movie= Movie.find_by_id(params[:id])
    #@movies = Movie.all
  end
  def update
  end
  def destroy
    @movie= Movie.find_by_id(params[:id])
    flash.notice= @movie.title
    success= @movie.destroy
    if success then
      flash.notice+= ' has been deleted.'
    else
      flash.notice+= ' was not deleted'
    end
    index
  end
end
