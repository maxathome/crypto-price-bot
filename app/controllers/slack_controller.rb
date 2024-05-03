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
    else
      render json: { text: "I only do Ethereum. If you want more, Venmo Max $5 @Max-Levine-2"}
    end
  end

  private
  def get_eth_price
    url = ENV['GET_PRICE_URL'] + ENV['CYRPTOCOMPARE_API_KEY']
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
  
#   def get_eth_price
#     response = HTTParty.get('https://api.coingecko.com/api/v3/simple/price?ids=ethereum&vs_currencies=usd')
#     response.parsed_response['ethereum']['usd']
#   end
end
