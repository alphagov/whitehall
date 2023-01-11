class PersonPresenter < Whitehall::Decorators::Decorator
  delegate_instance_methods_of Person

  def biography
    context.govspeak_to_html(model.biography_appropriate_for_role)
  end

  def link(options = {})
    name = ""
    name << "<span class='app-person-link__title'>The Rt Hon</span> " if privy_counsellor?
    name << "<span class='app-person-link__name govuk-!-padding-0 govuk-!-margin-0'>#{name_without_privy_counsellor_prefix}</span>"
    context.link_to name.html_safe, path, options.merge(class: "app-person-link")
  end

  def image
    if (img = image_url(:s216))
      context.image_tag img, alt: name, loading: "lazy"
    end
  end

  def path
    model.public_path
  end
end
