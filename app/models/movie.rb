class Movie < ActiveRecord::Base
  attr_accessible :title, :rating, :release_date, :description
  def self.default_scope
    #sort ascending by title
    #order('title ASC')
  end
  def date_formatted
    if self.release_date.nil?
      ''
    else
      self.release_date.strftime("%d %B %Y")
    end
  end
  def date_formatted=(new_value)
    @release_date= Date.parse(new_value)
  end
  def validated_save
    if self.title.empty? or blacklisted_rating? self.rating
      #refuse to save without a title at a minimum
      return false
    else
      return self.save
    end
  end
  def blacklisted_rating? (rating)
    # these are reserved and will cause bugs if used
    if    rating== 'sort_by'
    elsif rating== 'utf8'
    elsif rating== 'commit'
    elsif rating== '_method'
    elsif rating== 'authenticity_token'
    else
      return false
    end
    return true
  end
  def self.distinct_ratings
    ratings= Array.new
    Movie.find(:all, :select => "DISTINCT(rating)", :order => 'rating DESC').each { |movie|
      ratings.push movie.rating
    }
    ratings
  end
end
