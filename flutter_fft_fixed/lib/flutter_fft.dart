library flutter_fft;

class FlutterFft {
  Future<void> startRecorder() async {
    print("Pretend recorder started");
  }

  Future<void> stopRecorder() async {
    print("Pretend recorder stopped");
  }

  Stream<Map<String, dynamic>> get onRecorderStateChanged =>
      Stream.periodic(Duration(milliseconds: 100), (i) {
        return {
          'fft': List<double>.generate(64, (index) => (index * 1.0) + (i % 10))
        };
      });
}
