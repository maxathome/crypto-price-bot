class SlackController < ApplicationController
  skip_before_action :verify_authenticity_token

  def stocks
    stock_input = params[:text].strip.downcase
    quote = get_stock_quote(stock_input)
    render json: {
         response_type: "in_channel",
         text: format_message(stock_input.upcase, quote)
       }
  end

  def crypto
    crypto_input = params[:text].strip.downcase
    quote = get_crypto_quote(crypto_input)
    render json: {
        response_type: "in_channel",
        text: format_message(crypto_input.upcase, quote)
      }
  end

  private

  def get_crypto_quote(crypto_symbol)
    get_quote("#{crypto_symbol}/USD")
  end

  def get_stock_quote(stock_symbol)
    get_quote(stock_symbol)
  end

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
