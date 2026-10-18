#!/usr/bin/env bash
set -euo pipefail

# Vercel does not ship Flutter. Install stable, then emit build/web.
FLUTTER_HOME="${FLUTTER_HOME:-$HOME/flutter}"
if [ ! -x "$FLUTTER_HOME/bin/flutter" ]; then
  git clone https://github.com/flutter/flutter.git --depth 1 -b stable "$FLUTTER_HOME"
fi

export PATH="$FLUTTER_HOME/bin:$PATH"
flutter config --enable-web --no-analytics
flutter precache --web
flutter pub get
flutter build web --release
