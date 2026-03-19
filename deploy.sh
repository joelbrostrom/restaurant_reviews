#!/bin/bash
set -e

flutter build web --wasm \
  --dart-define=FOURSQUARE_API_KEY=R01RBUHGLPWWFHR1D1KC2LXCIPHXRFLOX31C1LSTQG5GK1CI \
  --dart-define=GEOAPIFY_API_KEY=6334b2436c02419f82b70457f8244e82

firebase deploy --only hosting
