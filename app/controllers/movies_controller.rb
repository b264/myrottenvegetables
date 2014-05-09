class MoviesController < ApplicationController
  def index
    #default sort field
    @sort_by= 'title'
    if params[:sort_by].nil?
      params[:sort_by]= @sort_by
      @sorted_by_user= false
    else
      @sorted_by_user= true
    end
    Movie.accessible_attributes.each { |attr|
      if params[:sort_by]== attr
        @sort_by= attr
      end
    }
    @distinct_ratings= Movie.find(:all, :select => "DISTINCT(rating)", :order => 'rating DESC')
    @ratings= Hash.new
    number_selected= 0
    @distinct_ratings.each { |movie|
      @ratings[movie.rating]= '0'.to_boolean
      if params.has_key? movie.rating
        @ratings[movie.rating]= params[movie.rating].to_boolean
        number_selected+= 1
      end
    }
    if number_selected < 1
      # if nothing is selected, mark everything selected
      @distinct_ratings.each { |movie|
        @ratings[movie.rating]= '1'.to_boolean
      }
      # if nothing is selected, select everything
      @movies= Movie.find(:all, :order => params[:sort_by])
    else
      # custom selection
      @match_list= Array.new
      @ratings.each { |key, value|
        if value
          @match_list.push key
        end
      }
      @movies= Movie.where(:rating => @match_list).order(params[:sort_by])
    end
    #@params=params
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
  def action_notify(name, flag)
    flash.notice= name.to_s
    if flash.notice.length < 1
      flash.notice= 'Database entry'
    end
    action= caller[0][/`([^']*)'/, 1] #name of the method that called this one
    unless action.last(1) == 'e'
      action+= 'e' #append an e on the end of words not ending in e
    end
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
    fill_methods_by_hash! @movie, params[:movie]
    action_notify @movie.title, @movie.validated_save
  end
  def show
    @movie= Movie.find_by_id(params[:id])
  end
  def update
    @movie= Movie.find_by_id(params[:id])
    fill_methods_by_hash! @movie, params
    action_notify @movie.title, @movie.validated_save
  end
  def destroy
    @movie= Movie.find_by_id(params[:id])
    action_notify @movie.title, @movie.destroy
  end
end
