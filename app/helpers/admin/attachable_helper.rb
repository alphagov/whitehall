module Admin::AttachableHelper
  def is_publication?(model_name)
    model_name == "publication"
  end

  def is_consultation?(model_name)
    model_name == "consultation"
  end

  def attachment_note(model_name)
    return "Attachments added to a #{model_name} will appear automatically." if is_publication?(model_name) || is_consultation?(model_name)

    "Attachments need to be referenced in the body markdown to appear in your document."
  end
end
