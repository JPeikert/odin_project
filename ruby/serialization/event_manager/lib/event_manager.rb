require "csv"
require "sunlight/congress"

Sunlight::Congress.api_key = "e179a6973728c4dd3fb1204283aaccb5"

def clean_zipcode(zipcode)
	zipcode.to_s.rjust(5, "0")[0..4]
end

puts "EventManager initialized.\n\n"

contents = CSV.open("event_attendees.csv", headers: true, header_converters: :symbol)

contents.each do |row|
	name = row[:first_name]
	zipcode = clean_zipcode(row[:zipcode])

	legislators = Sunlight::Congress::Legislator.by_zipcode(zipcode)
	
	puts "#{name} - #{zipcode} - #{legislators}"
end
# lines = File.exist?("event_attendees.csv") ? File.readlines("event_attendees.csv") : "Error - file not found"

# lines.each_with_index do |line, index|
# 	next if index == 0
#   columns = line.split(",")
#   puts columns[2]
# end