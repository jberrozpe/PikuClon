# Reglas de estilo PikuClon (estilo Pikuniku)

> Versión 1.0 · documento normativo. Toda pieza de arte nueva debe cumplirlo.
> Se valida automáticamente con `python3 tools/validar_estilo.py`.

La idea no es "dibujar bonito": es que **cualquier asset encaje sin discusión**.
Si una regla no se puede medir, no es una regla.

---

## 1. Paleta oficial (solo estos colores)

| Uso | Hex |
|---|---|
| Tinta / contorno | `#1D1E26` |
| Blanco | `#FFFFFF` |
| Crema | `#FFF3D6` |
| Amarillo | `#FFD166` |
| Oro | `#E9A825` |
| Rojo | `#E63946` |
| Rojo fuerte | `#D90429` |
| Rosado | `#FF8FA3` |
| Naranja | `#F4A261` |
| Verde | `#588157` |
| Azul | `#3F88C5` |
| Azul cielo | `#98C1D9` |
| Azul pálido | `#E8F4F8` |
| Madera | `#8C5A32` |

**Reglas de color**
- Máximo **3 colores propios** por asset, además de tinta, blanco y crema.
- Un color de sombra es el mismo tono oscurecido, no un color nuevo.
- Prohibidos degradados. La profundidad se hace con **capas planas**.
- Prohibido el negro puro y el gris neutro: la tinta es `#1D1E26`.

## 2. Trazo (v2 · contorno fino)

- Contorno **fino: 1.5–2.5 px**, en un tono **oscurecido del propio relleno**
  (rojo → `#B5323A`, arena → `#A9763B`, blanco → `#C4D8E6`).
- **Nunca negro puro** salvo en ojos, y nunca el trazo grueso de la v1.
- Trazos sin relleno (`fill="none"`): patas, cuerdas y brillos, **2–4.5 px**.
- `stroke-linejoin="round"` y `stroke-linecap="round"` en todo lo curvo.
- Profundidad: **2 tonos planos** (base + sombra o luz), sin degradados.

## 2 bis. Paletas por zona (de las referencias)

| Zona | Base | Sombra | Luz |
|---|---|---|---|
| Pradera / pueblo | `#8CBE5E` | `#59955B` | `#9AC67D` |
| Japón | `#61A270` | `#3F7A52` | `#ADC983` |
| Tíbet / hielo | `#74DFE2` | `#5C7A83` | `#F7FDFD` |
| Desierto | `#FAC262` | `#D77746` | `#F4A450` |
| Cueva | `#622E15` | `#3E1D0E` | `#F5CB47` |
| Bosque | `#2E6040` | `#1F4327` | `#9BB391` |
| Personajes | `#E8434A` | `#B5323A` | `#F26B63` |
| Elia · maestro | kimono `#F5ECF3` | faja `#3FB6D9` | abanico `#3FB24A` |

## 3. Forma

- **Presupuesto de formas: 12 primitivas como máximo** por asset (16 en los
  personajes dibujados por Elia, que se calcan del original)
  (rect, circle, ellipse, path, polygon, line). Si necesitas más, simplifica.
- Silueta reconocible en 1 segundo y **en negro**: si al rellenarla de negro no se
  entiende qué es, está mal.
- Esquinas y extremos siempre redondeados. La geometría recta solo para muebles,
  puertas y estructuras.
- Nada de detalle menudo: ventanas diminutas, tornillos, collares, tramados,
  texturas o líneas paralelas decorativas.

## 4. Personajes

- Cuerpo **bola** (ancho ≈ alto) con un solo color de relleno y, como mucho,
  una zona interior más clara.
- **Ojos punto**: dos círculos negros de **6–8 % del alto**, sin brillo.
  Boca opcional de un solo trazo; mofletes solo en personajes infantiles.
- **Patas de palo**: 2 trazos negros de 5 px que llegan al borde inferior del SVG.
  Sin zapatos dibujados salvo una línea de pie.
- Altura de referencia: **62 px el protagonista**, 90–120 px un adulto,
  130–150 px un ser grande. Nunca más de 2.5× el protagonista.
- Los personajes **no llevan sombra ni textura**. La expresividad está en los ojos.

## 5. Props y arquitectura

- Edificios: base recta apoyada en el borde inferior, tejado de 2–3 piezas,
  una puerta y **como mucho dos ventanas**.
- Rocas: una silueta + un gorro o una grieta. Nunca facetas múltiples.
- Vegetación: tronco + 3–5 hojas grandes. Nada de hojas pequeñas.
- Hielo: formas redondeadas con un brillo; nunca puntas afiladas tipo cristal roto.

## 6. Paisaje y niveles

- Fondo en **3 capas** como máximo (cielo, lejano, medio) + suelo.
- Las capas lejanas van **desaturadas** (más cerca del color del cielo).
- El sol es un disco con halo; los rayos, triángulos gruesos que giran.
- **Nada flota**: todo sprite apoyado en el suelo se coloca con
  `pie(alto, escala)`; las terrazas llevan base de roca hasta el suelo.
- Regla de repetición: **máximo 2 instancias** del mismo sprite con la misma
  escala por pantalla. La variedad se hace con escala, volteo o variantes.
- Aire: mínimo un 35 % de la pantalla sin elementos en la zona de juego.

## 7. Prohibido (falla automáticamente)

`<text>`, `linearGradient`, `radialGradient`, `filter`, `<image>`,
`style=`, `stroke-dasharray`, opacidad < 0.35, más de 12 formas,
más de 3 colores propios, trazos fuera de 2.5–3.5.

## 8. Checklist antes de dar un asset por bueno

1. ¿Se reconoce en negro a 64 px?
2. ¿Tiene contorno de 2.5–3.5?
3. ¿Usa solo la paleta (+3 propios)?
4. ¿12 formas o menos?
5. ¿Personaje con ojos grandes y patas de palo?
6. ¿Apoyado en el borde inferior (base recta)?
7. ¿Sin degradados, textos ni filtros?
8. ¿Se distingue de los otros assets del mismo tipo?
9. ¿Aguanta al lado del protagonista sin parecer de otro juego?
10. ¿Aporta algo o solo rellena?

Si alguna respuesta es "no", el asset no entra.

## 9. Cómo se hace cumplir

```bash
python3 tools/validar_estilo.py            # sprites
python3 tools/validar_estilo.py --escenas  # + repetición en niveles
```

- **FAIL** = el asset no entra.
- **WARN** = aceptable, pero anotado.
- `tools/baseline_estilo.txt` es la lista de deuda técnica: assets antiguos
  pendientes de simplificar. Un asset nuevo **no** puede añadirse a esa lista:
  debe pasar la norma desde el primer momento.
