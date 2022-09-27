module ErrorsHelper
  def errors_for_input(errors, attribute)
    return nil if errors.blank?

    errors.filter_map { |error|
      if error.attribute == attribute
        error.full_message
      end
    }
    .join("\n")
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
end
