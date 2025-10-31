---
name: docker-rails-setup
domain: config
dependencies: []
version: 1.0
rails_version: 8.0+
criticality: RECOMMENDED

# Configuration
applies_to:
  - Dockerfile
  - .dockerignore
---

# Docker Rails Setup

Rails 8+ includes Docker support by default. This skill covers the essential .dockerignore configuration to exclude development files from production builds, particularly the `docs/` folder created by the planning agent.

<when-to-use>
- Setting up Docker for Rails 8+ deployment
- Optimizing Docker build times and image sizes
- Excluding planning documentation from production images
- Deploying with Kamal (Rails 8 default deployment tool)
</when-to-use>

<benefits>
- **Smaller Images** - Exclude unnecessary files (docs, tests, specs)
- **Faster Builds** - Less files to copy during `COPY . .`
- **Security** - Prevent accidental inclusion of .env files or credentials
- **Stock Rails 8** - Uses patterns provided by Rails 8 generators
</benefits>

<standards>
- ALWAYS create .dockerignore to exclude development files
- ALWAYS exclude docs/ folder from production images
- Use stock Rails 8 Dockerfile patterns (don't over-customize)
- Leverage Rails 8 DevContainer support when appropriate
</standards>

## .dockerignore Configuration

<pattern name="dockerignore-rails-8">
<description>Essential .dockerignore for Rails 8 projects</description>

**Rails 8 .dockerignore with docs/ exclusion:**

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
db/*.sqlite3
db/*.sqlite3-*
storage/*

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
```

**Why exclude docs/ folder:**

The `docs/` folder is created by the planning agent (@plan) and contains:
- Vision documents (`docs/vision.md`)
- Architecture documents (`docs/architecture/*.md`)
- Feature specifications (`docs/features/F-NNN-*.md`)
- Task breakdowns (`docs/tasks/F-NNN-tasks.md`)
- Architecture Decision Records (`docs/decisions/NNN-*.md`)

**This documentation:**
- Grows over time as features are planned and documented
- Is not needed for application runtime
- Can be several MB of markdown files
- Reduces Docker image size significantly
- Speeds up Docker builds (fewer files to copy)

**CRITICAL:** Always exclude `docs/` from production Docker images.

</pattern>

## Stock Rails 8 Dockerfile

<pattern name="rails-8-stock-dockerfile">
<description>Rails 8 generates Dockerfiles by default</description>

**Rails 8 includes Docker by default:**

When you create a new Rails 8 app, a Dockerfile is generated automatically:

```bash
rails new myapp
# Creates Dockerfile automatically
```

**Basic Docker commands (Rails 8):**

```bash
# Build production image
docker build -t app .

# Create volume for storage
docker volume create app-storage

# Run production container
docker run --rm -it \
  -v app-storage:/rails/storage \
  -p 3000:3000 \
  --env RAILS_MASTER_KEY=<your-key> \
  app
```

**Multi-platform builds:**

```bash
# Build for multiple platforms (production deployment)
docker buildx build --push \
  --platform=linux/amd64,linux/arm64 \
  -t <user/image> .
```

**Key points:**
- Rails 8 Dockerfile is production-optimized by default
- Uses multi-stage builds automatically
- Includes health check at `/up` endpoint
- Compatible with Kamal deployment (Rails 8 default)

</pattern>

## DevContainer Support (Rails 8.1+)

<pattern name="rails-devcontainer">
<description>Rails 8.1+ supports DevContainers for VS Code</description>

**Generate Rails app with DevContainer:**

```bash
# Create new Rails app with DevContainer configuration
rails new myapp --devcontainer
```

**Benefits:**
- Full development environment in Docker
- Consistent across team members
- VS Code integration with Remote-Containers extension
- Includes all dependencies (database, Redis, etc.)

**When to use:**
- Teams want consistent development environments
- Onboarding new developers
- Working across multiple machines

</pattern>

## Kamal Deployment (Rails 8 Default)

<pattern name="kamal-rails-8">
<description>Kamal is the default deployment tool for Rails 8</description>

**Kamal ships with Rails 8:**

Rails 8 includes Kamal configuration by default in `config/deploy.yml`.

**Basic Kamal workflow:**

```bash
# Deploy to production
kamal deploy

# Check deployment status
kamal app logs

# Execute Rails commands remotely
kamal app exec 'bin/rails db:migrate'
```

**Requirements:**
- Dockerfile in project root (included by default)
- Health check endpoint at `/up` (included by default)
- `RAILS_MASTER_KEY` secret configured

**Kamal benefits:**
- Zero-downtime deployments
- Built-in SSL/TLS with Let's Encrypt
- Multi-server support
- Docker-based, no vendor lock-in

</pattern>

## Common Patterns

<antipatterns>
### ❌ DON'T: Include docs/ in production

```dockerfile
# BAD: No .dockerignore file
COPY . .
# Copies docs/, test/, spec/, etc.
```

**Problems:**
- Bloated image with planning docs not needed at runtime
- Longer build times
- Wasted CI/CD bandwidth

### ❌ DON'T: Over-customize the Dockerfile

```dockerfile
# BAD: Custom Alpine builds, complex optimizations
FROM ruby:3.3-alpine AS builder
RUN apk add --no-cache build-base ...
# Rails 8 Dockerfile is already optimized
```

**Problems:**
- Diverges from Rails 8 defaults
- Harder to maintain
- May break with Rails updates

</antipatterns>

<best-practices>
### ✅ DO: Use stock Rails 8 Dockerfile

```bash
# Good: Let Rails generate the Dockerfile
rails new myapp
# Dockerfile is already production-optimized
```

### ✅ DO: Create comprehensive .dockerignore

```gitignore
# Essential exclusions
docs/
spec/
test/
.git/
.env*
```

### ✅ DO: Leverage Kamal for deployment

```bash
# Rails 8 default deployment
kamal deploy
```

### ✅ DO: Use DevContainers for development

```bash
# Consistent dev environment
rails new myapp --devcontainer
```

</best-practices>

## Quick Start

<implementation-checklist>
### New Rails 8 Project with Docker

```bash
# 1. Create new Rails 8 app (includes Dockerfile)
rails new myapp

# 2. Add .dockerignore with docs/ exclusion
# (See pattern above)

# 3. Build and test locally
docker build -t myapp .
docker run -p 3000:3000 myapp

# 4. Deploy with Kamal
kamal deploy
```

### Existing Rails Project

```bash
# 1. Add .dockerignore with docs/ exclusion
# (See pattern above)

# 2. Use stock Rails 8 Dockerfile if possible
# (Avoid custom Alpine/optimization unless necessary)

# 3. Test build
docker build -t myapp .

# 4. Deploy
kamal deploy
```

</implementation-checklist>

## References

- [Rails 8 Docker Guide](https://guides.rubyonrails.org/getting_started_with_docker.html)
- [Kamal Documentation](https://kamal-deploy.org/)
- [Rails 8 Release Notes](https://rubyonrails.org/2024/10/31/rails-8-0-released)

## Related Skills

- `solid-stack-setup` - SolidQueue/Cache/Cable configuration
- `credentials-management` - Rails encrypted credentials for secrets
- `environment-configuration` - Environment-specific settings
