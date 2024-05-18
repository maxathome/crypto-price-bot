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
    base_url = ENV['GET_CRYPTO_PRICE_URL']
    input_url =  base_url.gsub(/fsym=[^&]*/, "fsym=#{crypto_symbol}")
    url = input_url + ENV['CRYPTOCOMPARE_API_KEY']
    response = HTTParty.get(url)
  
    # Log the response for debugging
    Rails.logger.info("API Response: #{response}")
  
    if response.parsed_response["Response"] == "Error"
      Rails.logger.info("Symbol not found")
      return "NOT FOUND"
    elsif response.success?
      crypto_price = response.parsed_response['USD']
      Rails.logger.info("Crypto Price: #{crypto_price}")
      return crypto_price
    else
      # Log error or notify about the failure
      Rails.logger.error("Failed to retrieve Crypto price from API")
      return nil # Or handle this situation appropriately
    end
  rescue => e
    Rails.logger.error("Exception occurred: #{e.message}")
    nil
  end

  def get_stock_price(stock_symbol)
    base_url = ENV['GET_STOCK_PRICE_URL']
    input_url =  base_url.gsub(/symbol=[^&]*/, "symbol=#{stock_symbol}")
    url = input_url + ENV['ALPHAVANTAGE_API_KEY']
    response = HTTParty.get(url)
  
    # Log the response for debugging
    Rails.logger.info("API Response: #{response}")
  
    if response.parsed_response['Global Quote'] == {}
      Rails.logger.info("Symbol not found")
      return "NOT FOUND"
    elsif response.success?
      stock_price = response.parsed_response['Global Quote']['05. price'].to_f.round(2)
      Rails.logger.info("Stock Price: #{stock_price}")
      return stock_price
    else
      # Log error or notify about the failure
      Rails.logger.error("Failed to retrieve Stock price from API")
      return nil # Or handle this situation appropriately
    end
  rescue => e
    Rails.logger.error("Exception occurred: #{e.message}")
    nil
  end

  # def get_stock_price 
  #   url = ENV['GET_STOCK_PRICE_URL'] + ENV['ALPHAVANTAGE_API_KEY']
  #   response = HTTParty.get(url)
  
  #   # Log the response for debugging
  #   Rails.logger.info("API Response: #{response}")
  
  #   if response.success?
  #     copper_price = response.parsed_response['Global Quote']['05. price'].to_f.round(2)
  #     Rails.logger.info("Copper Price: #{copper_price}")
  #     return copper_price
  #   else
  #     # Log error or notify about the failure
  #     Rails.logger.error("Failed to retrieve Copper price from API")
  #     return nil # Or handle this situation appropriately
  #   end
  # rescue => e
  #   Rails.logger.error("Exception occurred: #{e.message}")
  #   nil
  # end  
end
