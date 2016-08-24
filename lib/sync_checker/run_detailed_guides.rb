documents = Document.where(id: DetailedGuide.all.pluck(:document_id).uniq)
dg_checks = documents.map { |doc| SyncChecker::DetailedGuideCheck.new(doc) }
checker = SyncChecker::SyncCheck.new(dg_checks, csv_file_path: ARGV[0])
checker.run
