{% set username='webpanel-user' %}

user_name: {{ username }}
user_homedir: /home/{{ username }}
app_name: web_panel

celery_module: common

salt_path: /home/{{ username }}/source/AwesomeGame/salt

host_name: awesomegame.sterenczak.me

DB_NAME: 'webpanel'
DB_USER: 'web_panel'
