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
        res = requests.get(
            "https://backend-ifa-production.up.railway.app/api/dolar/v2/general",
            timeout=60,
        )
        res.raise_for_status()
        panel = res.json()["panel"]
        blue = [x for x in panel if x["titulo"] == "Dólar Blue"][0]
        compra = int(blue["compra"])
        venta = int(blue["venta"])
        cierre_anterior = int(blue["cierre"])
        diff = venta - cierre_anterior
        symbol = {-1: "-", 0: "", 1: "+"}[sign(diff)]
        print(f"󰈸 {compra}/{venta}/{symbol}{abs(diff)}/{(venta/cierre_anterior)-1:.2%}")
    except (Timeout, HTTPError):
        print("󱗗")


if __name__ == "__main__":
    main()
