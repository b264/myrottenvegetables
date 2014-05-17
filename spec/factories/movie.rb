FactoryGirl.define do
  factory :movie do
    title 'A Fake Title' # default values
    rating 'PG'
    release_date { 10.years.ago }
  end
  # in your specs
  #it 'should include rating and year' do
    #movie= FactoryGirl.build(:movie, :title => 'Milk')
    # etc.
  #end
