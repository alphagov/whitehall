detailed_guide = DetailedGuide.where(id: 621_922).first

if detailed_guide
  Whitehall.edition_services.deleter(detailed_guide).perform!
end
