module ViewHelper
  SERVER_NAME        =  'http://freecinc.com'
  SECURE_SERVER_NAME = 'https://freecinc.com'

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

  def secure_url(relative_url)
    # Production urls should use https
    # localhost urls should keep http
    absolute_url = url(relative_url)
    absolute_url.sub(SERVER_NAME, SECURE_SERVER_NAME)
  end

end
