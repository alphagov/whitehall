[400_612,
 403_646,
 407_080,
 409_918,
 403_691,
 407_085,
 407_171,
 409_867,
 403_708,
 403_688,
 406_620,
 409_891,
 403_706,
 407_151,
 409_876,
 403_683,
 406_383,
 407_228,
 403_704,
 407_077,
 409_923,
 403_695,
 407_179,
 407_079,
 403_102,
 400_399,
 403_710,
 406_608,
 419_802,
 420_932,
 420_936,
 398_547,
 386_766].each do |id|
  if (edition = Edition.where(id:).first)
    if edition.archived?
      if edition.unpublishing.present?
        puts "#{id}: Unpublishing already exists; skipping"
      else
        unpublishing = edition
                         .build_unpublishing(
                           unpublishing_reason_id: UnpublishingReason::Withdrawn.id,
                           explanation: "This content is no longer current.",
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
