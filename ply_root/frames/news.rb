frame :news do |f|

  f.priority = 5
  f.update_every = 1.minute # seconds
  f.show_for = 60.seconds

  f.index do
  end

  f.web_service :headlines do
    require 'open-uri'

    req_target = "http://feeds.bbci.co.uk/news/world/rss.xml"
    doc = Nokogiri::XML(open(req_target))
    items = doc.xpath('/rss/channel/item')

    news_items = []
    max_count = 15
    count = 0
    items.each do |item|
      title = item.xpath("title").text()
      description = item.xpath("description").text()
      obj = {title: title, description: description}
      news_items << obj unless title.include?("VIDEO") || news_items.include?(obj)
      count = count + 1
      if (count > max_count)
        break
      end
    end

    news_items
  end
end