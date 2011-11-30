platform = Whitehall.platform
expected_platform = "preview"
abort("Wrong platform: #{platform}; expected #{expected_platform}") unless platform == expected_platform

topic_names = [
  "Business support",
  "economic growth",
  "export control",
  "Government-owned businesses[very draft]",
  "green economy",
  "public sector innovation"
]

puts "Removing associations with all documents for the following topics..."

topic_names.each do |topic_name|
  print "  Processing topic: #{topic_name}... "
  topic = Topic.find_by_name!(topic_name)
  topic.document_topics.destroy_all
  puts "done."
end

puts "...done."
