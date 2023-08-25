class Admin::FlashMessageComponent < ViewComponent::Base
  def initialize(message:, html_safe: false)
    @html_safe = html_safe
    @message = message
  end

  def message
    if @html_safe
      @message.html_safe
    else
      @message
    end
  end
end
