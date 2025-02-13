class ContentBlockManager::ContentBlockEdition::Show::PublicationDetailsSummaryCardComponent < ViewComponent::Base
  def initialize(content_block_edition:)
    @content_block_edition = content_block_edition
  end

private

  attr_reader :content_block_edition

  def title
    "Publication details"
  end

  def rows
    [
      status_item,
    ]
  end

  def summary_card_actions
    [
      {
        label: "Edit",
        href: helpers.content_block_manager.content_block_manager_content_block_workflow_path(id: content_block_edition.id, step: :schedule_publishing),
      },
    ]
  end

  def scheduled_value
    I18n.l(content_block_edition.scheduled_publication, format: :long_ordinal)
  end

  def status_item
    if content_block_edition.scheduled_publication
      {
        key: "Scheduled date and time",
        value: scheduled_value,
      }
    else
      {
        key: "Publish date",
        value: I18n.l(Time.zone.today, format: :long_ordinal),
      }
    end
  end
end
