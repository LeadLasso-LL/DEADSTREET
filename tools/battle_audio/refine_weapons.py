"""Original dry weapon reports with distinct construction per weapon class."""
from pathlib import Path
import hashlib
import json
import wave
import numpy as np

ROOT = Path(__file__).resolve().parents[2]
R = ROOT / 'assets/audio/harold'
SR = 48000
SEED = 20260911
rng = np.random.default_rng(SEED)
IDENTITIES = {
    'smg': 'Short, midrange mechanical bark; fast cutoff for repeated fire.',
    'pistol': 'Compact, rounded pressure pop with a restrained slide click.',
    'rifle': 'Sharp broadband crack over a rough, forceful low-mid report.',
    'shotgun': 'Wide, weighty blast with a longer low body and dry action detail.',
}

def band(a, lo, hi):
    f = np.fft.rfftfreq(len(a), 1 / SR)
    h = (1 - np.exp(-(f / max(lo, 1)) ** 4)) * np.exp(-(f / hi) ** 4)
    return np.fft.irfft(np.fft.rfft(a) * h, n=len(a))

def texture(t, lo, hi, decay):
    a = band(rng.normal(size=len(t)), lo, hi)
    a /= max(np.sqrt(np.mean(a * a)), 1e-8)
    return a * np.exp(-t / decay)

def pressure(t, width):
    # A single bipolar pressure transient, never a pitched oscillator/drum tone.
    x = t / width
    return (1 - x) * np.exp(-x)

def mechanical(t, at, gain, duration, lo, hi):
    out = np.zeros_like(t)
    n = int(at * SR)
    if n < len(t):
        out[n:] = gain * texture(t[:len(t)-n], lo, hi, duration)
    return out

def make(kind):
    t = np.arange(int(SR * .65)) / SR
    jitter = rng.uniform(.94, 1.06)
    if kind == 'smg':
        # Deliberately compact and mid-heavy, with almost no lingering bass.
        out = .85 * texture(t, 650, 4400, .007 * jitter)
        out += .40 * texture(t, 2300, 8500, .0013)
        out += .26 * pressure(t, .00065)
        out *= np.exp(-(t / .036) ** 4)
        out += mechanical(t, .034, .08, .003, 1400, 4500)
    elif kind == 'pistol':
        # Broad pressure pop; less abrasive high-frequency energy than the rifle.
        out = 1.3 * pressure(t, .0015 * jitter)
        out += .48 * texture(t, 220, 2900, .013 * jitter)
        out += .22 * texture(t, 2200, 6800, .002)
        out += mechanical(t, .062, .045, .004, 1600, 5200)
    elif kind == 'rifle':
        # Strong leading crack followed by a dense, irregular report, no echo.
        out = 1.05 * texture(t, 3200, 17000, .0028 * jitter)
        out += .80 * texture(t, 420, 7800, .019 * jitter)
        out += .48 * texture(t, 100, 950, .030)
        out += .5 * pressure(t, .00045)
        out += mechanical(t, .082, .055, .004, 1100, 4800)
    else:
        # Weight audible above sub-bass, so it survives phone speakers too.
        out = 1.0 * pressure(t, .0024 * jitter)
        out += .95 * texture(t, 70, 1300, .052 * jitter)
        out += .58 * texture(t, 280, 3900, .032)
        out += .33 * texture(t, 2200, 9000, .0038)
        out *= np.exp(-(t / .19) ** 3)
        out += mechanical(t, .23, .06, .014, 600, 3000)
        out += mechanical(t, .31, .045, .006, 1200, 4200)
    # Remove DC and gently soften peaks without adding a reverberant tail.
    out = band(out, 38, 18000)
    out = np.tanh(out * .8)
    out[:8] *= np.linspace(0, 1, 8)
    out[-240:] *= np.linspace(1, 0, 240)
    out *= .88 / max(abs(out))
    return out

def main():
    R.mkdir(parents=True, exist_ok=True)
    weapon_names = {f'{k}_{i}.wav' for k in IDENTITIES for i in range(3)}
    preserved = {p.name: hashlib.sha256(p.read_bytes()).hexdigest()
                 for p in R.glob('*.wav') if p.name not in weapon_names}
    report = {}
    for kind in IDENTITIES:
        for i in range(3):
            out = make(kind)
            assert np.all(np.isfinite(out)) and max(abs(out)) < 1
            data = (out * 32767).astype('<i2')
            path = R / f'{kind}_{i}.wav'
            with wave.open(str(path), 'wb') as w:
                w.setnchannels(1)
                w.setsampwidth(2)
                w.setframerate(SR)
                w.writeframes(data.tobytes())
            energy = np.cumsum(out * out)
            spectrum = abs(np.fft.rfft(out)) ** 2
            f = np.fft.rfftfreq(len(out), 1 / SR)
            report[path.name] = {
                'peak_dbfs': float(20 * np.log10(max(abs(out)))),
                'rms_dbfs': float(20 * np.log10(np.sqrt(np.mean(out * out)))) ,
                'energy_90_ms': float(np.searchsorted(energy, energy[-1] * .9) / SR * 1000),
                'energy_centroid_hz': float(np.sum(spectrum * f) / np.sum(spectrum)),
                'seconds': len(out) / SR,
                'sha256': hashlib.sha256(path.read_bytes()).hexdigest(),
            }
    assert len({v['sha256'] for v in report.values()}) == 12
    for name, digest in preserved.items():
        assert hashlib.sha256((R / name).read_bytes()).hexdigest() == digest, name
    (R / 'WEAPON_REVISION.json').write_text(json.dumps({
        'revision': 4, 'source': 'Original procedural waveforms; no external samples',
        'seed': SEED, 'identities': IDENTITIES, 'assets': report,
        'preserved_other_wav_files': len(preserved),
    }, indent=2) + '\n')
    print(json.dumps(report, indent=2))
    print(f'Preserved {len(preserved)} non-weapon WAV files unchanged.')

if __name__ == '__main__':
    main()
