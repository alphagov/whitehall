module CanScheduleOrPublish
  extend ActiveSupport::Concern

  def schedule_or_publish
    @schema = ContentBlockManager::ContentBlock::Schema.find_by_block_type(@content_block_edition.document.block_type)

    if params[:schedule_publishing] == "schedule"
      ContentBlockManager::ScheduleEditionService.new(@schema).call(@content_block_edition, scheduled_publication_params)
    else
      publish and return
    end

    redirect_to content_block_manager.content_block_manager_content_block_workflow_path(id: @content_block_edition.id,
                                                                                        step: :confirmation,
                                                                                        is_scheduled: true)
  end

  def publish
    new_edition = ContentBlockManager::PublishEditionService.new.call(@content_block_edition)
    redirect_to content_block_manager.content_block_manager_content_block_workflow_path(id: new_edition.id, step: :confirmation)
  end

  def validate_scheduled_edition
    if params[:schedule_publishing].blank?
      @content_block_edition.errors.add(:schedule_publishing, t("activerecord.errors.models.content_block_manager/content_block/edition.attributes.schedule_publishing.blank"))
      raise ActiveRecord::RecordInvalid, @content_block_edition
    elsif params[:schedule_publishing] == "schedule"
      validate_scheduled_publication_params

      @content_block_edition.assign_attributes(scheduled_publication_params)
      @content_block_edition.assign_attributes(state: "scheduled")
      raise ActiveRecord::RecordInvalid, @content_block_edition unless @content_block_edition.valid?
    end
  end

  def validate_scheduled_publication_params
    error_base = "activerecord.errors.models.content_block_manager/content_block/edition.attributes.scheduled_publication"
    if scheduled_publication_params.values.all?(&:blank?)
      @content_block_edition.errors.add(:scheduled_publication, t("#{error_base}.blank"))
    elsif scheduled_publication_time_params.all?(&:blank?)
      @content_block_edition.errors.add(:scheduled_publication, t("#{error_base}.time.blank"))
    elsif scheduled_publication_date_params.all?(&:blank?)
      @content_block_edition.errors.add(:scheduled_publication, t("#{error_base}.date.blank"))
    elsif scheduled_publication_params.values.any?(&:blank?)
      @content_block_edition.errors.add(:scheduled_publication, t("#{error_base}.invalid_date"))
    end

    raise ActiveRecord::RecordInvalid, @content_block_edition if @content_block_edition.errors.any?
  end

  def scheduled_publication_time_params
    [
      scheduled_publication_params["scheduled_publication(4i)"],
      scheduled_publication_params["scheduled_publication(5i)"],
    ]
  end

  def scheduled_publication_date_params
    [
      scheduled_publication_params["scheduled_publication(1i)"],
      scheduled_publication_params["scheduled_publication(2i)"],
      scheduled_publication_params["scheduled_publication(3i)"],
    ]
  end
end
