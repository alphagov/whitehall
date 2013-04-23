u = Unpublishing.find_by_slug('civil-contingencies-act-a-short-guide-revised')
if u
  print "Removing explanation from 'civil-contingencies-act-a-short-guide-revised' unpublishing"
  u.explanation = ''
  if u.save
    puts ". Done!"
  else
    puts ". ERROR - unpublishing no longer valid: #{u.errors.full_messages}"
  end
else
  puts "Unpublishing for 'civil-contingencies-act-a-short-guide-revised' not present - skipping!"
end
