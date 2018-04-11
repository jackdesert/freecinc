module ViewHelper
  IMAGE_PATH = 'images/'

  def http_host
    env['HTTP_HOST']
  end

  def root_url
    "http://#{http_host}"
  end

  def root_url_secure
    return root_url unless production?
    root_url.sub(/\Ahttp/, 'https')
  end

  def server_with_port
    "#{env['SERVER_NAME']}:53589"
  end

  def production?
    settings.production?
  end

  def image_url
    "#{root_url_secure}/#{IMAGE_PATH}"
  end

  def root_path
    '/'
  end

  def generate_path
    '/generated_keys'
  end

  def about_path
    '/about'
  end

  def terms_path
    '/terms'
  end

  def author_email
    'jworky@gmail.com'
  end

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

  def fake_uuid
    '---------This-is-a-fake-uuid--------'
  end

  def secure_url(relative_url)
    # Production urls should use https
    # localhost urls should keep http
    absolute_url = url(relative_url)
    return absolute_url unless production?
    absolute_url.sub(/^http/, 'https')
  end


  def image_path(text)
    if production?
      # Load images from the remote url
      text.gsub(IMAGE_PATH, image_url)
    else
      # Load images locally (faster for development)
      text
    end
  end

  def on_home_page?
    path_info == root_path
  end

  def on_about_page?
    path_info == about_path
  end

  private

  def path_info
    env['PATH_INFO']
  end

  def freecinc_proper?
    http_host == 'freecinc.com'
  end

  def stylesheets_production
    insert_stylesheet('reset.css') + insert_stylesheet('style.css')
  end

  def stylesheets_development
    "<link rel='stylesheet' type='text/css' href='reset.css'>
    <link rel='stylesheet' type='text/css' href='style.css'>"
  end

  def insert_stylesheet(filename)
    contents = read_stylesheet_and_use_appropriate_image_path(filename)
    output = "<!-- Stylesheet '#{filename}' -->\n"
    output += "<style>\n"
    output += contents
    output += "</style>\n\n"
    output
  end

  def read_stylesheet_and_use_appropriate_image_path(filename)
    contents = File.read("#{settings.root}/public/#{filename}")
    image_path(contents)
  end

end
