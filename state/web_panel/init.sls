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
{% set salt_path=pillar['salt_path'] %}

deploy-code:
  file.recurse:
    - source: salt://awesomegame-panel
    - name: {{ user_homedir }}/source
    - user: {{ user_name }}
    - exclude_pat: E@(venv)|(src/static/vendor)
    - require:
        - pkg: python-django-packages
    - watch_in:
      - cmd: supervisor-restart

amqp-env:
  environ.setenv:
    - name: CLOUDAMQP_URL
    - value: redis://localhost:6379
    - require:
      - pkg: redis-packages

secret_key_env:
  environ.setenv:
    - name: SECRET_KEY
    - value: {{ pillar['SECRET_KEY'].get(app_name, 'TEST') }}

initial-data:
  cmd.wait:
    - name: {{ user_homedir }}/venv/bin/python manage.py loaddata initial_users
    - runas: {{ user_name }}
    - cwd: {{ user_homedir }}/source
    - require:
      - cmd: django-migrate
    - watch:
      - file: deploy-code

/etc/dd-agent/datadog.conf:
  file.managed:
    - source: salt://common/files/datadog/datadog.conf.j2
    - template: jinja
    - context:
        type: panel
    - require:
        - cmd: Connect to Datadog
    - watch_in:
      - cmd: Restart datadog
