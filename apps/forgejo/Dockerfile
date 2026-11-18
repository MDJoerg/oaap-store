# Wrapper um das offizielle Forgejo-Image. Wir bauen Forgejo NICHT
# selbst — wir legen nur einen Einstiegsschritt davor, der
#   1. die öffentliche Adresse aus OAAP_INSTANCE_NAMES ableitet, wenn
#      niemand eine gesetzt hat, und
#   2. mit einem Client des Mandanten (OAAP_OIDC_*, Runtime 2.35) die
#      Anmeldequelle „oaap" anlegt oder nachzieht — bei jedem Start,
#      sobald Forgejo antwortet.
# Danach startet das Image wie immer (/usr/bin/entrypoint, s6).
#
# Version festgenagelt (care.rebuild: self). 15 ist die LTS-Linie.
FROM data.forgejo.org/forgejo/forgejo:15.0.11

COPY entrypoint.sh /usr/local/bin/oaap-entrypoint
COPY oidc-source.sh /usr/local/bin/oaap-oidc-source
RUN chmod 755 /usr/local/bin/oaap-entrypoint /usr/local/bin/oaap-oidc-source

ENTRYPOINT ["/usr/local/bin/oaap-entrypoint"]
CMD ["/usr/bin/s6-svscan", "/etc/s6"]
