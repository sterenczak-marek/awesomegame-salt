supervisor:
  pkg.installed:
    - pkgs: [supervisor,]
    - install_recommends: False

  service:
    - running
    - name: supervisor
    - require:
      - pkg: supervisor


{% set user_name=pillar['user_name'] %}
{% set app_name=pillar['app_name'] %}
{% set user_homedir=pillar['user_homedir'] %}
{% set celery_module=pillar['celery_module'] %}


service-{{ app_name }}:
  supervisord.running:
    - name: {{ app_name }}
    - require:
      - pkg: supervisor
    - update: True
    - watch:
      - file: /etc/supervisor/conf.d/{{ app_name }}.conf

service-{{ app_name }}-ws:
  supervisord.running:
    - name: {{ app_name }}-ws
    - require:
      - pkg: supervisor
    - update: True
    - watch:
      - file: /etc/supervisor/conf.d/{{ app_name }}-ws.conf

service-celery:
  supervisord.running:
    - name: celery-{{user_name}}
    - require:
      - pkg: supervisor
    - update: True
    - watch:
      - file: /etc/supervisor/conf.d/celery-{{user_name}}.conf

/etc/supervisor/conf.d/{{ app_name }}.conf:
  file.managed:
    - source: salt://common/files/supervisor/game_server.j2
    - user: root
    - group: root
    - mode: 600
    - template: jinja
    - context:
        app_name: '{{ app_name }}'
        virtualenv_home: '{{ user_homedir }}/venv'
        user_homedir: '{{ user_homedir }}'
        app_dir: '{{ user_homedir }}/source/AwesomeGame/{{ app_name }}'
        tmp_dir: '{{ user_homedir }}/tmp'
        user_name: '{{ user_name }}'
    - require:
      - pkg: supervisor

/etc/supervisor/conf.d/{{ app_name }}-ws.conf:
  file.managed:
    - source: salt://common/files/supervisor/game_server_ws.j2
    - user: root
    - group: root
    - mode: 600
    - template: jinja
    - context:
        app_name: '{{ app_name }}'
        virtualenv_home: '{{ user_homedir }}/venv'
        user_homedir: '{{ user_homedir }}'
        app_dir: '{{ user_homedir }}/source/AwesomeGame/{{ app_name }}'
        tmp_dir: '{{ user_homedir }}/tmp'
        user_name: '{{ user_name }}'
    - require:
      - pkg: supervisor

/etc/supervisor/conf.d/celery-{{user_name}}.conf:
  file.managed:
    - source: salt://common/files/supervisor/celery.j2
    - user: root
    - group: root
    - mode: 600
    - template: jinja
    - context:
        user_name: '{{ user_name }}'
        app_dir: '{{ user_homedir }}/source/AwesomeGame/{{ app_name }}'
        virtualenv_home: '{{ user_homedir }}/venv'
        django_module: '{{ celery_module }}'
    - require:
      - pkg: supervisor
