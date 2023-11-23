module DesignSystemHelper
  def within_conditional_reveal(label, &block)
    input = find_field(label)
    conditional_reveal_id = input["aria-controls"] || input["data-aria-controls"]
    conditional_reveal = find_by_id(conditional_reveal_id)
    within(conditional_reveal, &block)
  end
end

World(DesignSystemHelper)
