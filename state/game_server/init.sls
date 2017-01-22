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
