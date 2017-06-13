class DocumentListExportWorker < WorkerBase
  def perform(filter_options, user_id)
    user = User.find(user_id)
    filter = create_filter(filter_options, user)
    csv = generate_csv(filter)
    send_mail(csv, user, filter)
  end

private

  def send_mail(csv, user, filter)
    Notifications.document_list(csv, user.email, filter.page_title).deliver_now
  end

  def create_filter(filter_options, user)
    Admin::EditionFilter.new(Edition, user, filter_options.symbolize_keys)
  end

  def generate_csv(filter)
    CSV.generate(col_sep: "|") do |csv|
      csv << DocumentListExportPresenter.header_row
      filter.each_edition_for_csv do |edition|
        presenter = DocumentListExportPresenter.new(edition)
        csv << presenter.row
      end
    end
  end
end
