nginx:
  pkg:
    - installed
  service.running:
    - watch:
      - pkg: nginx
      - file: /etc/nginx/sites-available/default

{% set tmp_dir=pillar['user_homedir'] + '/tmp' %}

/etc/nginx/sites-available/default:
  file.managed:
    - source: salt://common/files/nginx/default.jinja
    - template: jinja
    - user: root
    - group: root
    - context:
        user_home: '{{ pillar['user_homedir'] }}'
        tmp_dir: '{{ tmp_dir }}'

/etc/nginx/sites-enabled/default:
  file.symlink:
    - target: /etc/nginx/sites-available/default
    - require:
      - file: /etc/nginx/sites-available/default
