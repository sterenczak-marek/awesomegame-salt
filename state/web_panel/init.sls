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


initial-data:
  cmd.wait:
    - name: {{ user_homedir }}/venv/bin/python manage.py loaddata initial_users
    - runas: {{ user_name }}
    - cwd: {{ user_homedir }}/source
    - require:
      - cmd: django-migrate
    - watch:
      - file: deploy-code


# TODO: zrobić ssh-keygen
keygen:
  cmd.run:
    - name: ssh-keygen -q -f {{ salt_path }}/salt-ssh.rsa -N ""
    - runas: {{ user_name }}
    - unless: test -f {{ salt_path }}/salt-ssh.rsa

copy-key:
  cmd.run:
    - name: cp {{ salt_path }}/salt-ssh.rsa.pub {{ user_homedir }}/config/
    - watch:
      - cmd: keygen
    - require:
      - file: {{ user_homedir }}/config


salt-virtualenv:
  virtualenv.managed:
    - name: {{ salt_path }}/venv
    - user: {{ user_name }}
    - cwd: {{ salt_path }}
    - system_site_packages: False
    - requirements: {{ salt_path }}/requirements.txt
    - pip_upgrade: True
    - require:
      - file: deploy-code
      - pkg: python-virtualenv-packages
    - watch_in:
      - cmd: supervisor-restart

salt-venv-permission:
  file.directory:
    - name: {{ salt_path }}/venv
    - user: {{ user_name }}
    - group: {{ user_name }}
    - file_mode: 750
    - dir_mode: 750
    - recurse:
        - user
        - group
        - mode
    - require:
        - virtualenv: salt-virtualenv
    - require_in:
      - file: /etc/supervisor/conf.d/celery-{{user_name}}.conf

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
