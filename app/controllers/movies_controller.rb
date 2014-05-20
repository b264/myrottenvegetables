class MoviesController < ApplicationController
  # database CRUD actions below
  def create
    @movie= Movie.new
    fill_attribs_by_hash! @movie, params[:movie]
    action_notify @movie.title, @movie.validated_save
  end
  def show
    @movie= Movie.find_by_id(params[:id])
  end
  def update
    @movie= Movie.find_by_id(params[:id])
    fill_attribs_by_hash! @movie, params
    action_notify @movie.title, @movie.validated_save
  end
  def destroy
    @movie= Movie.find_by_id(params[:id])
    action_notify @movie.title, @movie.destroy
  end
  # CRUD accessories
  def new
    # no information to feed view
  end
  def edit
    @movie= Movie.find_by_id(params[:id])
  end 
  def index
    ensure_session_has_key
    if force_clear_saved_session?
      force_clear_session
      redirect_to_RESTful_URI
    elsif saved_parameters?
      merge_parameters
      redirect_to_RESTful_URI
    else
      # send to view
      @movies= Movie.where(:rating => match_list).order(sort_criteria)
    end
  end
  # other routes
  def search_tmdb
    Movie.find_in_tmdb(params[:search_terms])
  end
  # methods without URI routing assigned
  def force_clear_saved_session?
    # URI parameters override to force-clear saved session information
    # http://server.domain/path/model?session_type=new
    if params.has_key? :session_type
      if params[:session_type]== 'new'
        return true
      end
    end
    return false
  end
  def match_list
    match_array= Array.new
    ratings_selected.each_pair { |rating, value|
      # if nothing is selected, select everything
      if value or (num_ratings_selected < 1)
        match_array.push rating
      end
    }
    return match_array
  end
  def action_notify(name, flag)
    flash.notice= name.to_s
    if flash.notice.length < 1
      flash.notice= 'Database entry'
    end
    action= caller[0][/`([^']*)'/, 1] #name of the method that called this one
    unless action.last(1)== 'e'
      action+= 'e' #append an e on the end of words not ending in e
    end
    if flag
      flash.notice+= ' has been ' + action.to_s + 'd.'
    else
      flash.notice+= ' was NOT ' + action.to_s + 'd!'
    end
    redirect_to movies_path(), :method => :get
  end
  def fill_methods_by_hash!(object, hash)
    # warning: unsafe; see fill_attribs_by_hash!
    raise SecurityError, 'Obsolete method called'
    hash.each_pair { |key, value|
      eval (%{
        if object.respond_to? "#{key}"
          object.#{key}= value
        end
      })
    }
  end
  def fill_attribs_by_hash! (model_instance_object, hash)
    model_instance_object.class.accessible_attributes.each { |attr|
      unless attr.empty?
        eval (%{
          if hash.has_key? "#{attr}"
            if model_instance_object.respond_to? "#{attr}="
              model_instance_object.#{attr}= hash["#{attr}"]
            end
          end
        })
      end
    }
  end
  def redirect_to_RESTful_URI
    flash.keep
    redirect_to movies_path(params), :method => :get
  end
  def force_clear_session
    params.delete :session_type
    reset_saved_params
  end
  def reset_saved_params
    session[:saved_params]= Hash.new
  end
  def saved_parameters?
    if session[:saved_params].empty?
      return false
    end
    return true
  end
  def ensure_session_has_key
    unless session.has_key? :saved_params
      reset_saved_params
    end
  end
  def new_filter_criteria_supplied?
    new_filter_criteria= false
    Movie.distinct_ratings.each { |rating|
      new_filter_criteria ||= params.has_key? rating
    }
    return new_filter_criteria
  end
  def new_sort_criteria_supplied?
    return params.has_key? :sort_by
  end
  def saved_filter_criteria?
    saved_filter_criteria= false
    Movie.distinct_ratings.each { |rating|
      saved_filter_criteria ||= session[:saved_params].has_key? rating
    }
    return saved_filter_criteria
  end
  def saved_sort_criteria?
    session[:saved_params].has_key? :sort_by
  end
  def restore_saved_filter_criteria
    Movie.distinct_ratings.each { |rating|
      if session[:saved_params].has_key? rating
        params[rating]= session[:saved_params][rating]
      end
    }
  end
  def restore_saved_sort_criteria
    params[:sort_by]= session[:saved_params][:sort_by]
  end
  def merge_parameters
    unless new_sort_criteria_supplied?
      if saved_sort_criteria?
        restore_saved_sort_criteria
      end
    end
    unless new_filter_criteria_supplied?
      if saved_filter_criteria?
        restore_saved_filter_criteria
      end
    end
    reset_saved_params
  end
  def ratings_selected
    @ratings= Hash.new
    Movie.distinct_ratings.each { |rating|
      if params.has_key? rating
        # use the supplied rating filter
        @ratings[rating]= params[rating].to_boolean
        save_criteria rating
      else
        @ratings[rating]= '0'.to_boolean
      end
    }
    return @ratings
  end
  def num_ratings_selected
    number_selected= 0
    ratings_selected.each_pair { |rating, value|
      if value
        number_selected+= 1
      end
    }
    @num_selected= number_selected
    return number_selected
  end
  def save_criteria (key)
    ensure_session_has_key
    session[:saved_params][key] = params[key]
    return params[key]
  end
  def sort_criteria
    # set default sort field to first column
    @sort_by= ''
    Movie.accessible_attributes.each { |attr|
      unless attr.empty?
        if @sort_by.empty?
          @sort_by= attr
        end
      end
    }
    @sorted_by_user= false
    if new_sort_criteria_supplied?
      # enact new sort criteria, if it's a valid field in the model
      Movie.accessible_attributes.each { |attr|
        unless attr.empty?
          if params[:sort_by]== attr
            @sort_by= save_criteria :sort_by
            @sorted_by_user= true
          end
        end
      }
    end
    return @sort_by
  end
end
