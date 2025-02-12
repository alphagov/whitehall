module Workflow::Steps
  extend ActiveSupport::Concern

  included do
    before_action :initialize_edition_and_schema
  end

  def steps
    @steps ||= if @schema.subschemas.any?
                 standard_steps = Workflow::Step::ALL.map(&:dup)
                 extra_steps = @schema.subschemas.map do |subschema|
                   Workflow::Step.new(
                     "embedded_#{subschema.id}".to_sym,
                     "embedded_#{subschema.id}".to_sym,
                     :redirect_to_next_step,
                   )
                 end
                 standard_steps.insert(1, extra_steps).flatten!
               else
                 Workflow::Step::ALL
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

  def initialize_edition_and_schema
    @content_block_edition = ContentBlockManager::ContentBlock::Edition.find(params[:id])
    @schema = ContentBlockManager::ContentBlock::Schema.find_by_block_type(@content_block_edition.document.block_type)
  end

  def index
    steps.find_index { |step| step.name == params[:step].to_sym }
  end
end
