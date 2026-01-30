# YAML- Voici un exemple plus complexe 

```yaml

services:
  # Application web
  web:
    image: nginx:alpine
    container_name: mon-serveur-web
    ports:
      - "8080:80"
    volumes:
      - ./html:/usr/share/nginx/html
    networks:
      - mon-reseau
    depends_on:
      - api

  # API backend
  api:
    build:
      context: ./api
      dockerfile: Dockerfile
    container_name: mon-api
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=production
      - DATABASE_URL=postgresql://user:password@db:5432/mabase
    volumes:
      - ./api:/app
      - /app/node_modules
    networks:
      - mon-reseau
    depends_on:
      - db
    restart: unless-stopped

  # Base de données
  db:
    image: postgres:15-alpine
    container_name: ma-db
    environment:
      - POSTGRES_USER=user
      - POSTGRES_PASSWORD=password
      - POSTGRES_DB=mabase
    volumes:
      - postgres-data:/var/lib/postgresql/data
    networks:
      - mon-reseau
    restart: unless-stopped

  # Redis pour le cache
  redis:
    image: redis:alpine
    container_name: mon-redis
    ports:
      - "6379:6379"
    networks:
      - mon-reseau
    restart: unless-stopped

# Volumes persistants
volumes:
  postgres-data:

# Réseau personnalisé
networks:
  mon-reseau:
    driver: bridge
    
```

    FIN du Document