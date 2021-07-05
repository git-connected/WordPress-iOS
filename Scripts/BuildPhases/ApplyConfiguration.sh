#!/bin/sh

set -e

# The Secrets File Sources
SECRETS_ROOT="${HOME}/.configure/wordpress-ios/secrets"

PRODUCTION_SECRETS_FILE="${SECRETS_ROOT}/WordPress-Secrets.swift"
INTERNAL_SECRETS_FILE="${SECRETS_ROOT}/WordPress-Secrets-Internal.swift"
ALPHA_SECRETS_FILE="${SECRETS_ROOT}/WordPress-Secrets-Alpha.swift"
JETPACK_SECRETS_FILE="${SECRETS_ROOT}/Jetpack-Secrets.swift"

LOCAL_SECRETS_FILE="${SRCROOT}/Credentials/Secrets.swift"
EXAMPLE_SECRETS_FILE="${SRCROOT}/Credentials/Secrets-example.swift"

# The Secrets file destination
SECRETS_DESTINATION_FILE="${BUILD_DIR}/Secrets/Secrets.swift"
mkdir -p $(dirname $SECRETS_DESTINATION_FILE)

# If the WordPress Production Secrets are available for WordPress, use them
if [ -f "$PRODUCTION_SECRETS_FILE" ] && [ "$BUILD_SCHEME" == "WordPress" ]; then
    echo "Applying Production Secrets"
    cp -v $PRODUCTION_SECRETS_FILE "${SECRETS_DESTINATION_FILE}"
    exit 0
fi

# If the WordPress Internal Secrets are available, use them
if [ -f "$INTERNAL_SECRETS_FILE" ] && [ "${BUILD_SCHEME}" == "WordPress Internal" ]; then
    echo "Applying Internal Secrets"
    cp -v $INTERNAL_SECRETS_FILE "${SECRETS_DESTINATION_FILE}"
    exit 0
fi

# If the WordPress Alpha Secrets are available, use them
if [ -f "$INTERNAL_SECRETS_FILE" ] && [ "${BUILD_SCHEME}" == "WordPress Alpha" ]; then
    echo "Applying Alpha Secrets"
    cp -v $ALPHA_SECRETS_FILE "${SECRETS_DESTINATION_FILE}"
    exit 0
fi

# If the Jetpack Secrets are available (and if we're building Jetpack) use them
if [ -f "$JETPACK_SECRETS_FILE" ] && [ "${BUILD_SCHEME}" == "Jetpack" ]; then
    echo "Applying Jetpack Secrets"
    cp -v $JETPACK_SECRETS_FILE "${SECRETS_DESTINATION_FILE}"
    exit 0
fi

# If the developer has a local secrets file, use it
if [ -f "$LOCAL_SECRETS_FILE" ]; then
    echo "Applying Local Secrets"
    cp -v $LOCAL_SECRETS_FILE "${SECRETS_DESTINATION_FILE}"
    exit 0
fi

# None of the above secrets was found. Use the example secrets file as a last
# resort, unless building for Release.
case $CONFIGURATION in
  # There are three release configurations: Release, Release-Alpha, and
  # Release-Internal. Since they all start with "Release" we can use a pattern
  # to check for them.
  Release*)
    echo "error: Could not find secrets at $SECRETS_ROOT. Cannot continue release build."
    exit 1
    ;;
  *)
    echo "Applying Example Secrets"
    echo "warning: Could not find secrets at $SECRETS_ROOT, falling back to $EXAMPLE_SECRETS_FILE. In a release build, this would be an error."
    cp -v $EXAMPLE_SECRETS_FILE $SECRETS_DESTINATION_FILE
    ;;
esac
