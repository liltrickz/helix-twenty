# Imagen de twenty-server para Helix: Twenty v2.30.0 oficial con UN cambio,
# elevar MAX_WORKSPACES_WITHOUT_ENTERPRISE_KEY (5 → 500).
#
# Base legal: el repositorio de Twenty es AGPLv3 salvo los ficheros marcados
# "@license Enterprise"; la constante y el check del límite NO llevan esa marca
# (packages/twenty-server/src/engine/core-modules/auth/, verificado 16-08-2026),
# así que son AGPL y esta modificación está permitida. En cumplimiento del
# artículo 13 de la AGPL, este Dockerfile (la modificación completa) se publica
# en un repositorio público. No se usa ningún fichero "@license Enterprise"
# (ni SSO ni dominios por workspace de pago).
FROM twentycrm/twenty:v2.30.0
USER root
RUN set -e; \
    ficheros=$(grep -rl "MAX_WORKSPACES_WITHOUT_ENTERPRISE_KEY" /app --include="*.js" | head -20); \
    [ -n "$ficheros" ] || { echo "constante no encontrada: la version base cambio"; exit 1; }; \
    for f in $ficheros; do \
      sed -i 's/MAX_WORKSPACES_WITHOUT_ENTERPRISE_KEY = 5\b/MAX_WORKSPACES_WITHOUT_ENTERPRISE_KEY = 500/g; s/MAX_WORKSPACES_WITHOUT_ENTERPRISE_KEY=5\b/MAX_WORKSPACES_WITHOUT_ENTERPRISE_KEY=500/g' "$f"; \
    done; \
    grep -rq "MAX_WORKSPACES_WITHOUT_ENTERPRISE_KEY ?= ?500" /app --include="*.js" -E || \
      { echo "el parche no se aplico (patron distinto en esta build)"; grep -rn "MAX_WORKSPACES_WITHOUT_ENTERPRISE_KEY" /app --include="*.js" | head -5; exit 1; }
