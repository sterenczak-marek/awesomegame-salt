redis-packages:
  pkg.installed:
    - pkgs: [redis-server,]
    - install_recommends: False

bower-packages:
  pkg.installed:
    - pkgs: [nodejs, npm, nodejs-legacy]
    - install_recommends: False
