change_note_updates = {
  # https://www.pivotaltracker.com/story/show/56594950
  234431 => "Corrected typo in title (£500 not £50) and updated June data.",
  234425 => "Added the data for July 2013.",
  235088 => "Added the data for July 2013.",
  222803 => "Added the data for June 2013.",
  222826 => "Added the data for May 2013.",
  210364 => "Added the data for May 2013.",
  202304 => "Added the data for April 2013.",
  202309 => "Added the data for March 2013.",

  # https://www.pivotaltracker.com/story/show/47441073
  176896 => "Overwrote the PDF file with the latest version.",

  # https://www.pivotaltracker.com/story/show/50642931
  16864  => "Formatting updated."
}

change_note_updates.each do |edition_id, new_change_note|
  puts "Updating change note on edition #{edition_id}"
  Edition.find(edition_id).update_attribute('change_note', new_change_note)
end
