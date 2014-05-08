require 'lita'
require_relative 'lita/handlers/imgstocker'

if ENV['RACK_ENV'] !='production'
  require 'dotenv'
  Dotenv.load
end

Lita.configure do |config|
  config.robot.name       = ENV["BOT_NAME"] || 'lita'
  config.robot.adapter    = ENV["ADAPTER"] ? ENV["ADAPTER"].to_sym : :shell
  config.robot.log_level = :info

  config.redis.url = ENV["REDISTOGO_URL"]
  config.http.port = ENV["PORT"]

  config.adapter.api_key             = ENV['TWITTER_API_KEY']
  config.adapter.api_secret          = ENV['TWITTER_API_SECRET']
  config.adapter.access_token        = ENV['TWITTER_ACCESS_TOKEN']
  config.adapter.access_token_secret = ENV['TWITTER_ACCESS_TOKEN_SECRET']

  config.handlers.imgstocker.internal_api_key = ENV['INTERNAL_API_KEY']
end
