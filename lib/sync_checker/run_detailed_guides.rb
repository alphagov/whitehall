# documents = Document.where(id: 293884)
documents = Document.where(id: DetailedGuide.all.pluck(:document_id).uniq.last(1000))
dg_checks = documents.map { |doc| SyncChecker::DetailedGuideCheck.new(doc) }
checker = SyncChecker::SyncCheck.new(dg_checks, csv_file_path: ARGV[0])
checker.run
