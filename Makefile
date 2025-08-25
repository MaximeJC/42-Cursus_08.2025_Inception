COMPOSE_PROJECT_NAME = inception
COMPOSE_FILE = srcs/docker-compose.yml

#! RULES

.PHONY: all up build down clean re fclean

all: up

up:
	@echo "Starting Inception services..."
	docker compose -f $(COMPOSE_FILE) --project-name $(COMPOSE_PROJECT_NAME) up --build -d

build: up

down:
	@echo "Stopping Inception services..."
	docker compose -f $(COMPOSE_FILE) --project-name $(COMPOSE_PROJECT_NAME) down

# Stops the containers and removes volumes
clean:
	@echo "Cleaning up containers and volumes..."
	docker compose -f $(COMPOSE_FILE) --project-name $(COMPOSE_PROJECT_NAME) down -v

# Full cleanup: containers, volumes, networks, and images
fclean: clean
	@echo "Performing full Docker system cleanup..."
	docker system prune -af --volumes

re: fclean all

logs:
	docker compose -f $(COMPOSE_FILE) --project-name $(COMPOSE_PROJECT_NAME) logs -f -t

ps:
	docker compose -f $(COMPOSE_FILE) --project-name $(COMPOSE_PROJECT_NAME) ps
