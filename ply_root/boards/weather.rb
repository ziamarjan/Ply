board :weather do |f|

  f.priority = 80
  f.show_for = 10.seconds

  f.index do
  end

  f.web_service :response do
    require 'open-uri'

    weather_target = "http://www.google.com/ig/api?weather=Perth,%20Australia&hl=en-gb" # Google's secret weather API & -gb gives us Celcius

    doc = Nokogiri::XML(open(weather_target))

    current = doc.xpath("//current_conditions").first
    current_temp = current.xpath("temp_c").first["data"] rescue "?"

    # calculate upcoming forecasts
    futures = doc.xpath("//forecast_conditions")

    future_data = futures.map do |future|
      day = future.xpath("day_of_week").first["data"] rescue "Unknown"
      low = future.xpath("low").first["data"] rescue "?"
      high = future.xpath("high").first["data"] rescue "?"

      {:day => day, :low => low, :high => high}
    end

    {:current => current_temp, :future => future_data}
  end
end