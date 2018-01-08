#These are detailed guides that have been unpublished and then quickly
#submitted and/or rejected. This means they don't get republished correctly
#during migration.

DetailedGuide.where(id: [629523, 516694, 437572]).each do | detailed_guide |
  detailed_guide.state = "draft"
  detailed_guide.save!
end
