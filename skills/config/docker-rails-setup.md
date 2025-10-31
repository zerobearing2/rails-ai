---
name: docker-rails-setup
domain: config
dependencies: []
version: 1.0
rails_version: 7.0+
criticality: RECOMMENDED

# Configuration
applies_to:
  - Dockerfile
  - .dockerignore
  - docker-compose.yml
---

# Docker Rails Setup

Configure Docker for Rails applications with proper build optimization, production-ready images, and efficient layer caching.

<when-to-use>
- Setting up Docker for Rails application deployment
- Configuring production Docker images
- Optimizing Docker build times and image sizes
- Setting up local development with Docker Compose
- Deploying with Kamal (requires proper Dockerfile)
- CI/CD pipelines using Docker
</when-to-use>

<benefits>
- **Optimized Image Size** - Exclude unnecessary files from builds
- **Faster Builds** - Proper layer caching and .dockerignore usage
- **Production Ready** - Multi-stage builds for lean production images
- **Development/Production Parity** - Same Docker setup across environments
- **CI/CD Friendly** - Consistent builds in automation pipelines
- **Kamal Compatible** - Works seamlessly with Rails 8 deployment tool
</benefits>

<standards>
- ALWAYS create .dockerignore to exclude development files
- ALWAYS use multi-stage builds for production images
- ALWAYS exclude docs/ folder from production images
- Keep production images minimal (use alpine base when possible)
- Separate build dependencies from runtime dependencies
- Cache gem installations efficiently
- Use BuildKit for better caching
- Include health check endpoints
</standards>

## .dockerignore Configuration

<pattern name="dockerignore-rails-optimized">
<description>Comprehensive .dockerignore for Rails projects</description>

**Essential .dockerignore file:**

```gitignore
# Planning and Documentation (not needed in production)
docs/
*.md
README*
LICENSE*
CHANGELOG*

# Development Files
.git/
.github/
.gitignore
.dockerignore

# Environment Files (use secrets management instead)
.env*
config/master.key
config/credentials/*.key

# Test Files
spec/
test/
coverage/
.rspec
.simplecov

# Development Dependencies
.bundle/
vendor/cache/

# Logs
log/*
tmp/*
*.log

# Development Databases
*.sqlite3
*.sqlite3-journal
storage/development*.sqlite3
storage/test*.sqlite3

# Node Modules (rebuild in container)
node_modules/
yarn-error.log

# IDE and Editor Files
.vscode/
.idea/
*.swp
*.swo
*~
.DS_Store

# CI/CD Files
.travis.yml
.gitlab-ci.yml
.circleci/
Jenkinsfile

# Documentation Assets
doc/
public/uploads/test/
public/uploads/development/
```

**Why exclude docs/ folder:**
- Contains planning specs, ADRs, architecture docs created by planning agent
- Grows over time as features are specified and documented
- Not needed for application runtime
- Can be several MB of markdown files
- Reduces Docker image size significantly
- Speeds up Docker builds (fewer files to copy)

</pattern>

## Dockerfile Configuration

<pattern name="dockerfile-rails-production">
<description>Production-optimized multi-stage Dockerfile for Rails</description>

**Multi-stage production Dockerfile:**

```dockerfile
# syntax=docker/dockerfile:1

# Stage 1: Build dependencies
FROM ruby:3.3-alpine AS builder

# Install build dependencies
RUN apk add --no-cache \
    build-base \
    postgresql-dev \
    nodejs \
    yarn \
    git

WORKDIR /app

# Install gems (cached layer)
COPY Gemfile Gemfile.lock ./
RUN bundle config set --local deployment 'true' && \
    bundle config set --local without 'development test' && \
    bundle install --jobs 4

# Install JavaScript dependencies (cached layer)
COPY package.json yarn.lock ./
RUN yarn install --frozen-lockfile --production

# Copy application code
COPY . .

# Precompile assets
RUN RAILS_ENV=production \
    SECRET_KEY_BASE=dummy \
    bundle exec rails assets:precompile

# Stage 2: Runtime image
FROM ruby:3.3-alpine

# Install runtime dependencies only
RUN apk add --no-cache \
    postgresql-client \
    nodejs \
    tzdata

WORKDIR /app

# Copy gems from builder
COPY --from=builder /usr/local/bundle /usr/local/bundle

# Copy application and precompiled assets
COPY --from=builder /app /app

# Remove build artifacts and docs (optimization)
RUN rm -rf \
    tmp/cache \
    spec \
    test \
    docs \
    node_modules \
    .git

# Create non-root user
RUN addgroup -g 1000 rails && \
    adduser -D -u 1000 -G rails rails && \
    chown -R rails:rails /app

USER rails

# Expose port
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=40s \
    CMD wget -q -O /dev/null http://localhost:3000/up || exit 1

# Start server
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]
```

**Key optimizations:**
1. **Multi-stage build** - Separate build and runtime dependencies
2. **Layer caching** - Gems and JS dependencies cached before code copy
3. **Alpine Linux** - Minimal base image (~5MB vs ~150MB for full Ruby)
4. **Docs removed** - `rm -rf docs` in final stage removes planning documentation
5. **Non-root user** - Security best practice
6. **Health check** - Kubernetes/Docker Swarm compatible

</pattern>

<pattern name="dockerfile-rails-development">
<description>Development Dockerfile with hot-reloading</description>

**Development Dockerfile (docker-compose.yml):**

```dockerfile
# syntax=docker/dockerfile:1

FROM ruby:3.3

# Install dependencies
RUN apt-get update -qq && \
    apt-get install -y \
      build-essential \
      postgresql-client \
      nodejs \
      yarn

WORKDIR /app

# Install gems
COPY Gemfile Gemfile.lock ./
RUN bundle install

# Install JavaScript dependencies
COPY package.json yarn.lock ./
RUN yarn install

# Copy application code
COPY . .

# Expose port
EXPOSE 3000

# Start server with hot-reloading
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]
```

**docker-compose.yml for development:**

```yaml
version: '3.8'

services:
  web:
    build:
      context: .
      dockerfile: Dockerfile.dev
    command: bundle exec rails server -b 0.0.0.0
    volumes:
      - .:/app
      - bundle:/usr/local/bundle
    ports:
      - "3000:3000"
    environment:
      - RAILS_ENV=development
      - DATABASE_URL=postgresql://postgres:password@db:5432/app_development
    depends_on:
      - db

  db:
    image: postgres:16-alpine
    volumes:
      - postgres:/var/lib/postgresql/data
    environment:
      - POSTGRES_PASSWORD=password

volumes:
  bundle:
  postgres:
```

**Development features:**
- Volume mount for hot-reloading
- Full dependencies for development
- Separate Dockerfile.dev
- Docs folder included (for agent work)

</pattern>

## Kamal Configuration

<pattern name="kamal-docker-config">
<description>Kamal-compatible Docker configuration for Rails 8</description>

**Kamal requires specific Dockerfile patterns:**

```dockerfile
# Kamal-compatible Dockerfile
# syntax=docker/dockerfile:1

# Use official Ruby image
FROM ruby:3.3-slim AS base

# Install dependencies
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
      curl \
      libpq5 \
      libjemalloc2 && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Set production environment
ENV RAILS_ENV=production \
    BUNDLE_DEPLOYMENT=1 \
    BUNDLE_WITHOUT=development:test

# Build stage
FROM base AS build

RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
      build-essential \
      git \
      libpq-dev \
      nodejs \
      yarn

# Install gems
COPY Gemfile Gemfile.lock ./
RUN bundle install

# Install JS dependencies and build
COPY package.json yarn.lock ./
RUN yarn install --frozen-lockfile

# Copy application
COPY . .

# Precompile assets
RUN bundle exec rails assets:precompile

# Remove docs and build artifacts
RUN rm -rf docs/ spec/ test/ node_modules/

# Final stage
FROM base

# Copy built artifacts
COPY --from=build /usr/local/bundle /usr/local/bundle
COPY --from=build /app /app

# Health check for Kamal
HEALTHCHECK --interval=10s --timeout=5s --start-period=30s \
    CMD curl -f http://localhost:3000/up || exit 1

EXPOSE 3000

CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
```

**Kamal config/deploy.yml:**

```yaml
service: myapp

image: username/myapp

servers:
  web:
    hosts:
      - 192.168.1.1
    labels:
      traefik.http.routers.myapp.rule: Host(`myapp.com`)

registry:
  username: username
  password:
    - KAMAL_REGISTRY_PASSWORD

env:
  secret:
    - RAILS_MASTER_KEY
```

**Key points:**
- Health check at `/up` endpoint (Rails 7.1+)
- Docs folder removed in build stage
- Puma server for production
- Multi-stage for optimization

</pattern>

## Docker Compose for Full Stack

<pattern name="docker-compose-full-stack">
<description>Production-like environment with all services</description>

**Complete docker-compose.yml:**

```yaml
version: '3.8'

services:
  web:
    build:
      context: .
      target: development
    command: bundle exec rails server -b 0.0.0.0
    volumes:
      - .:/app
      - bundle:/usr/local/bundle
      - node_modules:/app/node_modules
    ports:
      - "3000:3000"
    environment:
      - RAILS_ENV=development
      - DATABASE_URL=postgresql://postgres:password@db:5432/app_development
      - REDIS_URL=redis://redis:6379/0 # If using Redis for any reason
    depends_on:
      - db
    stdin_open: true
    tty: true

  db:
    image: postgres:16-alpine
    volumes:
      - postgres:/var/lib/postgresql/data
    environment:
      - POSTGRES_PASSWORD=password
    ports:
      - "5432:5432"

  # Optional: For running background jobs in development
  worker:
    build:
      context: .
      target: development
    command: bundle exec rails solid_queue:start
    volumes:
      - .:/app
      - bundle:/usr/local/bundle
    environment:
      - RAILS_ENV=development
      - DATABASE_URL=postgresql://postgres:password@db:5432/app_development
    depends_on:
      - db

volumes:
  bundle:
  node_modules:
  postgres:
```

</pattern>

## Common Patterns

<antipatterns>
### ❌ DON'T: Include development files in production

```dockerfile
# BAD: Copies everything including docs/
COPY . .
# No .dockerignore file
```

**Problems:**
- Bloated image with test files, docs, specs
- Longer build times
- Security risk (might copy .env files)
- Wastes CI/CD bandwidth

### ❌ DON'T: Use single-stage builds for production

```dockerfile
# BAD: Single stage, includes build tools in final image
FROM ruby:3.3
RUN apt-get install build-essential
COPY . .
RUN bundle install
```

**Problems:**
- Massive image size (includes build tools)
- Security issues (build tools in production)
- Slower deployments

### ❌ DON'T: Forget to exclude docs folder

```gitignore
# BAD: .dockerignore without docs/
.git/
*.log
tmp/
# Missing: docs/
```

**Problems:**
- Planning docs add unnecessary size
- Specs and ADRs copied to production
- Wasted build time copying markdown files
</antipatterns>

<best-practices>
### ✅ DO: Comprehensive .dockerignore

```gitignore
# Planning documentation
docs/

# Development files
spec/
test/
.git/
```

### ✅ DO: Multi-stage builds

```dockerfile
FROM ruby:3.3 AS builder
# Build here

FROM ruby:3.3-slim
# Production runtime
COPY --from=builder /app /app
RUN rm -rf docs/
```

### ✅ DO: Layer caching optimization

```dockerfile
# Copy dependency files first (cached layer)
COPY Gemfile Gemfile.lock ./
RUN bundle install

# Copy code last (changes frequently)
COPY . .
```

### ✅ DO: Remove docs in final stage

```dockerfile
RUN rm -rf docs/ spec/ test/ tmp/cache
```

</best-practices>

## Testing

<testing-strategy>
### Build Image Locally

```bash
# Build production image
docker build -t myapp:latest .

# Check image size
docker images myapp:latest

# Verify docs excluded
docker run --rm myapp:latest ls -la
# Should NOT show docs/ folder

# Test health check
docker run -p 3000:3000 myapp:latest
curl http://localhost:3000/up
```

### Docker Compose Testing

```bash
# Start all services
docker-compose up -d

# Run tests in container
docker-compose exec web bundle exec rails test

# Check logs
docker-compose logs web

# Cleanup
docker-compose down -v
```
</testing-strategy>

## Checklist

<implementation-checklist>
### Production Dockerfile
- [ ] Multi-stage build (builder + runtime)
- [ ] Alpine or slim base for runtime stage
- [ ] Gems cached in separate layer
- [ ] Assets precompiled in build stage
- [ ] docs/ removed in final stage
- [ ] Non-root user configured
- [ ] Health check endpoint included
- [ ] Proper CMD/ENTRYPOINT

### .dockerignore
- [ ] docs/ folder excluded
- [ ] .git/ excluded
- [ ] spec/ and test/ excluded
- [ ] .env* files excluded
- [ ] tmp/ and log/ excluded
- [ ] Development databases excluded
- [ ] IDE files excluded
- [ ] CI/CD configs excluded

### Docker Compose (Development)
- [ ] Volume mounts for hot-reload
- [ ] Database service included
- [ ] Environment variables set
- [ ] Port mappings configured
- [ ] Named volumes for persistence

### Kamal Deployment
- [ ] Health check at /up endpoint
- [ ] RAILS_MASTER_KEY secret configured
- [ ] Proper image tagging
- [ ] Registry authentication set
- [ ] deploy.yml configured
</implementation-checklist>

## References

- [Rails Docker Guide](https://guides.rubyonrails.org/getting_started_with_docker.html)
- [Docker Multi-Stage Builds](https://docs.docker.com/build/building/multi-stage/)
- [Kamal Documentation](https://kamal-deploy.org/)
- [Rails 8 Deployment](https://rubyonrails.org/2024/10/31/rails-8-0-released)

## Related Skills

- `solid-stack-setup` - SolidQueue/Cache/Cable configuration
- `credentials-management` - Rails encrypted credentials for secrets
- `environment-configuration` - Environment-specific settings
