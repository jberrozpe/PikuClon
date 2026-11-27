#!/usr/bin/env python3
"""Validador de las reglas de estilo PikuClon (docs/ESTILO_PIKUNIKU.md).

Uso:
    python3 tools/validar_estilo.py            # revisa recursos/sprites/*.svg
    python3 tools/validar_estilo.py --escenas   # además revisa repetición en escenas
    python3 tools/validar_estilo.py --verbose  # muestra cada aviso

Código de salida 1 si hay algún FAIL.
"""

import glob
import os
import re
import sys
import xml.etree.ElementTree as ET
from collections import Counter

RAIZ = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

PALETA = {
    "#1d1e26", "#ffffff", "#fff3d6", "#ffd166", "#e9a825", "#e63946",
    "#d90429", "#ff8fa3", "#f4a261", "#588157", "#3f88c5", "#98c1d9",
    "#e8f4f8", "#8c5a32",
}
# Tintes permitidos (mismo tono aclarado/oscurecido) para sombras y brillos.
TINTES_OK = {
    "#f7fbff", "#eaf4ff", "#d6e4f4", "#bfe6ff", "#8fd0f5", "#7fc8f8",
    "#cfe6ff", "#b8d9f7", "#c9ddf2", "#a9c8e8", "#55677a", "#5c6375",
    "#6b647a", "#8c84a0", "#4e4859", "#c89b6a", "#b98a5e", "#d2a874",
    "#c08a58", "#c9915a", "#b5714b", "#eac382", "#f7dfae", "#d3a967",
    "#efc98a", "#e3b471", "#d69f58", "#c9864b", "#f2c46b", "#8a5a34",
    "#e8b54d", "#ffca7a", "#e4572e", "#f2a03d", "#f0b96a", "#ffe6b0",
    "#9fb0c6", "#fff0cd", "#fbe0b2", "#f3cf95", "#7b5a44", "#8fb8dc",
    "#cfe1f2", "#ffe9be", "#f4f9ff", "#d9ae62", "#a7d8ff",
    # paletas de personajes v2
    "#e8434a", "#b5323a", "#f26b63", "#c93a42", "#f2c9a0", "#c99a6e",
    "#f2a03d", "#c97b22", "#ffc46b", "#5c87ac", "#d9a25f", "#a9763b",
    "#e0b074", "#553a2a", "#3a3230", "#2b2d42", "#c4d8e6", "#cfe6ff",
    "#5e7a94", "#3a4a58", "#b07a50", "#efa08c", "#c9b48a", "#7e1f27",
    "#3c5c3b", "#8cbe7c", "#8cbe5e", "#59955b", "#9ac67d", "#61a270",
    "#3f7a52", "#adc983", "#5e3c22", "#4a3324", "#e8c9a8", "#c9a03b",
    "#b8ae9c", "#5e5a54", "#2c6595", "#b57f12", "#d77746", "#f4a450",
    "#f5cb47", "#622e15", "#3e1d0e", "#2e6040", "#1f4327", "#9bb391",
    # paleta del maestro de karate (diseño de Elia)
    "#f5ecf3", "#d2c2d8", "#3fb6d9", "#227a9b", "#3fb24a", "#2c8a38",
    "#5b4632", "#8e2b33",
    # personajes dibujados por Elia (calcados del original)
    "#1a1210", "#a81a18", "#d8231f", "#e9dde8", "#c9b7cb", "#1f7a2c",
    "#2fa83c", "#1b7e99", "#357a2c", "#4caf3e", "#f2b632", "#c08a18",
    "#2b2118", "#3d9a34",
    # alcalde de Elia
    "#1a1a1a", "#1f7a8a", "#2fa3b8", "#b87a12", "#b8912a", "#c9c2b4",
    "#e8a020", "#f2c230", "#f5f1e8",
    # maestro kimono v2 (dibujo nuevo de Elia)
    "#e01f3d", "#a81430", "#5a2a1e", "#3a2318", "#f2d5d8", "#c9a7ac",
    # cueva ampliada: cristales, lava, mural
    "#7fd8f7", "#3d9bc2", "#a9e8ff", "#5fc4e8", "#e8fbff",
    "#b8401a", "#7a2410", "#f2842b", "#ffc24a", "#ffe08a",
    "#5a3a24", "#c48a12",
    "#d9a066", "#c08a50", "#b87a44", "#7a4a24", "#c0503f", "#7a2a20", "#e0a24a", "#8a5a2b", "#c97b45", "#f0d6b0",
    "#2c6b33", "#3e9b37", "#57b85a", "#a9743f",
    # agave, calavera y formación rocosa
    "#39512a", "#5e7a3e", "#7fa158", "#9cbb6e", "#b0cc82",
    "#3a2e22", "#9c8a6a", "#dccfb2", "#e8dcc0", "#f2e7d0",
    "#7a5b45", "#4a3328", "#2e1f18", "#1e1410", "#8a6a50", "#9c7a5c",
    "#4e2e18", "#4e7a3a", "#6e8b4a", "#7ed0e4", "#8a7548", "#a9e4f2", "#b9a277", "#d9be86",
    # jeque
    "#141010", "#2a211c", "#8a7a5a", "#b7a98c", "#c9a227", "#d8cbb0", "#ebc49a", "#f4ebd8", "#fbf6ea",
    # pared de roca de la cueva
    "#4a2a1a", "#5a3420", "#3e2316", "#2e180f", "#6b4028",
    # rockero (zona de pruebas)
    "#4fd1a5", "#2e9c7a", "#7b3f1e", "#4a2410", "#3a1a0a",
    # casa de queso
    "#f2b824", "#c48a12", "#de9b1e", "#de9f1c", "#b87a12", "#5e3a1e", "#b07c4a",
}

TAGS_PROHIBIDOS = ("text", "linearGradient", "radialGradient", "filter", "image")
ATRIBUTOS_PROHIBIDOS = ("style", "stroke-dasharray")
PRIMITIVAS = {"rect", "circle", "ellipse", "path", "polygon", "polyline", "line"}

MAX_FORMAS = 12          # personajes y props
MAX_FORMAS_PERSONAJE = 22  # personajes dibujados por Elia
MAX_FORMAS_EDIFICIO = 28  # edificios/estructuras
EDIFICIOS = {"dojo", "templo_tibetano", "pagoda", "casa_roja", "casa_azul",
             "casa_amarilla", "casita_bosque", "cabana_alpina", "cabina_inglesa",
             "entrada_cueva", "arco_piedra", "globo_viaje", "maquina_fuegos",
             "gradas_plaza", "tejado_espana", "casa_queso"}
MAX_COLORES_PROPIOS = 3
STROKE_MIN, STROKE_MAX = 1.5, 2.5      # contorno fino (v2)
LINEA_MIN, LINEA_MAX = 2.0, 4.5        # trazos sin relleno (patas, cuerdas)

# Arte anterior a la norma: se revisa, pero no bloquea.
LEGADO = {
    "arbol_oscuro", "arco_torii", "banderines", "boton_base",
    "boton_tapa", "cabana_alpina", "cabina_inglesa",
    "caja_madera", "caja_rayo", "casa_amarilla", "casa_azul", "casa_roja",
    "casita_bosque", "cerezo_sakura", "confetti_objeto", "don_cuadrado",
    "edelweiss", "estrella", "farolillo",
    "globo_viaje", "gradas_plaza", "hierba", "jugador_cuerpo",
    "maceta_espana", "maquina_fuegos", "montanas_alpes",
    "noche_espana", "nube", "nube_plataforma", "nube_vapor", "oveja",
    "pelota_rayo", "pieza_brillante", "puerta", "seta_trampolin",
    "tejado_espana", "volcan_fuji",
}


def _leer_baseline():
    ruta = os.path.join(RAIZ, "tools", "baseline_estilo.txt")
    if not os.path.exists(ruta):
        return set()
    return {l.strip() for l in open(ruta, encoding="utf-8") if l.strip()
            and not l.startswith("#")}


class Resultado:
    def __init__(self, ruta):
        self.ruta = ruta
        self.errores = []
        self.avisos = []

    def fail(self, msg):
        self.errores.append(msg)

    def warn(self, msg):
        self.avisos.append(msg)

    @property
    def estado(self):
        if self.errores:
            return "FAIL"
        return "WARN" if self.avisos else "OK"


def revisar_svg(ruta):
    res = Resultado(os.path.relpath(ruta, RAIZ))
    try:
        arbol = ET.parse(ruta)
    except ET.ParseError as exc:
        res.fail(f"XML inválido: {exc}")
        return res

    raiz = arbol.getroot()
    ancho = raiz.get("width", "")
    alto = raiz.get("height", "")
    view = raiz.get("viewBox", "")
    if not ancho or not alto:
        res.fail("sin width/height")
    if view:
        partes = view.replace(",", " ").split()
        if len(partes) == 4 and (partes[2] != ancho.replace("px", "").strip()
                                 or partes[3] != alto.replace("px", "").strip()):
            res.warn("viewBox no coincide con width/height")

    formas = 0
    colores = Counter()
    grosores = []
    grosores_ext = []
    sin_contorno = 0

    for nodo in raiz.iter():
        etiqueta = nodo.tag.split("}")[-1]
        if etiqueta in TAGS_PROHIBIDOS:
            res.fail(f"elemento prohibido <{etiqueta}>")
        if etiqueta in PRIMITIVAS:
            formas += 1
            if not nodo.get("stroke"):
                sin_contorno += 1
        for atributo in ATRIBUTOS_PROHIBIDOS:
            if nodo.get(atributo):
                res.fail(f"atributo prohibido {atributo}")
        opacidad = nodo.get("opacity")
        if opacidad:
            try:
                if float(opacidad) < 0.35:
                    res.fail(f"opacidad {opacidad} < 0.35")
            except ValueError:
                pass
        for campo in ("fill", "stroke"):
            color = (nodo.get(campo) or "").lower()
            if color.startswith("#") and len(color) == 7:
                colores[color] += 1
        if nodo.get("stroke-width"):
            try:
                grosor = float(nodo.get("stroke-width"))
                if (nodo.get("fill") or "").lower() == "none":
                    grosores_ext.append(grosor)
                else:
                    grosores.append(grosor)
            except ValueError:
                pass

    nombre_archivo = os.path.splitext(os.path.basename(ruta))[0]
    if nombre_archivo in ("maestro_karate", "elia_pastor", "npc", "camello_detallado", "palmera_detallada", "jeque"):
        limite = MAX_FORMAS_PERSONAJE
    elif nombre_archivo in EDIFICIOS:
        limite = MAX_FORMAS_EDIFICIO
    else:
        limite = MAX_FORMAS
    if formas > limite:
        res.fail(f"{formas} formas (máximo {limite})")
    elif formas > limite * 0.75:
        res.warn(f"{formas} formas, cerca del máximo ({limite})")
    if sin_contorno > 0:
        res.warn(f"{sin_contorno} forma(s) sin contorno")

    for g in grosores:
        if g < STROKE_MIN or g > STROKE_MAX:
            res.fail(f"contorno de {g} px (se espera {STROKE_MIN}-{STROKE_MAX})")
            break
    for g in grosores_ext:
        if g < LINEA_MIN or g > LINEA_MAX:
            res.fail(f"trazo sin relleno de {g} px (se espera {LINEA_MIN}-{LINEA_MAX})")
            break

    propios = {c for c in colores if c not in PALETA and c not in TINTES_OK}
    if len(propios) > MAX_COLORES_PROPIOS:
        res.fail(f"{len(propios)} colores propios: {', '.join(sorted(propios))}")
    elif propios:
        res.warn(f"colores propios: {', '.join(sorted(propios))}")

    nombre = os.path.splitext(os.path.basename(ruta))[0]
    pendientes = _leer_baseline()
    if nombre in pendientes and res.errores:
        res.avisos = [f"(pendiente) {e}" for e in res.errores] + res.avisos
        res.errores = []
    if nombre in LEGADO and res.errores:
        res.avisos = [f"(legado) {e}" for e in res.errores] + res.avisos
        res.errores = []
    return res


def revisar_escenas():
    """Repetición por PANTALLA (ventana de 1152 px), no por nivel entero.

    Los objetos de misión (tablones, dianas, rocas, enemigos) están exentos:
    la misión exige varios iguales.
    """
    EXENTOS = {
        "tablon_madera.svg", "diana_madera.svg", "roca_nieve.svg",
        "yeti.svg", "pieza_brillante.svg", "estrella.svg",
        "confetti_objeto.svg", "jarron.svg", "monton_monedas.svg",
        "monton_monedas_b.svg", "monton_monedas_c.svg", "joyas.svg",
        "joyas_grandes.svg",
        # maleza y adornos diminutos: repetirlos es natural
        "hierba.svg", "edelweiss.svg", "farolillo.svg", "banderines.svg",
    }
    problemas = []
    for escena in sorted(glob.glob(os.path.join(RAIZ, "escenas", "*.tscn"))):
        texto = open(escena, encoding="utf-8", errors="ignore").read()
        if "ext_resource" not in texto:
            continue
        recursos = dict(re.findall(
            r'\[ext_resource type="Texture2D" path="([^"]+)" id="([^"]+)"\]', texto))
        recursos = {v: k for k, v in recursos.items()}

        elementos = []
        for bloque in re.split(r"(?m)^\[node ", texto)[1:]:
            cabecera = bloque.split("\n", 1)[0]
            if 'type="Sprite2D"' not in cabecera:
                continue
            m = re.search(r'texture = ExtResource\("([^"]+)"\)', bloque)
            pos = re.search(r'position = Vector2\(([-\d.]+), ([-\d.]+)\)', bloque)
            if not m or not pos:
                continue
            escala = re.search(r'scale = Vector2\(([\d.]+), ([\d.]+)\)', bloque)
            ruta = recursos.get(m.group(1), m.group(1))
            if os.path.basename(ruta) in EXENTOS:
                continue
            elementos.append((float(pos.group(1)), os.path.basename(ruta),
                              escala.groups() if escala else ("1", "1")))

        elementos.sort()
        for i, (x, ruta, escala) in enumerate(elementos):
            ventana = [(x2, r2) for x2, r2, e2 in elementos[i:]
                       if x2 - x <= 1152.0 and (r2, e2) == (ruta, escala)]
            if len(ventana) > 2:
                problemas.append(
                    f"{os.path.basename(escena)}: {len(ventana)}× {ruta} "
                    f"juntos a escala {escala} (máximo 2 por pantalla)")
                break
    return problemas


def main():
    argumentos = sys.argv[1:]
    verbose = "--verbose" in argumentos

    rutas = sorted(glob.glob(os.path.join(RAIZ, "recursos", "sprites", "*.svg")))
    resultados = [revisar_svg(r) for r in rutas]

    fallos = [r for r in resultados if r.estado == "FAIL"]
    avisos = [r for r in resultados if r.estado == "WARN"]

    print(f"Revisando {len(resultados)} sprites…\n")
    for res in resultados:
        if res.estado == "OK" and not verbose:
            continue
        print(f"[{res.estado}] {res.ruta}")
        for e in res.errores:
            print(f"    ✗ {e}")
        for a in res.avisos:
            print(f"    · {a}")

    if "--escenas" in argumentos:
        print("\nRepetición en escenas:")
        problemas = revisar_escenas()
        if problemas:
            for p in problemas:
                print(f"    ✗ {p}")
            fallos.append(True)
        else:
            print("    OK")

    print(f"\nResumen: {len(resultados) - len(fallos) - len(avisos)} OK, "
          f"{len(avisos)} WARN, {len(fallos)} FAIL")
    return 1 if fallos else 0


if __name__ == "__main__":
    sys.exit(main())
