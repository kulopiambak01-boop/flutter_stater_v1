class ObdCommands {
  /// STANDARD PID
  static const rpm = '010C';
  static const speed = '010D';
  static const coolantTemp = '0105';
  static const engineLoad = '0104';
  static const fuelLevel = '012F';
  static const maf = '0110';

  /// ELM327
  static const voltage = 'ATRV';
  static const reset = 'ATZ';
  static const echoOff = 'ATE0';
  static const lineFeedOff = 'ATL0';
  static const spacesOn = 'ATS1';
  static const headersOff = 'ATH0';
  static const adaptiveTiming = 'ATAT1';
  static const autoProtocol = 'ATSP0';
  static const describeProtocol = 'ATDP';
  static const allowLongMessages = 'ATAL';
  static const deviceVersion = 'ATI';

  /// PID SUPPORT
  static const supportedPidA = '0100';
  static const supportedPidB = '0120';
  static const supportedPidC = '0140';
}
