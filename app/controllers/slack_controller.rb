class SlackController < ApplicationController
  skip_before_action :verify_authenticity_token

  def stocks
   stock_input = params[:text].strip.downcase
   price = get_stock_price(stock_input)
   render json: {
        response_type: "in_channel", # This makes the response visible to everyone in the channel
        text: "The current price of #{stock_input.upcase} is $#{price}"
      }
  end

  def crypto
    crypto_input = params[:text].strip.downcase
    price = get_crypto_price(crypto_input)
    render json: {
        response_type: "in_channel", # This makes the response visible to everyone in the channel
        text: "The current price of #{crypto_input.upcase} is $#{price}"
      }
  end

  private

  def get_crypto_price(crypto_symbol)
    get_price("#{crypto_symbol}/USD")
  end

  def get_stock_price(stock_symbol)
    get_price(stock_symbol)
  end

  def get_price(symbol)
    url = ENV['TWELVE_DATA_URL'] + symbol + "&apikey=" + ENV['TWELVE_DATA_API_KEY']
    response = HTTParty.get(url)

    Rails.logger.info("API Response: #{response}")

    if response.success? && response.parsed_response['price']
      price = response.parsed_response['price'].to_f.round(2)
      Rails.logger.info("Price: #{price}")
      price
    elsif response.parsed_response['message']
      Rails.logger.info("Symbol not found: #{response.parsed_response['message']}")
      "NOT FOUND"
    else
      Rails.logger.error("Failed to retrieve price from API")
      nil
    end
  rescue => e
    Rails.logger.error("Exception occurred: #{e.message}")
    nil
  end
end
