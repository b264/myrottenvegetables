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

Then /I should see "(.*)" before "(.*)"/ do |e1, e2|
  e1_position= /#{e1}/=~ page.body
  e2_position= /#{e2}/=~ page.body
  e1_position.should_not be_nil
  e2_position.should_not be_nil
  e1_position.should < e2_position
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
  movies.count.should be amount.to_i
  #expect(movies.count).to eq number
end

Then(/^I should see "(.*?)" and "(.*?)" rated movies$/) do |arg1, arg2|
  pending # express the regexp above with the code you wish you had
end

Then(/^I should not see "(.*?)" and "(.*?)" rated movies$/) do |arg1, arg2|
  pending # express the regexp above with the code you wish you had
end
