module Whitehall
  class FormBuilder < ActionView::Helpers::FormBuilder
    def save_or_cancel(options={})
      cancel = @template.content_tag(:span, "class" => "or_cancel") do
        @template.concat %{ or }
        @template.concat @template.link_to 'cancel', cancel_path(options[:cancel])
      end
      @template.content_tag(:fieldset, "class" => "clear") do
        @template.concat submit "Save"
        @template.concat cancel
      end
    end

    private

    def cancel_path(path)
      return path if path
      if object.is_a?(Document)
        object.new_record? ? @template.admin_documents_path :
                             @template.admin_document_path(object)
      else
        object.new_record? ? @template.polymorphic_path([:admin, object.class]) :
                             @template.polymorphic_path([:admin, object])
      end
    end
  end
end