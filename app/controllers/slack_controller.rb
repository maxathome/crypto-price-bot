class SlackController < ApplicationController
  skip_before_action :verify_authenticity_token

  def commands
    case params[:text].strip.downcase
    when 'eth'
      price = get_eth_price
      render json: {
        response_type: "in_channel", # This makes the response visible to everyone in the channel
        text: "The current price of Ethereum is $#{price}"
      }
    when 'cper'
      price = get_cper_price
      render json: {
        response_type: "in_channel", # This makes the response visible to everyone in the channel
        text: "The current price of Copper is $#{price}"
      }
    else
      render json: { text: "I only do Ethereum and Copper. If you want more, Venmo Max $5 @Max-Levine-2"}
    end
  end

  private
  def get_eth_price
    url = ENV['GET_CYRPTO_PRICE_URL'] + ENV['CYRPTOCOMPARE_API_KEY']
    response = HTTParty.get(url)
  
    # Log the response for debugging
    Rails.logger.info("API Response: #{response}")
  
    if response.success?
      ethereum_price = response.parsed_response['USD']
      Rails.logger.info("Ethereum Price: #{ethereum_price}")
      return ethereum_price
    else
      # Log error or notify about the failure
      Rails.logger.error("Failed to retrieve Ethereum price from API")
      return nil # Or handle this situation appropriately
    end
  rescue => e
    Rails.logger.error("Exception occurred: #{e.message}")
    nil
  end
  
  def get_cper_price 
    url = ENV['GET_STOCK_PRICE_URL'] + ENV['ALPHAVANTAGE_API_KEY']
    response = HTTParty.get(url)
  
    # Log the response for debugging
    Rails.logger.info("API Response: #{response}")
  
    if response.success?
      copper_price = response.parsed_response['Global Quote']['05. price'].to_f.round(2)
      Rails.logger.info("Copper Price: #{copper_price}")
      return copper_price
    else
      # Log error or notify about the failure
      Rails.logger.error("Failed to retrieve Copper price from API")
      return nil # Or handle this situation appropriately
    end
  rescue => e
    Rails.logger.error("Exception occurred: #{e.message}")
    nil
  end
  
#   def get_eth_price
#     response = HTTParty.get('https://api.coingecko.com/api/v3/simple/price?ids=ethereum&vs_currencies=usd')
#     response.parsed_response['ethereum']['usd']
#   end
end
