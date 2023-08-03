module ErrorsHelper
  def errors_for_input(errors, attribute)
    return nil if errors.blank?

    errors.filter_map { |error|
      if error.attribute == attribute
        error.full_message
      end
    }
    .join(tag.br)
    .html_safe
    .presence
  end

  def errors_for(errors, attribute)
    return nil if errors.blank?

    errors.filter_map { |error|
      if error.attribute == attribute
        {
          text: error.full_message,
        }
      end
    }
    .presence
  end

  def errors_from_flash(flash)
    return nil if flash.blank?

    flash.map do |array|
      {
        href: "##{array.first}",
        text: array.last,
      }
    end
  end
end
