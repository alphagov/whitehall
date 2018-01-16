Consultation.where(first_published_at: nil).each do |consultation|
  next unless consultation.document.ever_published_editions.any?
  next unless consultation.opening_at.present?

  public_at = consultation.make_public_at(consultation.opening_at.to_datetime)
  result = consultation.save(touch: false, validate: false)

  puts "Setting %s first_published_at to %s \n=> %s" %
    [consultation.inspect, public_at, result]
end

Consultation.where("date(first_published_at) > date(opening_at)").each do |consultation|
  next unless consultation.document.ever_published_editions.any?
  next unless consultation.opening_at.present?

  public_at = consultation.first_published_at = consultation.opening_at.to_datetime
  result = consultation.save(touch: false, validate: false)

  puts "Setting %s first_published_at to %s \n=> %s" %
    [consultation.inspect, public_at, result]
end
