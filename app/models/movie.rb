class Movie < ActiveRecord::Base
  attr_accessible :title, :rating, :description, :release_date
  #sort ascending by title unless specified
  default_scope order('title ASC')
end
