enum Environment { dev, staging, prod }

enum Env { dev, staging, prod }

class EnvConfig {
  static late Env env;
  static String urlAppscript =
      "https://script.google.com/macros/s/AKfycbzT0_225h7J7jPX6OTw4Pa_tP8k91QzjlcyX-YF0WyfmE8IBzuEcQ5Qt07AVKGtd-6YTw/exec";

  static String get baseUrl {
    switch (env) {
      case Env.dev:
        return urlAppscript;
      case Env.staging:
        return "https://staging-api.com";
      case Env.prod:
        return urlAppscript;
    }
  }
}
