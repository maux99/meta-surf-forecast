# frozen_string_literal: true

class Spitcast < Forecast
  class << self
    def site_url
      'http://www.spitcast.com'
    end

    def api_url(spot)
      raise "No Spitcast spot associated with #{spot.name} (#{spot.id})" if spot.spitcast_id.blank?

      "http://api.spitcast.com/api/spot/forecast/#{spot.spitcast_id}/?dcat=week"
    end

    def for_chart
      pluck('round(height, 1)')
    end

    def parse_data(spot, request, data)
      data.each do |entry|
        next unless entry.gmt

        record = unscoped.where(spot: spot, timestamp: Time.zone.parse("#{entry.gmt}:00 UTC")).first_or_initialize
        record.api_request = request
        record.height = entry.size_ft
        record.rating = case entry.shape_full
                        when 'Poor' then 1
                        when 'Poor-Fair' then 2
                        when 'Fair' then 3
                        when 'Fair-Good' then 4
                        when 'Good' then 5
                        else 0
                        end
        record.save! if record.rating.present?
      end
    end
  end
end
