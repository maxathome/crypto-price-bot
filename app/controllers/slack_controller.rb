class SlackController < ApplicationController
  skip_before_action :verify_authenticity_token

  CRYPTO_SYMBOLS = %w[BTC ETH].freeze

  AMBIGUOUS_SYMBOLS = {
    "XRP"  => { crypto_name: "Ripple",       stock_name: "Bitwise XRP ETF" },
    "BCH"  => { crypto_name: "Bitcoin Cash", stock_name: "Banco de Chile" },
    "LINK" => { crypto_name: "Chainlink",    stock_name: "Interlink Electronics" }
  }.freeze

  def price
    input = params[:text].strip.upcase

    if AMBIGUOUS_SYMBOLS.key?(input)
      meta = AMBIGUOUS_SYMBOLS[input]
      render json: {
        response_type: "ephemeral",
        blocks: [
          {
            type: "section",
            text: { type: "mrkdwn", text: "Which *#{input}* did you mean?" }
          },
          {
            type: "actions",
            elements: [
              {
                type: "button",
                text: { type: "plain_text", text: "#{input} — #{meta[:crypto_name]} (Crypto)" },
                value: "#{input}|crypto",
                action_id: "price_crypto"
              },
              {
                type: "button",
                text: { type: "plain_text", text: "#{input} — #{meta[:stock_name]} (Stock)" },
                value: "#{input}|stock",
                action_id: "price_stock"
              }
            ]
          }
        ]
      }
      return
    end

    symbol = CRYPTO_SYMBOLS.include?(input) ? "#{input}/USD" : input
    quote = get_quote(symbol)

    if quote.nil? && !CRYPTO_SYMBOLS.include?(input)
      quote = get_quote("#{input}/USD")
      symbol = "#{input}/USD"
    end

    render json: {
      response_type: "in_channel",
      text: format_message(symbol, quote)
    }
  end

  def interactions
    payload = JSON.parse(params[:payload])
    action = payload["actions"].first
    response_url = payload["response_url"]
    symbol, type = action["value"].split("|")

    twelve_data_symbol = type == "crypto" ? "#{symbol}/USD" : symbol
    quote = get_quote(twelve_data_symbol)

    HTTParty.post(response_url, {
      headers: { "Content-Type" => "application/json" },
      body: {
        delete_original: true
      }.to_json
    })

    HTTParty.post(response_url, {
      headers: { "Content-Type" => "application/json" },
      body: {
        response_type: "in_channel",
        text: format_message(twelve_data_symbol, quote)
      }.to_json
    })

    render json: {}, status: :ok
  end

  private

  def get_quote(symbol)
    url = ENV['TWELVE_DATA_URL'] + symbol + "&apikey=" + ENV['TWELVE_DATA_API_KEY']
    response = HTTParty.get(url)

    Rails.logger.info("API Response: #{response}")

    if response.success? && response.parsed_response['close']
      quote = {
        price: response.parsed_response['close'].to_f.round(2),
        percent_change: response.parsed_response['percent_change'].to_f.round(2)
      }
      Rails.logger.info("Quote: #{quote}")
      quote
    elsif response.parsed_response['message']
      Rails.logger.info("Symbol not found: #{response.parsed_response['message']}")
      nil
    else
      Rails.logger.error("Failed to retrieve quote from API")
      nil
    end
  rescue => e
    Rails.logger.error("Exception occurred: #{e.message}")
    nil
  end

  def format_message(symbol, quote)
    return "#{symbol} not found" if quote.nil?

    direction = quote[:percent_change] >= 0 ? "up" : "down"
    emoji = quote[:percent_change] >= 0 ? "📈" : "📉"
    "#{emoji} #{symbol} is trading at $#{quote[:price]} — #{direction} #{quote[:percent_change].abs}% in the last 24h"
  end
end
