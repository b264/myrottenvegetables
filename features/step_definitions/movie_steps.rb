# Add a declarative step here for populating the DB with movies.

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

# Make sure that one string (regexp) occurs before or after another one
#   on the same page

Then /I should see "(.*)" before "(.*)"/ do |e1, e2|
  #  ensure that that e1 occurs before e2.
  #  page.body is the entire content of the page as a string.
  e1_position= /#{e1}/=~ page.body
  e2_position= /#{e2}/=~ page.body
  e1_position.should_not be_nil
  e2_position.should_not be_nil
  e1_position.should < e2_position
end

# Make it easier to express checking or unchecking several boxes at once
#  "When I uncheck the following ratings: PG, G, R"
#  "When I check the following ratings: G"

When /I (un)?check the following ratings: (.*)/ do |uncheck, rating_list|
  # HINT: use String#split to split up the rating_list, then
  #   iterate over the ratings and reuse the "When I check..." or
  #   "When I uncheck..." steps in lines 89-95 of web_steps.rb
end

Then /I should see all the movies/ do
  # Make sure that all the movies in the app are visible in the table
end
