"""Generate a short notification WAV (archarena - design/orders app)."""
import wave
import struct
import math
import os

# Short gentle tone: 523 Hz (C5), 0.25 sec, soft
sample_rate = 44100
duration_sec = 0.25
freq = 523
volume = 0.25

script_dir = os.path.dirname(os.path.abspath(__file__))
out_path = os.path.join(
    script_dir, "..", "android", "app", "src", "main", "res", "raw", "notification_sound.wav"
)
out_path = os.path.normpath(out_path)
os.makedirs(os.path.dirname(out_path), exist_ok=True)

n_samples = int(sample_rate * duration_sec)
frames = []
for i in range(n_samples):
    t = i / sample_rate
    # Soft beep with slight fade
    fade = 1.0 if i < n_samples * 0.8 else (n_samples - i) / (n_samples * 0.2)
    s = int(32767 * volume * fade * math.sin(2 * math.pi * freq * t))
    frames.append(struct.pack("<h", max(-32768, min(32767, s))))

with wave.open(out_path, "wb") as w:
    w.setnchannels(1)
    w.setsampwidth(2)
    w.setframerate(sample_rate)
    w.writeframes(b"".join(frames))

print("Created:", out_path)
