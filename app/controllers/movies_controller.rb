class MoviesController < ApplicationController
  def redirect_to_RESTful_URI
    flash.keep
    redirect_to movies_path(params), :method => :get
  end
  def force_clear_saved_session?
    # URI override to force-clear saved session information
    # http://server.domain/path/model?session_type=new
    if params.has_key? :session_type
      if params[:session_type]== 'new'
        return true
      end
    end
    return false
  end
  def force_clear_session
    params.delete :session_type
    reset_session_params
  end
  def reset_session_params
    session[:saved_params]= nil
  end
  def saved_parameters?
    if session[:saved_params]== nil
      return false
    end
    return true
  end
  def ensure_session_has_key
    unless session.has_key? :saved_params
      reset_session_params
    end
  end
  def new_filter_criteria_supplied?
    new_filter_criteria= false
    Movie.distinct_ratings.each { |rating|
      new_filter_criteria |= params.has_key? rating
    }
    return new_filter_criteria
  end
  def saved_filter_criteria?
    saved_filter_criteria= false
    Movie.distinct_ratings.each { |rating|
      saved_filter_criteria |= session[:saved_params].has_key? rating
    }
    return saved_filter_criteria
  end
  def restore_saved_filter_criteria
    Movie.distinct_ratings.each { |rating|
      params[rating]= '0'
      if session[:saved_params].has_key? rating
        params[rating]= session[:saved_params][rating]
      end
    }
  end
  def new_sort_criteria_supplied?
    params.has_key? :sort_by
  end
  def saved_sort_criteria?
    session[:saved_params].has_key? :sort_by
  end
  def restore_saved_sort_criteria
    params[:sort_by]= session[:saved_params][:sort_by]
  end
  def merge_parameters
    unless new_filter_criteria_supplied?
      if saved_filter_criteria?
        restore_saved_filter_criteria
      end
    end
    unless new_sort_criteria_supplied?
      if saved_sort_criteria?
        restore_saved_sort_criteria
      end
    end
    reset_session_params
  end
  def ratings_selected
    @ratings= Hash.new
    number_selected= 0
    Movie.distinct_ratings.each { |rating|
      # default is off
      @ratings[rating]= '0'.to_boolean
      if params.has_key? rating
        # use the supplied rating filter
        @ratings[rating]= params[rating].to_boolean
        add_to_saved_rating rating
        number_selected+= 1
      end
    }
    return number_selected
  end
  def add_to_saved_rating (rating)
    if session[:saved_params]== nil
      session[:saved_params] = {}
    end
    session[:saved_params][rating] = params[rating]
  end
  def sort_criteria
    #default sort field
    @sort_by= 'title'
    @sorted_by_user= false
    # enact each new sort criteria, if it's a valid field in the model
    Movie.accessible_attributes.each { |attr|
      if new_sort_criteria_supplied?
        if params[:sort_by]== attr
          @sort_by= attr
          #if @sorted_by_user
            session[:saved_params] = {:sort_by => attr}
            @sorted_by_user= true
          #end
        end
      end
    }
    return params[:sort_by]
  end
  def index
    ensure_session_has_key
    if force_clear_saved_session?
      force_clear_session
      redirect_to_RESTful_URI
    elsif saved_parameters?
      merge_parameters
      redirect_to_RESTful_URI
    # no saved paramters to parse, prepare for view render
    else
      if ratings_selected < 1
        # if nothing is selected, mark everything selected
        Movie.distinct_ratings.each { |rating|
          @ratings[rating]= '1'.to_boolean
        }
        # if nothing is selected, select everything
        @movies= Movie.find(:all, :order => sort_criteria)
      else
        # custom selection
        @match_list= Array.new
        @ratings.each { |key, value|
          if value
            @match_list.push key
          end
        }
        @movies= Movie.where(:rating => @match_list).order(sort_criteria)
      end
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
      flash.notice+= ' was NOT '+ action.to_s + 'd!'
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
