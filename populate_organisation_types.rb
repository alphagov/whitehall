[
  "Ministerial department",
  "Non-ministerial department",
  "Executive agency",
  "Executive non-departmental public body",
  "Advisory non-departmental public body",
  "Tribunal non-departmental public body",
  "Public corporation",
  "Independent monitoring body",
  "Ad-hoc advisory group",
  "Other"
].each do |name|
  OrganisationType.create!(name: name)
end