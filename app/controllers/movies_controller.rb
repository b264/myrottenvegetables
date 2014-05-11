class MoviesController < ApplicationController
  def index
    unless session.has_key? :saved_params
      reset_session_params
    end
    # URI override to force clear saved session information
    if params.has_key? :session_type
      if params[:session_type]== 'new'
        reset_session_params
        params.delete :session_type
        flash.keep
        redirect_to movies_path(params), :method => :get
      end
    end
    # if they have saved parameters stick them in a RESTful URI and redirect
    unless session[:saved_params]== nil
      # have new filter criteria been supplied
      new_filter_criteria= false
      Movie.distinct_ratings.each { |rating|
        new_filter_criteria |= params.has_key? rating
      }
      # have we some saved filter criteria
      saved_filter_criteria= false
      Movie.distinct_ratings.each { |rating|
        saved_filter_criteria |= session[:saved_params].has_key? rating
      }
      unless new_filter_criteria
        if saved_filter_criteria
          # put saved filter criteria back in place
          Movie.distinct_ratings.each { |rating|
            params[rating]= '0'
            if session[:saved_params].has_key? rating
              params[rating]= session[:saved_params][rating]
            end
          }
        end
      end
      # if new sort criteria hasn't been requested
      unless params.has_key? :sort_by
        # do we have saved sort criteria
        if session[:saved_params].has_key? :sort_by
          # put old sort criteria back
          params[:sort_by]= session[:saved_params][:sort_by]
        end
      end
      reset_session_params
      flash.keep
      redirect_to movies_path(params), :method => :get
    # no saved paramters to parse, prepare for view render
    else
      #default sort field
      @sort_by= 'title'
      @sorted_by_user= false
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
          if session[:saved_params]== nil
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
  end
  def reset_session_params
    session[:saved_params]= nil
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
