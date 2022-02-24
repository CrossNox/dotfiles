#!/usr/bin/env python3

"""Fetch coins from coingecko."""

import pathlib

import requests
import toml


def read_config():
    cfg_file = pathlib.Path.home() / ".config" / "crypto.toml"
    with open(cfg_file.resolve()) as f:
        return toml.load(f)


def fetch_coin(coin: str, base_currency: str):
    json_response = requests.get(
        f"https://api.coingecko.com/api/v3/coins/{coin}"
    ).json()
    return {
        "price": json_response["market_data"]["current_price"][base_currency],
        "change24h": json_response["market_data"][
            "price_change_percentage_24h_in_currency"
        ][base_currency],
        "change1h": json_response["market_data"][
            "price_change_percentage_1h_in_currency"
        ][base_currency],
    }


def main():
    config = read_config()
    display_fmt = f'{{icon}} {config["display"]["format"]}'
    coins_data = []
    for coin, coin_cfg in config["coins"].items():
        coin_data = fetch_coin(coin, config["display"]["base_currency"])
        coins_data.append(display_fmt.format(**coin_data, icon=coin_cfg["icon"]))

    print(config["display"]["separator"].join(coins_data))


if __name__ == "__main__":
    main()
