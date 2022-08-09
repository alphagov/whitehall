WorldLocation.pluck(:id).each do |id|
  print "."
  WorldLocationNewsWorker.perform_async_in_queue("bulk_republishing", id)
end
