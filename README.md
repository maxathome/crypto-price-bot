# Crypto Price Bot

A Rails Slack bot that returns real-time stock and crypto prices via slash commands, powered by the [Twelve Data API](https://twelvedata.com).

## Features

- Look up stock and crypto prices with a single `/price` command
- 24hr price change with up/down indicator
- Automatically disambiguates symbols that match both a stock and a crypto (e.g. XRP, BCH, LINK) via interactive buttons

## Requirements

- Ruby 3.0.2
- Rails 7.1
- A [Twelve Data](https://twelvedata.com) account (free tier supported)
- A Slack app with slash commands and interactive components enabled

## Environment Variables

Copy `.env.example` to `.env` and fill in the values:

| Variable | Description |
|----------|-------------|
| `TWELVE_DATA_API_KEY` | Your Twelve Data API key |
| `TWELVE_DATA_URL` | Twelve Data quote endpoint — `https://api.twelvedata.com/quote?symbol=` |
| `SLACK_BOT_TOKEN` | Your Slack bot token (`xoxb-...`) |

## Slack App Setup

1. Create a new app at [api.slack.com/apps](https://api.slack.com/apps)
2. Under **OAuth & Permissions**, add the following bot token scopes:
   - `commands`
   - `chat:write`
   - `chat:write.public` (to post in public channels without joining)
3. Under **Slash Commands**, create a `/price` command pointing to `https://your-domain.com/slack/price`
4. Under **Interactivity & Shortcuts**, enable interactivity and set the request URL to `https://your-domain.com/slack/interactions`
5. Install the app to your workspace and copy the bot token to your `.env`

## Running Locally

```bash
bundle install
cp .env.example .env  # fill in your keys
./bin/rails server
```

## Usage

In any Slack channel the bot has been invited to:

```
/price ETH      # Ethereum price
/price AAPL     # Apple stock price
/price XRP      # Shows disambiguation buttons (crypto vs stock)
```
