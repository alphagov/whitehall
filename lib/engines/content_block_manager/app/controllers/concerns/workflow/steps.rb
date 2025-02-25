module Workflow::Steps
  extend ActiveSupport::Concern

  included do
    before_action :initialize_edition_and_schema
  end

  def steps
    @steps ||= if @schema.subschemas.any?
                 standard_steps = all_steps.map(&:dup)
                 extra_steps = @schema.subschemas.map do |subschema|
                   Workflow::Step.new(
                     "#{Workflow::Step::SUBSCHEMA_PREFIX}#{subschema.id}".to_sym,
                     "#{Workflow::Step::SUBSCHEMA_PREFIX}#{subschema.id}".to_sym,
                     :redirect_to_next_step,
                     true,
                   )
                 end
                 standard_steps.insert(1, extra_steps).flatten!
               else
                 all_steps
               end
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
    steps.find_index { |step| step.name == params[:step].to_sym }
  end
end
