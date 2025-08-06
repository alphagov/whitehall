module HistoricContentConcern
  extend ActiveSupport::Concern

  def forbid_editing_of_historic_content!
    # We do this rather than relying on `enforce_permissions!` to be able
    # to redirect with a nice message rather than just "permission denied".
    if @edition.historic? && !can?(:update, @edition)
      redirect_to [:admin, @edition],
                  { flash: { alert: "This document is in <a href='https://www.gov.uk/guidance/how-to-publish-on-gov-uk/creating-and-updating-pages#history-mode' class='govuk-link'>history mode</a>. Please contact your GOV.UK lead or managing editor if you need to change it.", html_safe: true } }
    end
  end
end
