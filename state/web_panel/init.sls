include:
  - common
  - common.datadog
  - common.django
  - common.users
  - common.nginx
  - common.supervisor
  - common.virtualenv
  - common.app

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
