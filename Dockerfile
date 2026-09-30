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
FROM twentycrm/twenty:v2.43.0
USER root
# La imagen es Alpine: su grep (BusyBox) no admite --include ni su sed \b, por
# eso se busca con find y se sustituye con grupos (build fallida 27-09-2026).
RUN set -e; \
    ficheros=$(find /app -name '*.js' -not -path '*/node_modules/*' -exec grep -l "MAX_WORKSPACES_WITHOUT_ENTERPRISE_KEY" {} + | head -20); \
    [ -n "$ficheros" ] || { echo "constante no encontrada: la version base cambio"; exit 1; }; \
    for f in $ficheros; do \
      grep -n "MAX_WORKSPACES_WITHOUT_ENTERPRISE_KEY *= *[0-9]" "$f" || true; \
      sed -i 's/\(MAX_WORKSPACES_WITHOUT_ENTERPRISE_KEY *= *\)5\([^0-9]\)/\1500\2/g; s/\(MAX_WORKSPACES_WITHOUT_ENTERPRISE_KEY *= *\)5$/\1500/' "$f"; \
    done; \
    grep -E -q "MAX_WORKSPACES_WITHOUT_ENTERPRISE_KEY ?= ?500" $ficheros || \
      { echo "el parche no se aplico (patron distinto en esta build)"; grep -n "MAX_WORKSPACES_WITHOUT_ENTERPRISE_KEY" $ficheros | head -5; exit 1; }; \
    ! grep -E -q "MAX_WORKSPACES_WITHOUT_ENTERPRISE_KEY ?= ?5[^0-9]" $ficheros || \
      { echo "queda una definicion a 5 sin parchear"; exit 1; }
# Segundo cambio (30-09-2026, «You must be authenticated» al abrir el CRM desde Helix): Helix entra en el CRM con
# /verify?loginToken=…. Al canjearlo, el servidor revoca la sesión que el navegador ya tuviera
# (user-session.service issueSessionForTokenPair, «Superseded»); si la app llegó a lanzar una consulta con esa
# sesión, vuelve «Session is invalid» y la app cierra la sesión entera, la nueva incluida (medido en prod: 2 de
# cada 6 entradas con sesión previa). Un script en <head>, antes del bundle y SOLO en /verify con loginToken,
# cierra la sesión anterior (mutación signOut, síncrona) y apaga la marca local «conectado»: la app arranca como
# en un navegador limpio, el caso que nunca falla. Front, no servidor: la API no cambia.
RUN set -e; \
    f=/app/packages/twenty-server/dist/front/index.html; \
    [ "$(grep -c '<head>' "$f")" = "1" ] || { echo "index.html sin un unico <head>: la version base cambio"; exit 1; }; \
    sed -i "s|<head>|<head><script id=\"helix-verify-sesion\">try{if(location.pathname==='/verify'){if(new URLSearchParams(location.search).has('loginToken')){try{var x=new XMLHttpRequest();x.open('POST','/metadata',false);x.setRequestHeader('Content-Type','application/json');x.send(JSON.stringify({operationName:'SignOut',variables:{},query:'mutation SignOut(\$refreshToken: String) { signOut(refreshToken: \$refreshToken) }'}))}catch(e){}localStorage.setItem('isCookieAuthActiveState','false')}}}catch(e){}</script>|" "$f"; \
    grep -q 'id="helix-verify-sesion"' "$f" || { echo "el script de /verify no se inyecto"; exit 1; }; \
    grep -q "operationName:'SignOut'" "$f" || { echo "el script de /verify no lleva el signOut"; exit 1; }
USER 1000
