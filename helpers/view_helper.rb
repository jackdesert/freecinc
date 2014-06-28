module ViewHelper
  def link_to(url, text)
    "<a href='#{url}'>#{text}</a>"
  end

  def save_as(key)
    "Save the following block of text as #{key}"
  end

  def stylesheets
    "<link rel='stylesheet' type='text/css' href='reset.css'>
    <link rel='stylesheet' type='text/css' href='style.css'>"
  end
end
