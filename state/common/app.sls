
{% set user_name=pillar['user_name'] %}
{% set app_name=pillar['app_name'] %}
{% set user_homedir=pillar['user_homedir'] %}

virtualenv-{{ user_name}}:
  virtualenv.managed:
    - name: {{ user_homedir }}/venv
    - cwd: {{ user_homedir }}/source
    - system_site_packages: False
    - requirements: {{ user_homedir }}/source/requirements.txt
    - pip_upgrade: True
    - require:
      - file: deploy-code
      - pkg: python-virtualenv-packages
    - watch_in:
      - cmd: supervisor-restart

##
## Ustawienie dostepu dla grupy dla venv
##
venv-dir-permission-{{ user_name }}:
  file.directory:
    - name: {{ user_homedir }}/venv
    - user: {{ user_name }}
    - group: {{ user_name }}
    - file_mode: 750
    - dir_mode: 750
    - recurse:
        - user
        - group
        - mode
    - require:
        - virtualenv: virtualenv-{{ user_name}}
    - require_in:
      - file: /etc/supervisor/conf.d/{{ app_name }}.conf

clean_pyc:
  cmd.wait:
    - name: find {{ user_homedir }} -name '*.pyc' -delete
    - runas: {{ user_name }}
    - cwd: {{ user_homedir }}
    - watch:
      - file: deploy-code

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

{{ user_homedir }}/source/config/settings/production.py:
  file.managed:
    - source: salt://common/files/settings/{{ app_name }}/production.py.j2
    - user: {{ user_name }}
    - group: {{ user_name }}
    - mode: 600
    - template: jinja
    - require:
      - file: deploy-code

{{ user_homedir }}/source/manage.py:
  file.managed:
    - source: salt://common/files/manage.py.j2
    - user: {{ user_name }}
    - group: {{ user_name }}
    - mode: 600
    - template: jinja
    - require:
      - file: deploy-code

npm-bower:
  npm.installed:
    - name: bower
    - user: {{ user_name }}
    - dir: {{ user_homedir }}
    - require:
      - pkg: bower-packages

bower-app:
  cmd.wait:
    - name: {{ user_homedir }}/node_modules/.bin/bower install -p --config.directory="{{ user_homedir }}/public/vendor"
    - runas: {{ user_name }}
    - cwd: {{ user_homedir }}/source
    - require:
      - npm: npm-bower
      - file: {{ user_homedir }}/public
    - watch:
      - file: deploy-code

django-collectstatic:
  cmd.wait:
    - name: {{ user_homedir }}/venv/bin/python manage.py collectstatic -i vendor --noinput
    - runas: {{ user_name }}
    - cwd: {{ user_homedir }}/source
    - require:
      - virtualenv: virtualenv-{{ user_name}}
      - file: {{ user_homedir }}/public
      - file: {{ user_homedir }}/source/config/settings/production.py
      - file: {{ user_homedir }}/source/manage.py
    - watch:
      - file: deploy-code

django-migrate:
  cmd.wait:
    - name: {{ user_homedir }}/venv/bin/python manage.py migrate
    - runas: {{ user_name }}
    - cwd: {{ user_homedir }}/source
    - require:
      - virtualenv: virtualenv-{{ user_name}}
      - file: {{ user_homedir }}/source/config/settings/production.py
      - file: {{ user_homedir }}/source/manage.py
    - watch:
      - file: deploy-code

supervisor-restart:
  cmd.wait:
    - name: |
        supervisorctl restart {{ app_name }}
        supervisorctl restart {{ app_name }}-ws
        supervisorctl restart celery-{{user_name}}
    - require:
        - pkg: supervisor
