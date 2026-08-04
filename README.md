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

| App          | Was es ist                              | Lizenz   |
| ------------ | --------------------------------------- | -------- |
| Uptime Kuma  | Überwachung von Diensten und Webseiten  | MIT      |
| Stirling PDF | PDF-Werkzeuge im Browser                | MIT      |
| Vaultwarden  | Passwort-Manager (Bitwarden-kompatibel) | AGPL-3.0 |

## Status

Experimenteller Durchstich, Inhalte ohne Gewähr. Die Images verwenden
teils noch gleitende Tags (`latest`) — Version-Pinning und Signierung
folgen mit der Store-Spezifikation. Apps laufen hinter dem
OAAP-Gateway mit Plattform-Login; mitgebrachte eigene Logins der Apps
bleiben zusätzlich aktiv.
