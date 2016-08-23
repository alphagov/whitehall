documents = Document.where(id: DetailedGuide.all.pluck(:document_id).uniq)
dg_checks = documents.map { |doc| SyncChecker::DetailedGuideCheck.new(doc) }
checker = SyncChecker::SyncCheck.new(dg_checks)
checker.run
checker.failures.each do |failure|
  puts failure.inspect
end
