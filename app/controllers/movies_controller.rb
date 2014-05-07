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
  end
  def update
    @movie= Movie.find_by_id(params[:id])
    params.each_pair { |key, value|
      eval (%{
        if @movie.respond_to?("#{key}")
          @movie.#{key}= value
        end
      })
    }
    flash.notice= @movie.title
    if @movie.save
      flash.notice+= ' has been saved.'
    else
      flash.notice+= ' was not saved'
    end
    redirect_to :movies
  end
  def destroy
    @movie= Movie.find_by_id(params[:id])
    flash.notice= @movie.title
    if @movie.destroy
      flash.notice+= ' has been deleted.'
    else
      flash.notice+= ' was not deleted'
    end
    index
  end
end
