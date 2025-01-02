FROM postgres:15

# Copy the initialization script
COPY init.sql /docker-entrypoint-initdb.d/init.sql
COPY apply-init.sh /docker-entrypoint-initdb.d/apply-init.sh

# Make the script executable
RUN chmod +x /docker-entrypoint-initdb.d/apply-init.sh
