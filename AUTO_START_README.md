# Immich Development Environment Auto-Start

## Overview
The Immich development environment is now configured to automatically start when your computer boots using systemd.

## Service Details

**Service Name:** `immich-dev.service`  
**Service File:** `/etc/systemd/system/immich-dev.service`  
**Working Directory:** `/home/tung/workspace/immich`  
**User:** `tung`

## Service Management Commands

### Check Status
```bash
systemctl status immich-dev
```

### Start Service
```bash
sudo systemctl start immich-dev
```

### Stop Service
```bash
sudo systemctl stop immich-dev
```

### Restart Service
```bash
sudo systemctl restart immich-dev
```

### Disable Auto-Start (prevent from starting at boot)
```bash
sudo systemctl disable immich-dev
```

### Re-enable Auto-Start
```bash
sudo systemctl enable immich-dev
```

### View Logs
```bash
# View recent logs
sudo journalctl -u immich-dev -n 50

# Follow logs in real-time
sudo journalctl -u immich-dev -f

# View logs since last boot
sudo journalctl -u immich-dev -b
```

## Verify Containers

Check that all Immich containers are running:
```bash
docker ps --filter "name=immich"
```

## Access Points

- **Web UI:** http://localhost:3000
- **API Server:** http://localhost:2283
- **ML Service:** http://localhost:3003
- **PostgreSQL:** localhost:5432
- **Redis:** localhost:6379

## How It Works

1. **On Boot:** The service starts automatically after Docker is ready
2. **Command:** Runs `make dev` in the Immich workspace directory
3. **Restart:** If the service fails, it will automatically restart after 10 seconds
4. **On Stop:** Runs `make dev-down` to cleanly shut down containers
5. **GPU:** Uses CUDA GPU acceleration for the ML service (NVIDIA GTX 1080 Ti)

## Manual Development

If you want to temporarily run the development environment manually instead:

1. Stop the systemd service:
   ```bash
   sudo systemctl stop immich-dev
   ```

2. Run manually:
   ```bash
   make dev
   ```

3. When done, restart the service:
   ```bash
   sudo systemctl start immich-dev
   ```

## Troubleshooting

### Service won't start
```bash
# Check service logs
sudo journalctl -u immich-dev -n 100

# Check Docker is running
systemctl status docker

# Verify Docker Compose file
cd /home/tung/workspace/immich
docker compose -f ./docker/docker-compose.dev.yml config
```

### GPU not working
```bash
# Verify NVIDIA runtime is available
docker info 2>&1 | grep -i runtime

# Test GPU access
docker run --rm --gpus all nvidia/cuda:12.0.0-base-ubuntu22.04 nvidia-smi
```

### Containers not starting
```bash
# View container logs
docker logs immich_server
docker logs immich_machine_learning
docker logs immich_web

# Check if ports are already in use
sudo netstat -tlnp | grep -E ':(3000|2283|3003|5432|6379)'
```

## Modifying the Service

If you need to modify the service configuration:

1. Edit the service file:
   ```bash
   sudo nano /etc/systemd/system/immich-dev.service
   ```

2. Reload systemd:
   ```bash
   sudo systemctl daemon-reload
   ```

3. Restart the service:
   ```bash
   sudo systemctl restart immich-dev
   ```

## Removing Auto-Start

To completely remove the auto-start configuration:

```bash
# Stop and disable the service
sudo systemctl stop immich-dev
sudo systemctl disable immich-dev

# Remove the service file
sudo rm /etc/systemd/system/immich-dev.service

# Reload systemd
sudo systemctl daemon-reload
```
