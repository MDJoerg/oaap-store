# oaap-store

Inoffizielle, öffentliche App-Liste für die
[OAAP-Plattform](https://github.com/MDJoerg/oaap) — der frühe
**Store-Durchstich**. Eine OAAP-Installation kann diese Liste als
Store-Quelle eintragen und die Apps direkt installieren.

## Wie es funktioniert

1. **Die Liste** ist die Datei [`oaap-store.json`](oaap-store.json)
   (Format `store: "0.1"`): je App Identität, Beschreibung, App-Typ
   nach RFC-0004, Lizenz, Homepage und die **Paketquelle** (`package`:
   Git-URL + Pfad im Repo).
2. **Die Pakete** liegen unter [`apps/`](apps/) — je App ein Ordner mit
   `oaap-app.yaml` nach dem OAAP-App-Manifest
   ([Schema](https://github.com/MDJoerg/oaap-spec/blob/main/schema/oaap-app.schema.json)).
3. **Eine Plattform** trägt die Liste als Quelle ein und zeigt sie im
   Portal-Menü „Store":

   ```sh
   sudo oaap store add-source https://raw.githubusercontent.com/MDJoerg/oaap-store/main/oaap-store.json
   ```

4. **Installieren** direkt aus diesem Repo (das zeigt der Store je App
   fertig an):

   ```sh
   sudo oaap app install https://github.com/MDJoerg/oaap-store --path apps/uptime-kuma --channel test
   ```

## Enthaltene Apps

| App          | Was es ist                                        | Lizenz             |
| ------------ | ------------------------------------------------- | ------------------ |
| Uptime Kuma  | Überwachung von Diensten und Webseiten            | MIT                |
| Stirling PDF | PDF-Werkzeuge im Browser                          | MIT                |
| Vaultwarden  | Passwort-Manager (Bitwarden-kompatibel)           | AGPL-3.0           |
| n8n          | Workflow-Automatisierung ohne Code                | Sustainable Use    |
| Ollama       | Lokale KI-Modelle als API                         | MIT                |
| Open WebUI   | Chat-Oberfläche für lokale KI-Modelle             | BSD-3-Clause       |
| Forgejo      | Git-Hosting: Repositories, Issues, Pull Requests  | GPL-3.0-or-later   |

### Forgejo: Erstanlage des Administrators

Forgejo läuft als begründete `public`-Ausnahme (Git-Clients können den
Portal-Login nicht durchlaufen) und authentifiziert selbst; die
Selbstregistrierung ist per Default gesperrt. Den ersten Administrator
legt man nach der Installation einmalig auf dem Server an:

```sh
sudo docker exec -u git oaap-app-<instanz>   forgejo admin user create --admin   --username <name> --password '<passwort>' --email <mail>
```

Git-Zugriff läuft über HTTPS (SSH ist deaktiviert — das Gateway routet
nur HTTP). Die Adresse für Clone-URLs ist der erste Name der Instanz;
`FORGEJO__server__ROOT_URL` setzt eine andere.

### Forgejo: Anmeldung über den Anmeldedienst des Mandanten (ab 15.0.11)

Hat der Mandant einen Anmeldedienst, den OAAP angelegt hat (`oaap idp
provision`), gibt der Betreiber Forgejo einen eigenen Client darin
(RFC-0091 Stufe 3, OAAP ab 0.1.301):

```sh
sudo oaap idp app <connector> --instance <instanz> --dry-run   # erst ansehen
sudo oaap idp app <connector> --instance <instanz>
```

Danach steht auf der Anmeldeseite von Forgejo „Anmelden mit oaap“. Wer
sich darüber zum ersten Mal anmeldet, bekommt ein Forgejo-Konto mit
seinem Benutzernamen aus dem Realm; wer in den Realm darf, entscheidet
der Realm (auch über fremde Anmeldedienste davor). Für Git über HTTPS
legt jede Person in Forgejo ein Zugangstoken an (Einstellungen →
Anwendungen). Optional macht Forgejo aus Realm-Gruppen eigene Rechte:
`OAAP_FORGEJO_ADMIN_GROUP` (Forgejo-Administratoren) und
`OAAP_FORGEJO_RESTRICTED_GROUP` (eingeschränkte Benutzer), je mit vollem
Pfad wie `/partner`. Das sind Rechte in Forgejo, keine Plattformrollen.

Abschalten: `sudo oaap idp app <connector> --instance <instanz> --off`.
Der Client im Realm wird deaktiviert, nicht gelöscht; das passiert auch
beim Entfernen der Instanz.

## Status

Experimenteller Durchstich, Inhalte ohne Gewähr. Die Images verwenden
teils noch gleitende Tags (`latest`) — Version-Pinning und Signierung
folgen mit der Store-Spezifikation. Apps laufen hinter dem
OAAP-Gateway mit Plattform-Login; mitgebrachte eigene Logins der Apps
bleiben zusätzlich aktiv.
