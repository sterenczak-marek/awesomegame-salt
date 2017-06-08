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
{% set user_homedir=pillar['user_homedir'] %}

deploy-code:
  file.recurse:
    - source: salt://awesomegame-panel
    - name: {{ pillar['user_homedir'] }}/source
    - user: {{ pillar['user_name'] }}
    - exclude_pat: E@(venv)|(src/static/vendor)
    - require:
        - pkg: python-django-packages
    - watch_in:
      - cmd: supervisor-restart

db-perms:
  file.managed:
    - name: {{ user_homedir }}/source/AwesomeGamePanel.db
    - user: {{ user_name }}
    - group: {{ user_name }}
    - mode: 600
    - require:
      - cmd: django-migrate
