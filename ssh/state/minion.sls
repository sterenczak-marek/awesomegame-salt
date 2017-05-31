salt-minion-package:
  pkg.installed:
    - pkgs: ['salt-minion']
    - install_recommends: False
  service:
    - running
    - name: salt-minion
    - watch:
      - file: /etc/salt/minion

/etc/salt/minion:
  file.managed:
    - source: salt://files/minion.jinja
    - template: jinja
    - context:
        server_name: {{ pillar['server_name'] }}
    - require:
      - pkg: salt-minion-package
