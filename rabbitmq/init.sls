# RabbitMQ is not supported well at the moment.
{% set plugins = salt['pillar.get']('rabbitmq:plugins') -%}
{% set version = salt['pillar.get']('rabbitmq:version') -%}
{% set user = salt['pillar.get']('rabbitmq:user', 'rabbitmq') -%}
{% set password = salt['pillar.get']('rabbitmq:password', 'rabbitmq') -%}

{% if version is not none %}

rabbitmq_ppa:
  pkgrepo.managed:
    - humanname: RabbitMQ PPA
    - name: deb http://www.rabbitmq.com/debian/ testing main
    - file: /etc/apt/sources.list.d/rabbitmq.list
    - key_url: http://www.rabbitmq.com/rabbitmq-signing-key-public.asc

rabbitmq-server:
  pkg.installed

rabbitmq-service:
  service.running:
    - name: rabbitmq-server

{{ user }}:
  rabbitmq_user.present:
    - name: {{ user }} # RabbitMQ module does not respect this name.
    - password: {{ password }}
    - force: True
    - tags: administrator
    - perms:
      - '/':
        - '.*'
        - '.*'
        - '.*'
    - runas: root
    - require:
      - pkg: rabbitmq-server

{% for plugin in plugins %}

{{ plugin }}:
  rabbitmq_plugin:
    - enabled
{% endfor %}

{% endif %}
