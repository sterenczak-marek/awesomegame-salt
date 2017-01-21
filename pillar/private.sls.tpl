repository:
  source: https://gitlab.com/uam/praca-magisterska.git
  username: {{ username }}
  password: {{ password }}

opbeat:
  ORGANIZATION_ID: {{ ID }}
  APP_ID: {{ APP_ID }}
  SECRET_TOKEN: {{ TOKEN }}

mailgun:
  access_key: {{ ACCESS_KEY }}
  server_name: {{ SERVER_NAME }}

datadog_key: {{ DD_KEY }}
