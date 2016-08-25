if !STDIN.tty?
  ids = STDIN.readlines.map(&:to_i)
  STDIN.close
else
  ids = DetailedGuide.all.pluck(:document_id).uniq
end

documents = Document.where(id: ids)
dg_checks = documents.map { |doc| SyncChecker::Formats::DetailedGuideCheck.new(doc) }
checker = SyncChecker::SyncCheck.new(dg_checks, csv_file_path: ARGV[0])
checker.run
