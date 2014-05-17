Given /the following movies exist/ do |movies_table|
  movies_table.hashes.each do |hash|
    # each returned element will be a hash whose key is the table header.
    movie= Movie.new
    movie.title=hash[:title]
    movie.rating=hash[:rating]
    movie.release_date=hash[:release_date]
    movie.description=hash[:description]
    movie.validated_save
  end
end

Then /I should (not )?see "(.*)" before "(.*)"/ do |not_see, e1, e2|
  e1_position= /#{e1}/=~ page.body
  e2_position= /#{e2}/=~ page.body
  e1_position.should_not be_nil
  e2_position.should_not be_nil
  unless not_see
    e1_position.should < e2_position
  else
    e1_position.should > e2_position
  end
end

When /I (un)?check the following ratings: (.*)/ do |uncheck, rating_list|
  rating_list.to_s.split(", ").each do |rating|
    if uncheck
      step "I uncheck \"#{rating}\""
    else
      step "I check \"#{rating}\""
    end
  end
end

Then /I should see exactly (.*) movies/ do |amount|
  movies= Movie.all
  visible_movies= 0
  movies.each do |movie|
    movie_position= /#{movie.title}/=~ page.body
    unless movie_position== nil
      visible_movies+= 1
    end
  end 
  visible_movies.should be amount.to_i
end

Then(/^I should (not )?see "(.*?)" and "(.*?)" rated movies$/) do |be_hidden, rating1, rating2|
  ratings_selected=[rating1, rating2]
  movies= Movie.all
  ratings_selected.each do |rating|
    movies.each do |movie|
      movie_position= /#{movie.title}/=~ page.body
      if movie.rating== rating
        if be_hidden
          movie_position.should be_nil
        else
          movie_position.should_not be_nil
        end
      end
    end
  end
end
