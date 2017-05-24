Server administrator packages:
  pkg.installed:
    - pkgs: [curl]

Connect to Datadog:
  cmd.run:
    - name: bash -c "$(curl -L https://raw.githubusercontent.com/DataDog/dd-agent/master/packaging/datadog-agent/source/install_agent.sh)"
    - require:
      - pkg: Server administrator packages
    - env:
      - DD_API_KEY: {{ pillar['datadog']['api_key'] }}
    - unless: test -e /etc/init.d/datadog-agent

Restart datadog:
  cmd.run:
    - name: service datadog-agent restart

/etc/dd-agent/datadog.conf:
  file.managed:
    - source: salt://common/files/datadog/datadog.conf.j2
    - template: jinja
    - require:
        - cmd: Connect to Datadog
    - watch_in:
      - cmd: Restart datadog
