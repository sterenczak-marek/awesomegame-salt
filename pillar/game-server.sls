{% set username='game-srv' %}

user_name: {{ username }}
user_homedir: /home/{{ username }}
app_name: game_server

celery_module: src.game

host_name: awesomegame-srv1.sterenczak.me
