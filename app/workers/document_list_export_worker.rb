class DocumentListExportWorker < WorkerBase
  sidekiq_options queue: 'export_documents_list'

  def perform(filter_options, user_id)
    user = User.find(user_id)
    filter = create_filter(filter_options, user)

    Tempfile.open("document_list_export_worker") do |file|
      file.unlink
      csv = generate_csv(filter, file)
      send_mail(csv, user, filter)
    end
  end

private

  def send_mail(csv, user, filter)
    Notifications.document_list(csv, user.email, filter.page_title).deliver_now
  end

  def create_filter(filter_options, user)
    Admin::EditionFilter.new(Edition, user, filter_options.symbolize_keys.merge(include_unpublishing: true))
  end

  def generate_csv(filter, csv_file)
    csv = CSV.new(csv_file)
    csv << DocumentListExportPresenter.header_row
    filter.each_edition_for_csv do |edition|
      presenter = DocumentListExportPresenter.new(edition)
      csv << presenter.row
    end

    csv_file.rewind
    csv_file.read
  end
end
