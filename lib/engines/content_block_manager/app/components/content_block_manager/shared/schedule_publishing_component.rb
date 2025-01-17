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
end
