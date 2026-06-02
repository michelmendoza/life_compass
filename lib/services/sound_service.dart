import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';

class SoundService {
  static final AudioPlayer _player = AudioPlayer();

  static String? _shortPath;
  static String? _longPath;
  static String? _startPath;
  static String? _victoryPath;

  // Call once in TimerScreen.initState — writes WAV files to temp dir.
  static Future<void> init() async {
    if (_shortPath != null) return;
    await _player.setVolume(4.0);
    final dir = await getTemporaryDirectory();

    final shortFile = File('${dir.path}/beep_short.wav');
    await shortFile.writeAsBytes(_wav(frequency: 1046.5, seconds: 0.1));
    _shortPath = shortFile.path;

    final longFile = File('${dir.path}/beep_long.wav');
    await longFile.writeAsBytes(_wav(frequency: 880.0, seconds: 0.35));
    _longPath = longFile.path;

    final startFile = File('${dir.path}/beep_start.wav');
    await startFile.writeAsBytes(_startWav());
    _startPath = startFile.path;

    final victoryFile = File('${dir.path}/beep_victory.wav');
    await victoryFile.writeAsBytes(_victoryWav());
    _victoryPath = victoryFile.path;
  }

  // Short high beep — 3-2-1 countdown
  static void beepShort() {
    if (_shortPath != null) _player.play(DeviceFileSource(_shortPath!));
  }

  // Long lower beep — interval end / manual stop / new lap
  static void beepLong() {
    if (_longPath != null) _player.play(DeviceFileSource(_longPath!));
  }

  // Ascending two-note "go!" — played when a timer starts
  static void beepStart() {
    if (_startPath != null) _player.play(DeviceFileSource(_startPath!));
  }

  // Ascending melody — natural completion
  static void beepVictory() {
    if (_victoryPath != null) _player.play(DeviceFileSource(_victoryPath!));
  }

  // ── WAV generation ────────────────────────────────────────────────────────

  static Uint8List _wav({
    required double frequency,
    required double seconds,
    double amplitude = 0.9,
    int sampleRate = 44100,
  }) {
    final n = (sampleRate * seconds).round();
    return _buildWav(
      sampleRate: sampleRate,
      samples: _sineWave(
        frequency: frequency,
        numSamples: n,
        amplitude: amplitude,
        sampleRate: sampleRate,
      ),
    );
  }

  // E5 (659Hz, 90ms) → silence (40ms) → C6 (1047Hz, 150ms)
  static Uint8List _startWav({int sampleRate = 44100}) {
    final note1 = _sineWave(
      frequency: 659.25,
      numSamples: sampleRate * 90 ~/ 1000,
      amplitude: 0.9,
      sampleRate: sampleRate,
    );
    final silenceLen = sampleRate * 40 ~/ 1000;
    final note2 = _sineWave(
      frequency: 1046.5,
      numSamples: sampleRate * 150 ~/ 1000,
      amplitude: 0.9,
      sampleRate: sampleRate,
    );
    final all = Int16List(note1.length + silenceLen + note2.length);
    all.setRange(0, note1.length, note1);
    all.setRange(note1.length + silenceLen, all.length, note2);
    return _buildWav(sampleRate: sampleRate, samples: all);
  }

  // C5 → E5 → G5 → C6, each 200ms with 80ms silence between
  static Uint8List _victoryWav({int sampleRate = 44100}) {
    const notes = [523.25, 659.25, 783.99, 1046.5];
    const noteMs = 200;
    const silenceMs = 80;
    final noteSamples = sampleRate * noteMs ~/ 1000;
    final silenceSamples = sampleRate * silenceMs ~/ 1000;
    final totalSamples =
        notes.length * noteSamples + (notes.length - 1) * silenceSamples;

    final all = Int16List(totalSamples);
    int pos = 0;
    for (int ni = 0; ni < notes.length; ni++) {
      final wave = _sineWave(
        frequency: notes[ni],
        numSamples: noteSamples,
        amplitude: 0.9,
        sampleRate: sampleRate,
      );
      all.setRange(pos, pos + noteSamples, wave);
      pos += noteSamples;
      if (ni < notes.length - 1) {
        pos += silenceSamples;
      }
    }
    return _buildWav(sampleRate: sampleRate, samples: all);
  }

  static Int16List _sineWave({
    required double frequency,
    required int numSamples,
    required double amplitude,
    required int sampleRate,
  }) {
    final out = Int16List(numSamples);
    for (int i = 0; i < numSamples; i++) {
      final env =
          i > numSamples * 0.8 ? (numSamples - i) / (numSamples * 0.2) : 1.0;
      final v = (math.sin(2 * math.pi * frequency * i / sampleRate) *
              amplitude *
              env *
              32767)
          .round()
          .clamp(-32768, 32767);
      out[i] = v;
    }
    return out;
  }

  static Uint8List _buildWav(
      {required int sampleRate, required Int16List samples}) {
    final dataBytes = samples.lengthInBytes;
    final buf = ByteData(44 + dataBytes);

    void str(int offset, String s) {
      for (int i = 0; i < s.length; i++) {
        buf.setUint8(offset + i, s.codeUnitAt(i));
      }
    }

    str(0, 'RIFF');
    buf.setUint32(4, 36 + dataBytes, Endian.little);
    str(8, 'WAVE');
    str(12, 'fmt ');
    buf.setUint32(16, 16, Endian.little);
    buf.setUint16(20, 1, Endian.little); // PCM
    buf.setUint16(22, 1, Endian.little); // mono
    buf.setUint32(24, sampleRate, Endian.little);
    buf.setUint32(28, sampleRate * 2, Endian.little);
    buf.setUint16(32, 2, Endian.little);
    buf.setUint16(34, 16, Endian.little);
    str(36, 'data');
    buf.setUint32(40, dataBytes, Endian.little);

    final pcm = buf.buffer.asInt16List(44);
    pcm.setRange(0, samples.length, samples);

    return buf.buffer.asUint8List();
  }
}
