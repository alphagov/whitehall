valid = true
DocumentRelation.all.each do |dr|
  unless dr.valid?
    valid = false
    puts "DocumentRelation with ID: #{dr.id} is invalid: #{dr.errors.full_messages}"
  end
end
unless valid
  abort "*** Error: Some DocumentRelations were invalid"
end
