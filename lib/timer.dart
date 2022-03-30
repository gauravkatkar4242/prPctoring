class Timer {
  const Timer();

  Stream<int> countDownTimer({required int timeRemaining}) {
    return Stream.periodic(const Duration(seconds: 1), (x) => timeRemaining - x - 1).take(timeRemaining);
  }
}