class PolicyPresenter < Struct.new(:model, :context)
  include EditionPresenterHelper

  policy_methods = Policy.instance_methods - Object.instance_methods
  delegate *policy_methods, to: :model

  def as_hash
    super.merge({
      topics: model.topics.map(&:name).join(", ").html_safe
    })
  end
end
