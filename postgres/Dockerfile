FROM postgres:15

# Copy the initialization script
COPY postgres/init.sql /docker-entrypoint-initdb.d/init.sql
COPY postgres/apply-init.sh /docker-entrypoint-initdb.d/apply-init.sh

# Make the script executable
RUN chmod +x /docker-entrypoint-initdb.d/apply-init.sh
