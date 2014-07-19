module ViewHelper
  SERVER_NAME        =  'http://freecinc.com'
  SECURE_SERVER_NAME = 'https://freecinc.com'
  LOCAL_IMAGE_PATH = 'images/'
  REMOTE_IMAGE_PATH = "#{SECURE_SERVER_NAME}/#{LOCAL_IMAGE_PATH}"

  def link_to(url, text)
    "<a href='#{url}'>#{text}</a>"
  end

  def save_as(key)
    "Save the following block of text as #{key}"
  end

  def stylesheets
    if production?
      stylesheets_production
    else
      stylesheets_development
    end
  end


  def secure_url(relative_url)
    # Production urls should use https
    # localhost urls should keep http
    absolute_url = url(relative_url)
    absolute_url.sub(SERVER_NAME, SECURE_SERVER_NAME)
  end

  private
  def production?
    url('some_file').include?('freecinc.com')
    true
  end

  def stylesheets_production
    insert_stylesheet('reset.css') + insert_stylesheet('style.css')
  end

  def stylesheets_development
    "<link rel='stylesheet' type='text/css' href='reset.css'>
    <link rel='stylesheet' type='text/css' href='style.css'>"
  end

  def insert_stylesheet(filename)
    contents = read_stylesheet_with_absolute_image_path(filename)
    output = "<!-- Stylesheet '#{filename}' -->\n"
    output += "<style>\n"
    output += contents
    output += "</style>\n\n"
    output
  end

  def read_stylesheet_with_absolute_image_path(filename)
    contents = File.read("#{settings.root}/public/#{filename}")
    contents.gsub(LOCAL_IMAGE_PATH, REMOTE_IMAGE_PATH)
  end

end
