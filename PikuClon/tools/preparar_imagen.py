#!/usr/bin/env python3
"""Prepara una imagen entrante para usarla como sprite del juego.

    python3 tools/preparar_imagen.py entrada.png salida.png \
        --alto 120 --quitar-fondo --paleta

- recorta el margen transparente
- opcional: elimina un fondo liso (esquinas)
- escala para que el alto sea el indicado
- opcional: cuantiza a la paleta PikuClon
"""

import argparse
import os
import sys

from PIL import Image

PALETA = [
    (0x1D, 0x1E, 0x26), (0xFF, 0xFF, 0xFF), (0xFF, 0xF3, 0xD6),
    (0xFF, 0xD1, 0x66), (0xE9, 0xA8, 0x25), (0xE6, 0x39, 0x46),
    (0xD9, 0x04, 0x29), (0xFF, 0x8F, 0xA3), (0xF4, 0xA2, 0x61),
    (0x58, 0x81, 0x57), (0x3F, 0x88, 0xC5), (0x98, 0xC1, 0xD9),
    (0xE8, 0xF4, 0xF8), (0x8C, 0x5A, 0x32),
]


def quitar_fondo(imagen):
    """Hace transparente el color dominante de las esquinas."""
    imagen = imagen.convert("RGBA")
    ancho, alto = imagen.size
    pixeles = imagen.load()
    esquinas = [pixeles[0, 0], pixeles[ancho - 1, 0],
                pixeles[0, alto - 1], pixeles[ancho - 1, alto - 1]]
    fondo = max(set(esquinas), key=esquinas.count)
    tolerancia = 26
    for y in range(alto):
        for x in range(ancho):
            r, g, b, a = pixeles[x, y]
            if (abs(r - fondo[0]) <= tolerancia and abs(g - fondo[1]) <= tolerancia
                    and abs(b - fondo[2]) <= tolerancia):
                pixeles[x, y] = (r, g, b, 0)
    return imagen


def recortar(imagen):
    caja = imagen.getbbox()
    return imagen.crop(caja) if caja else imagen


def escalar(imagen, alto):
    if alto <= 0:
        return imagen
    factor = alto / imagen.height
    return imagen.resize((max(1, round(imagen.width * factor)), alto),
                         Image.LANCZOS)


def cuantizar(imagen):
    paleta = Image.new("P", (1, 1))
    plana = []
    for color in PALETA:
        plana.extend(color)
    plana.extend([0, 0, 0] * (256 - len(PALETA)))
    paleta.putpalette(plana)
    rgb = imagen.convert("RGB").quantize(palette=paleta, dither=Image.Dither.NONE)
    resultado = rgb.convert("RGBA")
    resultado.putalpha(imagen.getchannel("A"))
    return resultado


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("entrada")
    parser.add_argument("salida")
    parser.add_argument("--alto", type=int, default=0)
    parser.add_argument("--quitar-fondo", action="store_true")
    parser.add_argument("--paleta", action="store_true")
    parser.add_argument("--sin-recorte", action="store_true")
    args = parser.parse_args()

    if not os.path.exists(args.entrada):
        sys.exit(f"No existe: {args.entrada}")

    imagen = Image.open(args.entrada).convert("RGBA")
    if args.quitar_fondo:
        imagen = quitar_fondo(imagen)
    if not args.sin_recorte:
        imagen = recortar(imagen)
    if args.alto:
        imagen = escalar(imagen, args.alto)
    if args.paleta:
        imagen = cuantizar(imagen)

    os.makedirs(os.path.dirname(os.path.abspath(args.salida)), exist_ok=True)
    imagen.save(args.salida)
    print(f"{args.salida}: {imagen.width}x{imagen.height}")


if __name__ == "__main__":
    main()
