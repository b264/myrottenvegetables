class MoviesController < ApplicationController
  def index
    #starwars = Movie.create!(:title => 'Star Wars', :release_date => '25/4/1977', :rating => 'PG')
    @movies = Movie.all
  end
  def new
    @movie= Movie.new
  end
  def edit
    @movie= Movie.find_by_id(params[:id])
  end
  def fill_methods_by_hash!(object, hash)
    hash.each_pair { |key, value|
      eval (%{
        if object.respond_to? "#{key}"
          object.#{key}= value
        end
      })
    }
  end
  def action_notify(action, name, flag)
    flash.notice= name.to_s
    if flag
      flash.notice+= ' has been '+ action.to_s + 'd.'
    else
      flash.notice+= ' was not '+ action.to_s + 'd!'
    end
    redirect_to :movies
  end
  #CRUD actions below
  def create
    @movie= Movie.new
    #@movie.ttle
    fill_methods_by_hash! @movie, params[:movie]
    action_notify 'create', @movie.title, @movie.save
    #flash.notice= @movie.title.to_s
    #if @movie.save
    #  flash.notice+= ' has been created.'
    #else
    #  flash.notice+= ' was not created'
    #end
    #redirect_to :movies
  end
  def show
    @movie= Movie.find_by_id(params[:id])
  end
  def update
    @movie= Movie.find_by_id(params[:id])
    fill_methods_by_hash @movie, params
    flash.notice= @movie.title.to_s
    if @movie.save
      flash.notice+= ' has been saved.'
    else
      flash.notice+= ' was not saved'
    end
    redirect_to :movies
  end
  def destroy
    @movie= Movie.find_by_id(params[:id])
    flash.notice= @movie.title.to_s
    if @movie.destroy
      flash.notice+= ' has been deleted.'
    else
      flash.notice+= ' was not deleted'
    end
    redirect_to :movies
  end
end
