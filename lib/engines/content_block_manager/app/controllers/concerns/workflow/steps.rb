module Workflow::Steps
  extend ActiveSupport::Concern

  included do
    before_action :initialize_edition_and_schema
  end

  def steps
    @steps ||= should_show_subschema_steps? ? all_steps : all_steps.reject { |s| s.name == :embedded_objects }
  end

  def current_step
    Workflow::Step::ALL.find { |step| step.name == params[:step].to_sym }
  end

  def previous_step
    steps[index - 1]
  end

  def next_step
    steps[index + 1]
  end

private

  def all_steps
    if @content_block_edition.document.is_new_block?
      Workflow::Step::ALL.select { |s| s.included_in_create_journey == true }
    else
      Workflow::Step::ALL
    end
  end

  def should_show_subschema_steps?
    if @content_block_edition.document.is_new_block?
      @schema.subschemas.any?
    else
      @schema.subschemas.any? && @schema.subschemas.any? { |subschema| @content_block_edition.has_entries_for_subschema_id?(subschema.id) }
    end
  end

  def initialize_edition_and_schema
    @content_block_edition = ContentBlockManager::ContentBlock::Edition.find(params[:id])
    @schema = ContentBlockManager::ContentBlock::Schema.find_by_block_type(@content_block_edition.document.block_type)
  end

  def index
    steps.find_index { |step| step.name == params[:step]&.to_sym } || 0
  end
end
