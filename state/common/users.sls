
{% set user_name=pillar['user_name'] %}
{% set app_name=pillar['app_name'] %}
{% set user_homedir=pillar['user_homedir'] %}



{{ user_name }}-group:
  group.present:
    - name: {{ user_name }}
    - system: True

{{ user_name }}-run:
  user.present:
    - createhome: False
    - name: {{ user_name }}-run
    - gid: {{ user_name }}
    - system: True
    - home: {{ user_homedir }}
    - shell: /bin/bash
    - require:
      - user: {{ user_name }}

{{ user_name }}:
  user.present:
    - name: {{ user_name }}
    - gid: {{ user_name }}
    - system: True
    - home: {{ user_homedir }}
    - shell: /bin/bash
    - require:
      - group: {{ user_name }}-group

  ssh_auth.present:
    - user: {{ user_name }}
    - source: salt://common/files/ssh_key.pub
    - require:
      - file: {{ user_name }}

  file.directory:
    - name: {{ user_homedir }}
    - user: {{ user_name }}
    - group: {{ user_name }}
    - require:
      - user: {{ user_name }}
      - group: {{ user_name }}-group

{{ user_name }}-group-www:
  cmd.run:
    - name: adduser www-data {{ user_name }}
    - unless: test $(groups www-data|grep {{ user_name }}|wc -l) -eq '1'
    - watch_in:
      - service: nginx
    - require:
      - user: {{ user_name }}

{{ user_homedir }}/log:
  file.directory:
    - use:
      - file: {{ user_name }}
    - require:
      - file: {{ user_name }}

{{ user_homedir }}/tmp:
  file.directory:
    - use:
      - file: {{ user_name }}
    - require:
      - file: {{ user_name }}

{{ user_homedir }}/public:
  file.directory:
    - use:
      - file: {{ user_name }}

{{ user_homedir }}/source:
  file.directory:
    - use:
      - file: {{ user_name }}

{{ user_homedir }}/config:
  file.directory:
    - use:
      - file: {{ user_name }}

{{ user_homedir }}/.ssh:
  file.directory:
    - use:
      - file: {{ user_name }}
    - require:
        - ssh_auth: {{ user_name }}
