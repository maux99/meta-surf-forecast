# frozen_string_literal: true

namespace :spitcast do
  desc 'Update forecast from Spitcast'
  task update: %w[environment forecasts:set_batch_id] do
    Rails.logger.info 'Updating Spitcast data...'

    hydra = Typhoeus::Hydra.new(max_concurrency: API_CONCURRENCY)

    Spot.where.not(spitcast_id: nil).each do |spot|
      Spitcast.api_pull(spot, hydra: hydra)
    end

    hydra.run

    Rails.logger.info 'Finished updating Spitcast data'
  end
end
