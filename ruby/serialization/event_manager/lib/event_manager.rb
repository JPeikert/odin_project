require "csv"
require "sunlight/congress"
require "erb"

Sunlight::Congress.api_key = "e179a6973728c4dd3fb1204283aaccb5"


def clean_zipcode(zipcode)
	zipcode.to_s.rjust(5, "0")[0..4]
end

def clean_phone_number(phone_number)
  phone_number.to_s.gsub!(/\D/, '')

  if phone_number.length == 10
    phone_number
  elsif phone_number == 11 && phone_number[0] == 1
    phone_number[1..10]
  else
    "0"*10
  end
end

def legislators_by_zipcode(zipcode)
  Sunlight::Congress::Legislator.by_zipcode(zipcode)
end

def save_thank_you_letters(id, form_letter)
  Dir.mkdir("output") unless Dir.exist?("output")

  filename = "output/thanks_#{id}.html"

  File.open(filename, 'w') { |file| file.puts form_letter }
end

def popular_hours(registration_dates)
  hours = Hash.new(0)

  registration_dates.each do |regdate|
    date = DateTime.strptime(regdate, "%m/%d/%y %H:%M")
    hours[date.strftime("%H")] += 1
  end

  hours = hours.sort_by {|key, value| value }.reverse

  puts "Popularity of hours"
  hours.each do |hour|
    puts "#{hour[0]}: #{hour[1]}"
  end
end

def popular_days(registration_dates)
  days = Hash.new(0)

  registration_dates.each do |regdate|
    date = DateTime.strptime(regdate, "%m/%d/%y %H:%M")
    days[date.strftime("%A")] += 1
  end

  days = days.sort_by {|key, value| value }.reverse

  puts "Popularity of week days"
  days.each do |day|
    puts "#{day[0]}: #{day[1]}"
  end
end

puts "EventManager initialized."

contents = CSV.open("event_attendees.csv", headers: true, header_converters: :symbol)

template_letter = File.read("form_letter.erb")
erb_template = ERB.new(template_letter)
registration_dates = []

contents.each do |row|
  id = row[0]
	name = row[:first_name]
	zipcode = clean_zipcode(row[:zipcode])
  phone_number = clean_phone_number(row[:homephone])
  registration_dates << row[:regdate]
	legislators = legislators_by_zipcode(zipcode)

  form_letter = erb_template.result(binding)
	
  save_thank_you_letters(id, form_letter)
end

puts "Letters saved"

popular_hours(registration_dates)
popular_days(registration_dates)