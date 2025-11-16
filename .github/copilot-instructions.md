# Immich AI Agent Instructions

## Project Overview

Immich is a self-hosted photo and video management solution with a **monorepo architecture** using **pnpm workspaces**. The project consists of multiple components working together:

- **server/** - NestJS backend (TypeScript) with BullMQ job queues, PostgreSQL database (via Kysely), and REST/WebSocket APIs
- **web/** - SvelteKit 5 frontend with Vite, TailwindCSS 4, and TypeScript
- **mobile/** - Flutter app (Dart) using Riverpod state management and Isar local database
- **machine-learning/** - Python FastAPI service using uv for dependency management (CLIP embeddings, facial recognition)
- **cli/** - TypeScript CLI tool for backup and management
- **open-api/** - OpenAPI spec generation and TypeScript SDK

## Development Workflow

### Starting the Environment

The project uses **Docker Compose for local development** with devcontainer support:

```bash
# Start full dev stack (Redis, PostgreSQL, ML service, server, web)
make dev

# Start individual services via VS Code tasks:
# - "Immich API Server (Nest)" - Backend server (port 2283)
# - "Immich Web Server (Vite)" - Frontend dev server (port 3000)
# - Both run automatically with "Immich Server and Web" task on folder open
```

**Auto-Start Configuration:** The development environment can be configured to start automatically on system boot using systemd:

```bash
# Service management commands
sudo systemctl start immich-dev     # Start now
sudo systemctl stop immich-dev      # Stop now
sudo systemctl restart immich-dev   # Restart
sudo systemctl enable immich-dev    # Enable auto-start on boot
sudo systemctl disable immich-dev   # Disable auto-start

# Check status and logs
systemctl status immich-dev         # Current status
sudo journalctl -u immich-dev -f    # Follow logs
```

The systemd service (`immich-dev.service`) runs as your user, starts after Docker is ready, and includes automatic restart on failure. Full documentation available in `AUTO_START_README.md`.

### Package Management

Use **pnpm** for all JavaScript/TypeScript packages:

```bash
# Install dependencies for specific package
pnpm --filter immich install           # server
pnpm --filter immich-web install       # web
pnpm --filter @immich/cli install      # cli

# Or use Makefile shortcuts
make install-server
make install-web

# Build dependencies (SDK must be built before web/cli)
make build-sdk        # Build TypeScript SDK from OpenAPI
make build-web        # Requires SDK to be built first
```

### Testing and Quality

```bash
# Server (NestJS + Vitest)
pnpm --filter immich test              # Unit tests
pnpm --filter immich test:cov          # With coverage
pnpm --filter immich test:medium       # Integration tests with DB

# Web (Vitest + Playwright)
pnpm --filter immich-web test          # Unit tests
pnpm --filter immich-e2e test          # E2E API tests
pnpm --filter immich-e2e test:web      # E2E web tests

# Mobile (Flutter)
cd mobile && dart analyze
cd mobile && dart run custom_lint
cd mobile && dcm analyze lib

# Format/lint all packages
make format-all
make lint-all
make check-all
```

## Architecture Patterns

### Server (NestJS)

**Repository Pattern with Dependency Injection:**

All services extend `BaseService` which injects **all repositories** as dependencies. Repositories are interfaces for database access, external services, and infrastructure:

```typescript
// Services inherit from BaseService which provides all repositories
@Injectable()
export class AlbumService extends BaseService {
  // All repositories available via this.albumRepository, this.assetRepository, etc.
  async create(auth: AuthDto, dto: CreateAlbumDto) {
    const album = await this.albumRepository.create({...});
    await this.eventRepository.emit('AlbumCreated', {...});
    return album;
  }
}
```

**Key conventions:**
- Controllers (`@Controller`) are thin - delegate to services
- Services contain business logic and orchestrate repositories
- Repositories (`@Injectable`) handle data access and external I/O
- DTOs in `src/dtos/` for request/response validation with `class-validator`
- All async operations use Promises (not Observables despite NestJS defaults)

**Job Queue System (BullMQ):**

Background jobs use BullMQ with Redis. Queue definitions in `src/constants.ts`, job handlers in `src/services/job.service.ts`:

```typescript
// Enqueue jobs
await this.jobRepository.queue({ name: JobName.ThumbnailGeneration, data: { id: asset.id } });

// Jobs processed by microservices worker (separate process)
```

**Database Access (Kysely + TypeORM for Migrations):**

- Primary query builder: **Kysely** (type-safe SQL) via `nestjs-kysely`
- Migrations: TypeORM with manual SQL in `server/src/migrations/`
- Run migrations: `pnpm --filter immich run migrations:run`
- Generate SQL schema sync: `pnpm --filter immich run sync:sql`

### Web (SvelteKit 5)

**File-based routing with +page.ts/+page.svelte pattern:**

```
routes/
  admin/
    jobs-status/
      +page.ts        # Load data (runs server-side & client-side)
      +page.svelte    # Component
  photos/[assetId]/
    +page.ts          # Dynamic route with params
```

**API Communication:**

Use the generated TypeScript SDK from `@immich/sdk`:

```typescript
import { getAssets, createAlbum } from '@immich/sdk';

// All API calls are typed and generated from OpenAPI spec
const assets = await getAssets({ take: 100 });
```

**State Management:**

- Svelte 5 runes (`$state`, `$derived`, `$effect`) for reactive state
- Stores in `src/lib/stores/` for global state
- `svelte-persisted-store` for localStorage persistence

**Styling:**

TailwindCSS 4 (using new `@tailwindcss/vite` plugin) with custom theme in `app.css`

### Mobile (Flutter)

**Clean Architecture with Domain Layer:**

The mobile app follows a clean architecture pattern with distinct layers:

```
lib/
  domain/         # Business logic layer (interfaces, models, services, utils)
    interfaces/   # Repository contracts
    models/       # Core business models
    services/     # Business logic services
    utils/        # Domain utilities
  infrastructure/ # Implementation of domain interfaces (API clients, local storage)
  presentation/   # UI components, screens, and widgets
  providers/      # Riverpod state providers (root level for global state)
  repositories/   # Repository implementations
```

**Module Structure:** Features can be organized using modular structure:

```
lib/{feature}/
  models/       # Feature-specific data models
  providers/    # Riverpod state providers
  services/     # Business logic
  ui/           # Reusable widgets
  views/        # Screens/pages
```

**State Management (Riverpod):**

```dart
// Use @riverpod annotation for code generation
@riverpod
class AssetsNotifier extends _$AssetsNotifier {
  @override
  Future<List<Asset>> build() async {
    return await ref.read(assetServiceProvider).getAssets();
  }
}

// Or StateNotifier for simple cases
class CurrentUserProvider extends StateNotifier<UserDto?> {
  CurrentUserProvider() : super(null);
}
```

**Key Principles:**
- Presentation layer never directly uses repositories - always through domain services
- Use dependency injection via Riverpod providers
- Domain layer should not depend on presentation or infrastructure layers

**Local Database:** Isar for offline-first storage

**Code Generation:**

```bash
make translation    # Generate i18n from i18n/en.json
# Riverpod/Isar code gen runs automatically via build_runner
```

### Machine Learning (Python + FastAPI)

**Dependency Management:** Use `uv` (not pip):

```bash
cd machine-learning
uv sync --extra cpu         # CPU-only
uv sync --extra cuda        # NVIDIA CUDA
uv sync --extra rocm        # AMD ROCm
uv add package-name         # Add dependency
uv lock                     # Lock dependencies
```

**Models:** InsightFace models (antelopev2, buffalo_*) for facial recognition, CLIP for embeddings

## OpenAPI and Code Generation

**Critical workflow:** Server defines API → OpenAPI spec → SDK generation

```bash
# After changing DTOs or controllers in server/:
cd open-api
bash bin/generate-open-api.sh           # Regenerate all
bash bin/generate-open-api.sh typescript # Typescript SDK only
bash bin/generate-open-api.sh dart       # Mobile SDK only

# Server must be built first
pnpm --filter immich build
pnpm --filter immich sync:open-api
```

**Important:** Always regenerate SDK after changing server APIs. Web and CLI depend on `@immich/sdk`, mobile uses `mobile/openapi/`.

## Internationalization (i18n)

**Master translations:** All languages in root `i18n/*.json` (e.g., `i18n/en.json`, `i18n/es.json`)

To add translation keys:
1. Add to `i18n/en.json` as `"key": "English text"`
2. Run `cd mobile && make translation` (generates mobile translations)
3. Web auto-loads via `svelte-i18n`
4. Sort JSON: `pnpm --filter immich-web run format:i18n`

## Docker and Deployment

**Development:** `docker/docker-compose.dev.yml` with live-reload containers

**Production:** `docker/docker-compose.prod.yml` - multi-stage builds in `server/Dockerfile`, `web/Dockerfile`, `machine-learning/Dockerfile`

**Ports:**
- 3000: Web dev server (Vite)
- 2283: API server (NestJS)
- 3003: ML service (FastAPI)
- 6379: Redis
- 5432: PostgreSQL

## Common Pitfalls

1. **Build order matters:** SDK must be built before web/cli (`make build-sdk` first)
2. **Migrations:** Always generate migrations for schema changes: `pnpm --filter immich run migrations:generate MigrationName`
3. **Sharp dependency:** Use exact version `^0.34.4` (pinned in overrides)
4. **Mobile OpenAPI:** After regenerating, apply patches in `open-api/patch/` and delete `analysis_options.yaml`
5. **BullMQ jobs:** Jobs queued in API server, processed in microservices worker (separate container)
6. **Auth context:** Use `@Auth() auth: AuthDto` decorator in controllers, check permissions via `requireAccess()`

## Key Files to Reference

- `server/src/services/base.service.ts` - Base class with all repository injections
- `pnpm-workspace.yaml` - Workspace packages and overrides
- `Makefile` - Common development commands
- `mobile/lib/domain/` - Mobile domain layer architecture (interfaces, models, services)
- `server/src/app.module.ts` - NestJS module initialization with BullMQ/Kysely setup
- `.devcontainer/devcontainer.json` - Dev environment configuration
- `AUTO_START_README.md` - Auto-start configuration and systemd service management

## Testing Conventions

- **Server:** Vitest with mocked repositories, co-located `.spec.ts` files
- **Web:** Vitest with `@testing-library/svelte` and happy-dom
- **E2E:** Playwright in `e2e/` directory with docker-compose setup
- **Mobile:** Flutter test framework with widget testing

**Test Utilities:**

Server tests use `automock()` helper from `test/utils.ts` to create mocked instances:

```typescript
import { automock } from 'test/utils';

const mockRepository = automock(AlbumRepository);
mockRepository.create.mockResolvedValue(album);
```

Use factories and test data in `test-data/` directories for consistent test fixtures.
