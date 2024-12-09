class Admin::EditionableTopicalEventsController < Admin::EditionsController
private

  def edition_class
    EditionableTopicalEvent
  end
end
