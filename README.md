# helix-twenty

Imagen de [Twenty CRM](https://github.com/twentyhq/twenty) v2.43.0 usada por Helix
(app.gethelix.es) con dos modificaciones sobre el código AGPLv3:

- `MAX_WORKSPACES_WITHOUT_ENTERPRISE_KEY`: 5 → 500 (constante en
  `packages/twenty-server/src/engine/core-modules/auth/`, sin marca
  `@license Enterprise`, por tanto AGPLv3).
- Un script de una línea al principio de `index.html` del front: en `/verify` con
  `loginToken`, cierra la sesión que el navegador ya tuviera (mutación `signOut`) y apaga la
  marca local de sesión activa antes de que arranque la app, para que canjear el token no
  choque con esa sesión (el servidor la revoca y la app se desconectaba entera).

Este repositorio existe en cumplimiento de la licencia AGPLv3 (art. 13): contiene la
modificación completa aplicada a la versión que servimos. El código fuente íntegro de
la versión base es el del repositorio oficial de Twenty en la etiqueta v2.43.0.
No se usa ningún fichero bajo la licencia comercial de Twenty ("@license Enterprise").

Twenty es una marca de Twenty.com; Helix no está afiliada. El producto se presenta a
los usuarios como «CRM sobre Twenty (open source)».
