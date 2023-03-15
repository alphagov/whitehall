module Admin::CorporateInformationPagesHelper
  include Admin::EditionsHelper

  def index_table_title_row(edition)
    title = edition.title
    title += " (#{edition.primary_locale})" if edition.non_english_edition?
    sanitize(title)
  end
end
