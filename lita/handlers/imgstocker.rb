require 'faraday'
require 'json'

module Lita
  module Handlers
    class Imgstocker < Handler
      def self.default_config(handler_config)
        handler_config.internal_api_key = nil
      end

      route /^save ([a-zA-Z0-9_-]+)/, :save_icon, command: true
      route /^set ([a-zA-Z0-9_-]+)/,  :set_icon,  command: true
      route /^list/,                  :list_icon, command: true

      def save_icon(response)
        icon_name = response.matches[0][0]
        user_id   = response.user.id
        result    = http_client.post "api/users/#{user_id}/icons", { api_key: config.internal_api_key, name: icon_name }
        if result.status == 200
          response.reply "@#{response.user.name} done. [#{Time.now}]"
        else
          response.reply "@#{response.user.name} failure. [#{Time.now}]"
        end
      end

      def set_icon(response)
        icon_name = response.matches[0][0]
        user_id   = response.user.id
        result    = http_client.put "api/users/#{user_id}", { api_key: config.internal_api_key, icon: icon_name }
        if result.status == 200
          response.reply "@#{response.user.name} #{success_message} [#{Time.now}]"
        else
          response.reply "@#{response.user.name} #{failure_message} [#{Time.now}]"
        end
      end

      def list_icon(response)
        user_id   = response.user.id
        result    = http_client.get "api/users/#{user_id}/icons", { api_key: config.internal_api_key }
        if result.status == 200
          icon_names = JSON.parse(result.body)['icons'].map{ |icon| icon['name'] }
          response.reply "@#{response.user.name} #{icon_names.join(', ')} [#{Time.now}]"
        else
          response.reply "@#{response.user.name} #{failure_message} [#{Time.now}]"
        end
      end

      private
      def http_client
        @conn ||= Faraday.new(url: 'https://imgstocker.herokuapp.com') do |faraday|
          faraday.request  :url_encoded             # form-encode POST params
          faraday.response :logger                  # log requests to STDOUT
          faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
        end
      end

      def config
        Lita.config.handlers.imgstocker
      end

      def success_message
        [
          'りょーかいやで〜',
          'よっしゃ!やったるわ!',
          'まかせとき～',
          'おｋ',
          '拝承',
          '了解。',
          '承知いたしました。',
        ].sample
      end

      def failure_message
        [
          'いや～、失敗してもた。',
          'すまんな、なんかうまくいかん。',
          '失敗したので寝る( ˘ω˘)',
        ].sample
      end
    end
    Lita.register_handler(Imgstocker)
  end
end
