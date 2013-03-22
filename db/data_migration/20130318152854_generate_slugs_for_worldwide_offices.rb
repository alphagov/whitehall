WorldwideOffice.find_each do |office|
  office.slug = office.title.parameterize
  office.save!
end
