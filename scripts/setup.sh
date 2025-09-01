#!/usr/bin/env bash
set -e
echo "==> Activating melos (if not installed, this may take a minute)..."
dart pub global activate melos
echo "==> melos bootstrap"
melos bootstrap
echo "==> Creating platform folders (ios/android) for apps..."
pushd apps/customer >/dev/null
flutter create .
popd >/dev/null
pushd apps/driver >/dev/null
flutter create .
popd >/dev/null
echo "==> Done. Open VS Code and run the apps."
