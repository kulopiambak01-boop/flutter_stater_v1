enum ObdConnectionType {
  bluetooth,
  wifi;

  bool get isWireless => this == bluetooth || this == wifi;

  bool get isSerial => this == bluetooth;

  bool get requiresMtuHandling => false;
}
