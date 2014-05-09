class MoviesController < ApplicationController
  def index
    # override to clear session information
    if params.has_key? :session_type
      if params[:session_type]== 'new'
        if session.has_key? :saved_params
          session[:saved_params]= nil
        end
        #params[:session_type]= 'saved'
        params.delete :session_type
        flash.keep
        redirect_to movies_path(params), :method => :get
      end
    end
    # if they have saved parameters stick them in a RESTful URI and redirect
    if session.has_key? :saved_params
      unless session[:saved_params]== nil
        session[:saved_params].each { |key, value|
          params[key]= value
        }
        #session.delete(:saved_params)
        session[:saved_params]= nil
        flash.keep
        redirect_to movies_path(params), :method => :get
      end
    end
    #default sort field
    @sort_by= 'title'
    #if params[:sort_by].nil?
      #params[:sort_by]= @sort_by
      @sorted_by_user= false
    #else
    #  @sorted_by_user= true
    #  #session[:saved_params] = {:sort_by => params[:sort_by]}
    #end
    # enact a new sort criteria, if it's a valid field in the model
    Movie.accessible_attributes.each { |attr|
      if params.has_key? :sort_by
        if params[:sort_by]== attr
          @sort_by= attr
          #if @sorted_by_user
            session[:saved_params] = {:sort_by => attr}
            @sorted_by_user= true
          #end
        end
      end
    }
    # did the user filter the ratings
    @ratings= Hash.new
    number_selected= 0
    Movie.distinct_ratings.each { |rating|
      @ratings[rating]= '0'.to_boolean
      if params.has_key? rating
        # use the supplied rating filter
        @ratings[rating]= params[rating].to_boolean
        unless session.has_key? :saved_params
          session[:saved_params] = {}
        end
        session[:saved_params][rating] = params[rating]
        number_selected+= 1
      end
    }
    if number_selected < 1
      # if nothing is selected, mark everything selected
      Movie.distinct_ratings.each { |rating|
        @ratings[rating]= '1'.to_boolean
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
