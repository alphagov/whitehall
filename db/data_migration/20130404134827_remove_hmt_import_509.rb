i = Import.find_by_id(509)
if i
  print "Removing import 509"
  i.destroy
  if i.destroyed?
    puts ". Done!"
  else
    puts ". ERROR - import could not be deleted!"
  end
else
  pute "Import 509 not present - skipping!"
end
