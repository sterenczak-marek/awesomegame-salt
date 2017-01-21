base:
  '(game|web)-server-.*':
    - match: pcre
    - private
    - private_panel

  'game-server-.*':
    - match: pcre
    - game-server

  'web-server':
    - web-server
