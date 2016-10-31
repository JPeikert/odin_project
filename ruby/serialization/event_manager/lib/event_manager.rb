puts "EventManager initialized.\n\n"

lines = File.exist?("event_attendees.csv") ? File.readlines("event_attendees.csv") : "Error - file not found"

lines.each do |line|
  columns = line.split(",")
  puts columns[2]
end