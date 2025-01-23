class ContentBlockManager::Shared::SchedulePublishingComponent < ViewComponent::Base
  def initialize(content_block_edition:, params:, context:, back_link:, form_url:, is_rescheduling:)
    @content_block_edition = content_block_edition
    @params = params
    @context = context
    @back_link = back_link
    @form_url = form_url
    @is_rescheduling = is_rescheduling
  end

private

  attr_reader :is_rescheduling, :content_block_edition, :params, :context, :back_link, :form_url

  def year_param
    content_block_edition.scheduled_publication&.year || params.dig("scheduled_at", "scheduled_publication(1i)")
  end

  def month_param
    content_block_edition.scheduled_publication&.month || params.dig("scheduled_at", "scheduled_publication(2i)")
  end

  def day_param
    content_block_edition.scheduled_publication&.day || params.dig("scheduled_at", "scheduled_publication(3i)")
  end

  def hour_param
    content_block_edition.scheduled_publication&.hour || params.dig("scheduled_at", "scheduled_publication(4i)")
  end

  def minute_param
    content_block_edition.scheduled_publication&.min || params.dig("scheduled_at", "scheduled_publication(5i)")
  end
end
