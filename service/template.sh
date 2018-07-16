service=${1}

cat << EOF
# GDC Buildkite CI agent.
# Iain Buclaw <ibuclaw@gdcproject.org>
#

[Unit]
Description=buildkite.com/d-programming-gdc
Requires=docker.service
After=docker.service

[Service]
Type=simple

User=buildkite
WorkingDirectory=/srv/buildkite
ExecStart=/usr/bin/docker-compose up --build ${service}
ExecStop=/usr/bin/docker-compose stop

[Install]
WantedBy=multi-user.target
EOF
