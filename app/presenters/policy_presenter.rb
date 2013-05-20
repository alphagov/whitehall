class PolicyPresenter < Whitehall::Decorators::Decorator
  include EditionPresenterHelper

  delegate_instance_methods_of Policy

  def as_hash
    super.merge({
      topics: model.topics.map(&:name).join(", ").html_safe
    })
  end
end
