import wave
import math
import struct
import os

def generate_wave(filename):
    sample_rate = 44100
    duration = 1.0 # seconds
    volume = 0.5

    # C Major Arpeggio: C5, E5, G5, C6
    notes = [
        (523.25, 0.15),
        (659.25, 0.15),
        (783.99, 0.15),
        (1046.50, 0.55)
    ]

    audio = []
    
    current_time = 0.0
    for freq, note_duration in notes:
        num_samples = int(note_duration * sample_rate)
        for i in range(num_samples):
            # Apply decay envelope
            t = float(i) / sample_rate
            envelope = 1.0 - (t / note_duration)
            
            sample = volume * envelope * math.sin(2 * math.pi * freq * (current_time + t))
            audio.append(sample)
        current_time += note_duration

    # Ensure exact length if rounding caused drift, or simple concatenation
    # Re-writing for simpler concatenation loop
    
    final_audio = []
    
    # C5
    for i in range(int(0.15 * sample_rate)):
        t = i / sample_rate
        sample = volume * math.sin(2 * math.pi * 523.25 * t) * (1 - (i/(0.15*sample_rate)))
        final_audio.append(sample)
    
    # E5
    for i in range(int(0.15 * sample_rate)):
        t = i / sample_rate
        sample = volume * math.sin(2 * math.pi * 659.25 * t) * (1 - (i/(0.15*sample_rate)))
        final_audio.append(sample)
        
    # G5
    for i in range(int(0.15 * sample_rate)):
        t = i / sample_rate
        sample = volume * math.sin(2 * math.pi * 783.99 * t) * (1 - (i/(0.15*sample_rate)))
        final_audio.append(sample)

    # C6 (Longer)
    for i in range(int(0.6 * sample_rate)):
        t = i / sample_rate
        sample = volume * math.sin(2 * math.pi * 1046.50 * t) * math.exp(-3 * t) # Exponential decay
        final_audio.append(sample)

    # Write WAV file
    with wave.open(filename, 'w') as wav_file:
        wav_file.setnchannels(1) # Mono
        wav_file.setsampwidth(2) # 16-bit
        wav_file.setframerate(sample_rate)
        
        for sample in final_audio:
            # Clamp to -1..1
            sample = max(-1.0, min(1.0, sample))
            # Convert to 16-bit integer
            data = int(sample * 32767.0)
            wav_file.writeframes(struct.pack('<h', data))

    print(f"Generated {filename}")

def generate_fire_sound(filename):
    sample_rate = 44100
    duration = 1.5
    volume = 0.6
    
    num_samples = int(duration * sample_rate)
    samples = []
    
    # Brownian noise state
    last_val = 0.0
    
    import random
    
    for i in range(num_samples):
        # 1. Rumble (Brownian Noise - approximating low pass filtered noise)
        white = random.uniform(-1.0, 1.0)
        last_val = (last_val + (white * 0.1)) * 0.95 # Leaky integrator
        
        # 2. Crackle (Random sharp spikes)
        crackle = 0.0
        if random.random() < 0.005: # 0.5% chance per sample is too high, 0.05%?
             # Actually let's do fewer pops. 
             pass
        
        # Better crackle: random spikes
        if random.random() < 0.0005: # Rare pops
             crackle = random.uniform(0.5, 1.0) * (1 if random.random() < 0.5 else -1)

        # Mix
        mixed = (last_val * 0.5) + crackle
        samples.append(mixed)

    # Normalize
    max_val = max(abs(s) for s in samples)
    if max_val > 0:
        samples = [s * (volume / max_val) for s in samples]

    # Write WAV
    with wave.open(filename, 'w') as wav_file:
        wav_file.setnchannels(1)
        wav_file.setsampwidth(2)
        wav_file.setframerate(sample_rate)
        
        for sample in samples:
            sample = max(-1.0, min(1.0, sample))
            data = int(sample * 32767.0)
            wav_file.writeframes(struct.pack('<h', data))

    print(f"Generated {filename}")

if __name__ == "__main__":
    if not os.path.exists('assets/audio'):
        os.makedirs('assets/audio')
    generate_wave('assets/audio/success.wav')
    generate_fire_sound('assets/audio/fire.wav')
