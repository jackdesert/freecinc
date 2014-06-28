module ViewHelper
  def link_to(url, text)
    "<a href='#{url}'>#{text}</a>"
  end

  def save_as(key)
    "Save the following block of text as #{key}"
  end
end
