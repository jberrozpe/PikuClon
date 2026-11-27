#!/usr/bin/env python3
"""Convierte una foto de dibujo en un sprite limpio, plano y suavizado.

    python3 tools/preparar_personaje.py entrada.jpg salida.png --paleta maestro

No cambia las formas: recorta, quita el papel, aplana colores y suaviza los
bordes. La altura final se fija en la escena de Godot.
"""

import argparse
import sys

import numpy as np
from PIL import Image, ImageFilter, ImageOps

PALETAS = {
    "maestro": {
        "rojo": (216, 35, 31), "negro": (26, 18, 16), "kimono": (231, 216, 227),
        "faja": (43, 169, 201), "verde": (47, 168, 60), "marron": (107, 58, 34),
        "blanco": (255, 255, 255),
    },
    "pastor": {
        "verde": (76, 175, 62), "amarillo": (242, 182, 50),
        "azul": (46, 155, 196), "marron": (107, 58, 34),
        "negro": (26, 18, 16), "blanco": (255, 255, 255),
    },
}


def clasificar(rgb, hsv, paleta):
    H, S, V = hsv[:, :, 0], hsv[:, :, 1], hsv[:, :, 2]
    defecto = "kimono" if "kimono" in paleta else "amarillo"
    clase = np.full(H.shape, defecto, dtype=object)
    if "rojo" in paleta:
        clase[(V > 205) & (S < 65)] = "kimono"
        clase[V < 70] = "negro"
        clase[(V >= 70) & (S > 90) & ((H < 13) | (H > 240))] = "rojo"
        clase[(V >= 70) & (S > 85) & (H >= 112) & (H <= 152)] = "faja"
        clase[(V >= 70) & (S > 85) & (H >= 56) & (H < 112)] = "verde"
        clase[(V >= 70) & (S > 70) & (H >= 13) & (H < 56) & (V < 170)] = "marron"
        cerca = Image.fromarray(((clase == "negro") * 255).astype("uint8")).filter(ImageFilter.MaxFilter(13))
        clase[((V > 236) & (S < 55) & (np.asarray(cerca) > 127))] = "blanco"
    else:
        clase[V < 80] = "negro"
        clase[(V >= 80) & (S > 80) & (H >= 55) & (H < 115)] = "verde"
        clase[(V >= 80) & (S > 95) & (H >= 18) & (H < 55)] = "amarillo"
        clase[(V >= 80) & (S > 85) & (H >= 115) & (H <= 155)] = "azul"
        clase[(V >= 80) & (S > 60) & (H < 18) & (V < 160)] = "marron"
        clase[(V > 232) & (S < 45)] = "blanco"
    return clase


def preparar(ruta, salida, nombre_paleta, alto=180):
    paleta = PALETAS[nombre_paleta]
    im = ImageOps.exif_transpose(Image.open(ruta)).convert("RGB")

    lienzo = np.asarray(im).astype(int)
    mx, mn = lienzo.max(axis=2), lienzo.min(axis=2)
    sat = (mx - mn) / np.maximum(mx, 1)
    val = mx / 255.0
    contenido = (sat > 0.28) | (val < 0.52)
    ys, xs = np.where(contenido)
    im = im.crop((max(0, xs.min() - 40), max(0, ys.min() - 40),
                  min(im.width, xs.max() + 40), min(im.height, ys.max() + 40)))

    rgb = np.asarray(im.filter(ImageFilter.MedianFilter(5))).astype(int)
    hsv = np.asarray(im.convert("HSV").filter(ImageFilter.MedianFilter(5))).astype(int)
    mx, mn = rgb.max(axis=2), rgb.min(axis=2)
    sat = (mx - mn) / np.maximum(mx, 1)
    val = mx / 255.0

    clase = clasificar(rgb, hsv, paleta)

    # máscara del personaje (no papel) + suavizado morfológico
    papel = (((sat < 0.19) & (val > 0.30) & (val < 0.86))
             | ((val > 0.90) & (sat < 0.06)))
    alto_m, ancho_m = papel.shape
    fondo = np.zeros_like(papel)
    for y in range(alto_m):
        x = 0
        while x < ancho_m and papel[y, x]:
            fondo[y, x] = True; x += 1
        x = ancho_m - 1
        while x >= 0 and papel[y, x]:
            fondo[y, x] = True; x -= 1
    for x in range(ancho_m):
        y = 0
        while y < alto_m and papel[y, x]:
            fondo[y, x] = True; y += 1
        y = alto_m - 1
        while y >= 0 and papel[y, x]:
            fondo[y, x] = True; y -= 1
    for y in range(alto_m):
        cols = np.where(papel[y] | fondo[y])[0]
        if len(cols) > 1:
            fondo[y, cols.min():cols.max() + 1] |= papel[y, cols.min():cols.max() + 1]
    for x in range(ancho_m):
        cols = np.where(papel[:, x] | fondo[:, x])[0]
        if len(cols) > 1:
            fondo[cols.min():cols.max() + 1, x] |= papel[cols.min():cols.max() + 1, x]

    # suavizar fronteras de color y de silueta
    orden = list(paleta)
    mapa = {nombre: i for i, nombre in enumerate(orden)}
    indices = np.vectorize(mapa.get)(clase).astype("uint8")
    clase_img = Image.fromarray(indices)
    clase_img = clase_img.filter(ImageFilter.MedianFilter(9))
    mascara = Image.fromarray(((~fondo) * 255).astype("uint8"))
    mascara = mascara.filter(ImageFilter.MaxFilter(5)).filter(ImageFilter.MinFilter(9))
    mascara = mascara.filter(ImageFilter.GaussianBlur(3))
    mascara = mascara.point(lambda v: 255 if v > 128 else 0)
    mascara = mascara.filter(ImageFilter.MedianFilter(7))

    clases = np.asarray(clase_img)
    nombres = list(paleta)
    salida_img = np.zeros((alto_m, ancho_m, 4), dtype=np.uint8)
    for i, nombre in enumerate(nombres):
        color = paleta[nombre]
        m = clases == i
        for c in range(3):
            salida_img[m, c] = color[c]
    salida_img[:, :, 3] = np.asarray(mascara)

    # recortar a la silueta con color (excluye la sombra gris del papel)
    color = (sat > 0.22) | (val < 0.45)
    ys2, xs2 = np.where(color)
    caja = (int(xs2.min()), int(ys2.min()), int(xs2.max()) + 1, int(ys2.max()) + 1)
    res = Image.fromarray(salida_img, "RGBA").crop(caja)
    res = res.resize((round(res.width * alto / res.height), alto), Image.LANCZOS)
    res.save(salida)
    print(f"{salida}: {res.size[0]}x{res.size[1]}")


if __name__ == "__main__":
    ap = argparse.ArgumentParser()
    ap.add_argument("entrada")
    ap.add_argument("salida")
    ap.add_argument("--paleta", required=True, choices=sorted(PALETAS))
    ap.add_argument("--alto", type=int, default=180)
    args = ap.parse_args()
    preparar(args.entrada, args.salida, args.paleta, args.alto)
