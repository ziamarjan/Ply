frame :time do |f|

  f.priority = 99
  f.show_for = 10.seconds

  f.index do
    @time_zone_offset = Time.zone.utc_offset
  end

  f.web_service :utc_offset do
    Time.zone.utc_offset
  end
end