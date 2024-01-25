#!/usr/bin/env python3

"""Fetch USD blue value from finanzasargy."""

import requests
from requests.exceptions import HTTPError, Timeout


def sign(x: int) -> int:
    """Get sign for x"""
    if x < 0:
        return -1
    elif x == 0:
        return 0
    return 1


def main():
    """Fetch and display USD blue value."""
    try:
        headers = {
            "api-client": "finanzasargy",
            "Access-Control-Allow-Origin": "*",
            "Accept": "application/json, text/plain, */*",
            "Referer": "https://www.finanzasargy.com/",
        }

        res = requests.get(
            "https://backend-ifa-production-a92c.up.railway.app/api/mercado-blue",
            headers=headers,
            timeout=120,
        )
        res.raise_for_status()
        data = res.json()
        blue = [x for x in data if x["titulo"] == "Dólar Blue"][0]
        compra = int(blue["compra"])
        venta = int(blue["venta"])
        cierre_anterior = int(blue["cierre"])
        diff = venta - cierre_anterior
        symbol = {-1: "-", 0: "", 1: "+"}[sign(diff)]
        print(f"󰈸 {compra}/{venta}/{symbol}{abs(diff)}/{(venta/cierre_anterior)-1:.2%}")
    except (Timeout, HTTPError):
        print(f"󱗗 ({res.status_code})")


if __name__ == "__main__":
    main()
