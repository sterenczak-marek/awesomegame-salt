include:
  - common
  - common.datadog
  - common.django
  - common.users
  - common.nginx
  - common.supervisor
  - common.virtualenv
  - common.app

{% set user_name=pillar['user_name'] %}
{% set app_name=pillar['app_name'] %}
{% set user_homedir=pillar['user_homedir'] %}


deploy-code:
  file.recurse:
    - source: salt://awesomegame-game
    - name: {{ user_homedir }}/source
    - user: {{ user_name }}
    - exclude_pat: E@(venv)|(src/static/vendor)
    - require:
        - pkg: python-django-packages
    - watch_in:
      - cmd: supervisor-restart

auth-token:
  cmd.run:
    - name: {{ user_homedir }}/venv/bin/python manage.py create_user
    - runas: {{ user_name }}
    - cwd: {{ user_homedir }}/source
    - statefull: True
    - require:
      - cmd: django-migrate
    - watch:
      - file: deploy-code

db-perms:
  file.managed:
    - name: {{ user_homedir }}/source/AwesomeGameServer.db
    - user: {{ user_name }}
    - group: {{ user_name }}
    - mode: 600
    - require:
      - cmd: django-migrate

/etc/dd-agent/datadog.conf:
  file.managed:
    - source: salt://common/files/datadog/datadog.conf.j2
    - template: jinja
    - context:
        type: game
    - require:
        - cmd: Connect to Datadog
    - watch_in:
      - cmd: Restart datadog
