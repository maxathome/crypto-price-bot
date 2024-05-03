class SlackController < ApplicationController
    skip_before_action :verify_authenticity_token
  
    def commands
      case params[:text].strip.downcase
      when 'eth'
        price = get_eth_price
        render json: { text: "The current price of Ethereum is $#{price}" }
      else
        render json: { text: "Unsupported command" }
      end
    end
  
    def get_eth_price
      response = HTTParty.get('https://api.coingecko.com/api/v3/simple/price?ids=ethereum&vs_currencies=usd')
      response.parsed_response['ethereum']['usd']
    end
  end
  