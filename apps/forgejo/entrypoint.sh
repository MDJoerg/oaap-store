#!/bin/sh
# Einstiegsschritt vor dem Forgejo-Image (siehe Dockerfile).
set -eu

# 1. Die öffentliche Adresse. Forgejo baut daraus die Clone-URLs UND die
#    Rücksprungadresse für den Anmeldedienst; geraten wäre sie
#    http://localhost:3000/. Immer https: Hinter einem Edge spricht der
#    Knoten http, der Browser sieht https (Runtime 2.35).
if [ -z "${FORGEJO__server__ROOT_URL:-}" ] && [ -n "${OAAP_INSTANCE_NAMES:-}" ]; then
    first=${OAAP_INSTANCE_NAMES%%,*}
    host=${first#*://}
    host=${host%%/*}
    export FORGEJO__server__ROOT_URL="https://${host}/"
fi

# 2. Mit einem Client des Mandanten: Registrierung NUR über den
#    Anmeldedienst (wer in den Realm darf, entscheidet der Realm), der
#    Benutzername aus preferred_username, und die Anmeldequelle wird
#    nachgezogen, sobald Forgejo läuft.
if [ -n "${OAAP_OIDC_ISSUER:-}" ] && [ -n "${OAAP_OIDC_CLIENT_ID:-}" ] \
        && [ -n "${OAAP_OIDC_CLIENT_SECRET:-}" ]; then
    if [ "${OAAP_FORGEJO_REALM_SIGNUP:-true}" = "true" ]; then
        export FORGEJO__service__DISABLE_REGISTRATION=false
        export FORGEJO__service__ALLOW_ONLY_EXTERNAL_REGISTRATION=true
        export FORGEJO__oauth2_client__ENABLE_AUTO_REGISTRATION=true
    fi
    export FORGEJO__oauth2_client__USERNAME=nickname
    /usr/local/bin/oaap-oidc-source &
fi

exec /usr/bin/entrypoint "$@"
