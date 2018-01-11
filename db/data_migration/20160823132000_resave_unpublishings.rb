#this is an orphaned Unpublishing that used to belong to a WorldwidePriority
#which is a format we have removed.
Unpublishing.find(190).destroy

#Unpublishing was allowing alternative_url with trailing whitespace. This will
#clean the data by causing it to be stripped

current_unpublishing_id = nil
begin
  Unpublishing.all.each do |unpublishing|
    current_unpublishing_id = unpublishing.id
    unpublishing.save!
  end
rescue StandardError => e
  puts "Could not save #{current_unpublishing_id}, #{e.message}"
end
