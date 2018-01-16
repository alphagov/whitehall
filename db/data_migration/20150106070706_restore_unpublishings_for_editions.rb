[400612, 403646, 407080, 409918, 403691, 407085, 407171, 409867, 403708, 403688,
 406620, 409891, 403706, 407151, 409876, 403683, 406383, 407228, 403704, 407077,
 409923, 403695, 407179, 407079, 403102, 400399, 403710, 406608, 419802, 420932,
 420936, 398547, 386766].each do |id|
  if (edition = Edition.where(id: id).first)
    if edition.archived?
      if edition.unpublishing.present?
        puts "#{id}: Unpublishing already exists; skipping"
      else
        unpublishing = edition
                         .build_unpublishing(
                           unpublishing_reason_id: UnpublishingReason::Withdrawn.id,
                           explanation: 'This content is no longer current.'
                         )
        unpublishing.save!
        puts "#{id}: Unpublishing created"
      end
    else
      puts "#{id}: Not archived; skipping"
    end
  else
    puts "Couldn't find Edition with id: #{id}"
  end
end
