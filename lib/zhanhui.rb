require "nokogiri"
require "thread"
require 'open-uri'

class Zhanhui
  """
  Usage:
  1. get a list
    list = Zhanhui.get_exi_list()
  2. get details
    list.each{ |x| Zhanhui.get_details( x ) } 
  """

  private
  def self.request( url )
    """
    Mimic broswer behavior to sent HTTP request
    to avoid blocking
    """
    # force encoding
    url = URI::encode(url)
    # parse URL get URI
    uri = url.match(/com.*?\z/).to_s[3..-1]
    http_request = "GET #{uri} HTTP/1.1\r\n"+
    "Host:www.haozhanhui.com\r\n"+
    "Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8\r\n"+
    "Connection:keep-alive\r\n"+
    "User-Agent: Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:33.0) Gecko/20100101 Firefox/33.0\r\n\r\n"
    socket = TCPSocket.open( 'www.haozhanhui.com', 80)

    socket.puts( http_request)

    html = ""
    while line = socket.gets
      html += line
      # automatically end
      break if html.include?('</HTML>') || html.include?('</html>')
    end
    socket.close
    return html
  end

  ##################################
  #  Methods below parse Expo Info #
  ################################## 

  def self.get_expo_info( param )
    """
    Enter exhibition info page using :page in param
    THen parse details of exhibitons
    """
    url = param[:page]
    # use customized request instead of open
    doc = Nokogiri::HTML( request( url ) )

    # get exi center orgainzor and offcial_site
    info = doc.search("div[@class='exhinfo_center']").search('li')
    info.each do |text|
      text = text.text.rstrip
      if text[0..3] == '展会场馆'
        param[:location] = text[ 5..-1 ]
      elsif text[0..3] == '组织单位'
        param[:organizor] = text[ 5..-1 ]
      elsif text[0..3] == '官方网站'
        param[:official_site] = text[ 5..-1 ]
      end
    end
    
    # get range
    info = doc.search("div[@class='box exh_box']")
    info.each do |x|
      if x.search("h3").text == "展品范围"
        param[:range] = x.search("div[@class='box-bd exhdetail']").text
      elsif x.search("h3").text == "联系信息"
        param[:contact] = x.search("div[@class='box-bd exhdetail']").text
      end
    end
    return param
  end

  def self.get_expos()
    url = "http://www.haozhanhui.com/zhanlanjihua/"
    doc = Nokogiri::HTML(open(url))

    table = doc.search("ul[@class='trade-news haiwai']")
    
    exhibitions = []
    # get date, city and catagory
    table.search("li").each  do |li|
      text = li.text

      exhibition = {}
      exhibition[:date] = text[0,10]
      exhibition[:name] = text.match(/】\S\S([0-9]+|[a-zA-Z]+).+/).to_s[3..-1]

      # Deprecatem, we don't need city info now
      # text.gsub(/【.*?】/).each do |x|
      #   if exhibition[:cata] == ''
      #     exhibition[:cata] = x[1,x.length-2] 
      #     continue
      #   end
      #   exhibition[:city] = x[1,x.length-2] 
      # end
      # get info page
      exhibition[:page] = li.search("a").attribute("href").value

      exhibitions << exhibition
    end
    return exhibitions
  end


  #########################################
  # Methods below crawl Expo centers info #
  #########################################
  def self.get_expo_center_ids()
    page = Nokogiri::HTML( request('http://www.haozhanhui.com/exhplace.html') ) 
    province_pages = []
    page.search("div[@class='asfcz']").search("a").each do |x|
      province_pages << x.attribute("href").value
    end

    expo_center_ids = []
    province_pages.each do |province_page|
      page = Nokogiri::HTML( request( province_page ) )
      page.search("div[@class='right_center_zi']").search("a").each do |a|
        expo_center_ids << a.attribute('href').value.match(/\/\d{2,}.html/).to_s[1..-6]
      end
    end

    return expo_center_ids
  end

  def self.get_expo_center_info( id )
    center = {}
    center[:id] = id.to_i

    # get ciry, location, website, intro and contact
    url = "http://www.haozhanhui.com/place/place_detail_#{id}.html"
    center[:original_url] = url
    page = Nokogiri::HTML( request( url ) )
    page.search("div[@class='box exh_box']").each do |x|
      if x.search("h3").text[-4..-1] == "常用信息"
        # get name
        center[:name] = x.search("h3").text[0..-5]
        # get common info
        x.search("ul").search("li").each do |li|
          li = li.text
          if li[0..3] =="展馆城市"
            center[:city_name] = li[5..-1]
          elsif li[0..3] =="展馆位置"
            center[:address] = li[5..-1]
          elsif li[0..3] =="展馆网址"
            center[:website] = li[5..-1]
          end
        end
      elsif x.search("h3").text[-4..-1] == "展馆简介"
        center[:intro] = x.search("div[@class='box-bd placedetail']").text.strip
      elsif x.search("h3").text[-4..-1] == "联系信息"
        center[:contact] = x.search("div[@class='box-bd placedetail']").text.strip
      end
    end

    # check if has nearby info
    url = "http://www.haozhanhui.com/place/place_common_#{id}.html"
    page = Nokogiri::HTML( request( url ) )
    return center if page.search("div[@id='main']").search("div[@class='box-bd placecommon']").empty?
    
    # get nearby information
    # get bus information
    center[:bus] = get_expo_center_extra_info( '公交车站', id )

    # get tracffic information
    center[:traffic] = get_expo_center_extra_info( '路线图', id )

    # get bank information
    center[:bank] = get_expo_center_extra_info( '银行', id )

    # get extra infromation
    text = ''
    text += get_expo_center_extra_info( '购物', id )
    text += get_expo_center_extra_info( '餐厅', id )
    text += get_expo_center_extra_info( '娱乐休闲', id )
    center[:extra] = text

    return center
  end

  private
  def self.get_expo_center_extra_info( type, id )
    url = "http://www.haozhanhui.com/place/place_service_#{type}_#{id}.html"
    page = Nokogiri::HTML( request( url ))
    page.search("div[@class='box exh_box']")\
          .search("div[@class='box-bd placedetail']").text.strip
  end

end