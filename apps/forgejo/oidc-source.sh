#!/bin/sh
# Legt die Anmeldequelle „oaap" an oder zieht sie nach (RFC-0091 §4.4).
# Läuft im Hintergrund bei jedem Start, sobald Forgejo antwortet und es
# einen Administrator gibt, und endet dann. Idempotent: dieselben Werte
# noch einmal ändern nichts.
#
# Das Geheimnis steht für die Dauer EINES Aufrufs in der Prozessliste
# des Containers: Forgejos Kommandozeile nimmt es nur als Option.
set -u

log() { echo "oaap-oidc-source: $*"; }

i=0
until wget -q -O /dev/null http://127.0.0.1:3000/api/healthz; do
    i=$((i + 1))
    if [ "$i" -ge 180 ]; then
        log "Forgejo answered nothing within 6 minutes -- source not set"
        exit 1
    fi
    sleep 2
done

fj() { su-exec git env GITEA_CUSTOM=/data/gitea forgejo admin auth "$@"; }
admins() {
    su-exec git env GITEA_CUSTOM=/data/gitea forgejo admin user list --admin 2>/dev/null \
        | awk 'NR > 1 && NF' | wc -l
}

# Forgejo macht die ERSTE Person, die sich registriert, zum Administrator
# -- auch über den Anmeldedienst. Gemessen am 18.11.2026 auf oaap-test:
# ohne lokalen Admin wurde eine Testperson eines fremden Partners
# Forgejo-Administrator. Deshalb erst die Quelle, wenn es einen gibt.
said=""
until [ "$(admins)" -gt 0 ]; do
    if [ -z "$said" ]; then
        log "no administrator yet -- the first person signing in through the realm would become one, so the source waits. Create the first administrator (README); the source follows within 30 seconds."
        said=1
    fi
    sleep 30
done

set -- --name oaap --provider openidConnect \
    --key "$OAAP_OIDC_CLIENT_ID" --secret "$OAAP_OIDC_CLIENT_SECRET" \
    --auto-discover-url "${OAAP_OIDC_ISSUER%/}/.well-known/openid-configuration" \
    --scopes openid --scopes profile --scopes email \
    --group-claim-name groups \
    --admin-group "${OAAP_FORGEJO_ADMIN_GROUP:-}" \
    --restricted-group "${OAAP_FORGEJO_RESTRICTED_GROUP:-}"

id=$(fj list 2>/dev/null | awk -F'\t' 'NR > 1 { gsub(/ /, "", $2); if ($2 == "oaap") { gsub(/ /, "", $1); print $1 } }' | head -n 1)
if [ -n "$id" ]; then
    if fj update-oauth --id "$id" "$@" >/dev/null 2>&1; then
        log "source 'oaap' (id $id) brought up to date for client $OAAP_OIDC_CLIENT_ID"
    else
        log "updating source 'oaap' (id $id) failed"
        exit 1
    fi
else
    if fj add-oauth "$@" >/dev/null 2>&1; then
        log "source 'oaap' added for client $OAAP_OIDC_CLIENT_ID"
    else
        log "adding source 'oaap' failed"
        exit 1
    fi
fi
