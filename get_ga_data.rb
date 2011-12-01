#!/usr/bin/env ruby
# encoding: UTF-8

require 'garb'

#Set up the connection
Garb::Session.login('mygoogleusername', 'mypassword', :account_type => "GOOGLE")

profile = Garb::Management::Profile.all.detect {|profiles| profiles.web_property_id == 'UA-myid'}

#Define which statistics are wanted
class GoogleSearches
  extend Garb::Model

  metrics :visits
  dimensions :keyword
end

#You can only fetch 10,000 results at a time from the API
#So I had to break this into five pieces
(0..4).each do |i|

	iterator = i.to_s
		
	resultset = GoogleSearches.results(profile, :limit => 10000,
									:offset => (i*10000)+1,
									:start_date =>  Date.today - 180,
									:end_date => Date.today,
									:filters => {:source.contains => 'google'},
									:sort => :visits.desc
							)

    #Write the results in a csv file, 
    #stripping out any commas in the search terms themselves
	open('googleterms'+iterator+'.csv', 'w:UTF-8') do |f|
		
		resultset.each do |row|
		  f.puts row.keyword.gsub(/,/u,' ') << "," << row.visits
		end

	end

end




