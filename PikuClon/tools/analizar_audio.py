#!/usr/bin/env python3
"""Analiza una pista de música antes de meterla en el juego.

    python3 tools/analizar_audio.py cancion.mp3

Informa de formato, duración, nivel (pico y RMS), silencio al principio y al
final, y avisa si el bucle completo va a chasquear.
"""

import audioop
import os
import subprocess
import sys
import tempfile
import wave


def decodificar(ruta: str) -> str:
    """Devuelve un WAV temporal (afconvert decodifica mp3/ogg/flac/m4a)."""
    if ruta.lower().endswith(".wav"):
        return ruta
    destino = os.path.join(tempfile.gettempdir(), "analisis_audio.wav")
    subprocess.run(
        ["afconvert", "-f", "WAVE", "-d", "LEI16@44100", ruta, destino],
        check=True, capture_output=True)
    return destino


def analizar(ruta: str) -> None:
    wav_ruta = decodificar(ruta)
    with wave.open(wav_ruta, "rb") as w:
        canales = w.getnchannels()
        ancho = w.getsampwidth()
        frecuencia = w.getframerate()
        fotogramas = w.getnframes()
        datos = w.readframes(fotogramas)

    duracion = fotogramas / float(frecuencia)
    pico = audioop.max(datos, ancho) / 32768.0
    rms = audioop.rms(datos, ancho) / 32768.0

    # Silencio inicial y final (umbral -50 dB)
    umbral = 32768 * 0.003
    bloque = int(frecuencia * 0.02) * ancho * canales
    inicio = 0
    while inicio < len(datos):
        if audioop.rms(datos[inicio:inicio + bloque], ancho) > umbral:
            break
        inicio += bloque
    fin = len(datos)
    while fin > 0:
        desde = max(0, fin - bloque)
        if audioop.rms(datos[desde:fin], ancho) > umbral:
            break
        fin = desde

    silencio_inicio = inicio / (frecuencia * ancho * canales)
    silencio_fin = (len(datos) - fin) / (frecuencia * ancho * canales)

    # Diferencia entre el final y el principio: si es grande, el bucle chasquea
    muestras_inicio = audioop.tomono(datos[:bloque], ancho, 0.5, 0.5)
    muestras_fin = audioop.tomono(datos[-bloque:], ancho, 0.5, 0.5)
    salto = abs(audioop.rms(muestras_fin, ancho) - audioop.rms(muestras_inicio, ancho))

    print(f"Archivo:      {os.path.basename(ruta)}")
    print(f"Formato:      {canales} canales · {frecuencia} Hz · {ancho * 8} bits")
    print(f"Duración:     {int(duracion // 60)}:{duracion % 60:05.2f}")
    print(f"Pico:         {20 * __import__('math').log10(max(pico, 1e-6)):.1f} dBFS")
    print(f"RMS:          {20 * __import__('math').log10(max(rms, 1e-6)):.1f} dBFS")
    print(f"Silencio ini: {silencio_inicio * 1000:.0f} ms")
    print(f"Silencio fin: {silencio_fin * 1000:.0f} ms")
    if silencio_inicio > 0.15 or silencio_fin > 0.15:
        print("Aviso:        hay silencio en los extremos; conviene recortarlo")
    if salto > 0.02:
        print("Aviso:        el final y el principio difieren; el bucle puede chasquear")


if __name__ == "__main__":
    if len(sys.argv) != 2:
        sys.exit("Uso: python3 tools/analizar_audio.py archivo.mp3")
    analizar(sys.argv[1])
