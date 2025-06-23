module Workflow::Steps
  extend ActiveSupport::Concern
  include ContentBlockManager::ContentBlock::SchemaHelper

  included do
    before_action :initialize_edition_and_schema
  end

  def steps
    @steps ||= [
      *all_steps[0],
      *group_steps,
      *subschema_steps,
      *all_steps[1..],
    ].compact
  end

  def current_step
    steps.find { |step| step.name == params[:step].to_sym }
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

  def initialize_edition_and_schema
    @content_block_edition = ContentBlockManager::ContentBlock::Edition.find(params[:id])
    @schema = ContentBlockManager::ContentBlock::Schema.find_by_block_type(@content_block_edition.document.block_type)
  end

  def index
    steps.find_index { |step| step.name == params[:step]&.to_sym } || 0
  end

  def skip_subschema?(subschema)
    !@content_block_edition.document.is_new_block? &&
      !@content_block_edition.has_entries_for_subschema_id?(subschema.id)
  end

  def skip_group?(subschemas)
    subschemas.all? { |subschema| skip_subschema?(subschema) }
  end

  def subschemas
    @subschemas ||= ungrouped_subschemas(@schema)
  end

  def groups
    @groups ||= grouped_subschemas(@schema)
  end

  def subschema_steps
    subschemas.map do |subschema|
      next if skip_subschema?(subschema)

      Workflow::Step.new(
        "#{Workflow::Step::SUBSCHEMA_PREFIX}#{subschema.id}".to_sym,
        "#{Workflow::Step::SUBSCHEMA_PREFIX}#{subschema.id}".to_sym,
        :redirect_to_next_step,
        true,
      )
    end
  end

  def group_steps
    groups.keys.map do |group|
      next if skip_group?(groups[group])

      Workflow::Step.new(
        "#{Workflow::Step::GROUP_PREFIX}#{group}".to_sym,
        "#{Workflow::Step::GROUP_PREFIX}#{group}".to_sym,
        :redirect_to_next_step,
        true,
      )
    end
  end
end
