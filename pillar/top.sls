base:
  '(game|web)-.*':
    - match: pcre
    - private
    - private_panel

  'game-*':
    - game-server

  'web-*':
    - web-server
