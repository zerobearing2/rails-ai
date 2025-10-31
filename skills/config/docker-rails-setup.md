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

Rails 8+ includes Docker support by default. This skill covers essential .dockerignore configuration to exclude development files from production builds, particularly the `docs/` folder created by the planning agent.

<when-to-use>
- Setting up Docker for Rails 8+ deployment
- Optimizing Docker build times and image sizes
- Excluding planning documentation from production images
</when-to-use>

<benefits>
- **Smaller Images** - Exclude unnecessary files (docs, tests, specs)
- **Faster Builds** - Less files to copy during `COPY . .`
- **Security** - Prevent accidental inclusion of .env files
</benefits>

<standards>
- ALWAYS create .dockerignore to exclude development files
- ALWAYS exclude docs/ folder from production images
- Use stock Rails 8 Dockerfile patterns (don't over-customize)
</standards>

## .dockerignore Configuration

<pattern name="dockerignore-rails-8">
<description>Essential .dockerignore for Rails 8 projects</description>

```gitignore
# Planning and Documentation
docs/
*.md
README*

# Development Files
.git/
.github/
.gitignore
.dockerignore

# Environment Files
.env*
config/master.key
config/credentials/*.key

# Test Files
spec/
test/
coverage/

# Dependencies
.bundle/
vendor/cache/

# Logs and Temp
log/*
tmp/*
*.log

# Development Databases
*.sqlite3
db/*.sqlite3*
storage/*

# Node
node_modules/

# IDE Files
.vscode/
.idea/
*.swp
.DS_Store
```

**Why exclude docs/:**
- Created by planning agent (@plan) with vision, architecture, features, tasks, and ADRs
- Not needed for runtime
- Can be several MB of markdown
- Significantly reduces image size and build time

**CRITICAL:** Always exclude `docs/` from production Docker images.

</pattern>

## Stock Rails 8 Dockerfile

<pattern name="rails-8-stock-dockerfile">
<description>Rails 8 generates Dockerfiles by default</description>

Rails 8 creates a production-optimized Dockerfile automatically:

```bash
rails new myapp  # Creates Dockerfile automatically

# Build and run
docker build -t app .
docker run -p 3000:3000 --env RAILS_MASTER_KEY=<key> app

# Multi-platform build
docker buildx build --push --platform=linux/amd64,linux/arm64 -t <user/image> .
```

**Key features:**
- Multi-stage builds for smaller images
- Health check at `/up` endpoint
- Kamal-compatible (Rails 8 default deployment)

</pattern>

## DevContainer Support (Rails 8.1+)

<pattern name="rails-devcontainer">
<description>Rails 8.1+ supports DevContainers for VS Code</description>

```bash
rails new myapp --devcontainer
```

**Benefits:**
- Consistent development environment across team
- VS Code Remote-Containers integration
- Includes all dependencies (database, Redis, etc.)
- Ideal for onboarding and multi-machine workflows

</pattern>

## Kamal Deployment (Rails 8 Default)

<pattern name="kamal-rails-8">
<description>Kamal is the default deployment tool for Rails 8</description>

Rails 8 includes Kamal configuration in `config/deploy.yml`:

```bash
kamal deploy                              # Deploy to production
kamal app logs                            # Check status
kamal app exec 'bin/rails db:migrate'    # Remote commands
```

**Requirements:**
- Dockerfile (included by default)
- Health check at `/up` (included by default)
- `RAILS_MASTER_KEY` configured

**Benefits:** Zero-downtime deploys, SSL/TLS, multi-server support, no vendor lock-in.

</pattern>

## Common Patterns

<antipatterns>
### ❌ DON'T: Skip .dockerignore

```dockerfile
# BAD: No .dockerignore → copies docs/, test/, spec/
COPY . .
```

**Problem:** Bloated images, longer builds, wasted CI/CD bandwidth.

### ❌ DON'T: Over-customize Dockerfile

```dockerfile
# BAD: Custom Alpine builds
FROM ruby:3.3-alpine AS builder
RUN apk add --no-cache build-base ...
```

**Problem:** Harder to maintain, may break with Rails updates.

</antipatterns>

<best-practices>
### ✅ DO: Use stock Rails 8 Dockerfile

```bash
rails new myapp  # Dockerfile already optimized
```

### ✅ DO: Create comprehensive .dockerignore

```gitignore
docs/
spec/
test/
.git/
.env*
```

### ✅ DO: Leverage Kamal

```bash
kamal deploy  # Rails 8 default
```

</best-practices>

## Quick Start

<implementation-checklist>
### New Rails 8 Project

```bash
rails new myapp               # 1. Creates Dockerfile
# 2. Add .dockerignore (see pattern above)
docker build -t myapp .       # 3. Build locally
kamal deploy                  # 4. Deploy
```

### Existing Rails Project

```bash
# 1. Add .dockerignore (see pattern above)
# 2. Use stock Rails 8 Dockerfile
docker build -t myapp .       # 3. Test
kamal deploy                  # 4. Deploy
```

</implementation-checklist>

## References

- [Rails 8 Docker Guide](https://guides.rubyonrails.org/getting_started_with_docker.html)
- [Kamal Documentation](https://kamal-deploy.org/)
- [Rails 8 Release Notes](https://rubyonrails.org/2024/10/31/rails-8-0-released)

## Related Skills

- `solid-stack-setup` - SolidQueue/Cache/Cable configuration
- `credentials-management` - Rails encrypted credentials
