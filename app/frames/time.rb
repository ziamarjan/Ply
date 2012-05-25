frame :time do |f|
  f.index do
    @time_zone_offset = Time.zone.utc_offset
  end
end