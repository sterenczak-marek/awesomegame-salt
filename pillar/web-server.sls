{% set username='webpanel-user' %}

user_name: {{ username }}
user_homedir: /home/{{ username }}
app_name: web_panel

celery_module: src.common

salt_path: /home/{{ username }}/source/AwesomeGame/salt
