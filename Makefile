MULTI_ARCH_BUILDER ?= buildkit
BUILD_PLATFORMS := linux/amd64,linux/arm64

ARTIFACTORY_DOCKER_PUSH_URL := arunlogo
IMAGE_NAME := python-multi-arch
IMAGE_TAG := latest


BUILDKTIT_X86_SVC ?= tcp://localhost:1234

setup_multi_arch:
	docker buildx rm $(MULTI_ARCH_BUILDER) || true
	docker buildx create --name $(MULTI_ARCH_BUILDER) --driver remote  $(BUILDKTIT_X86_SVC)
	#docker buildx create --append  --name $(MULTI_ARCH_BUILDER) --driver remote  $(BUILDKTIT_X86_SVC)

multi_arch_build:
	docker buildx build --builder $(MULTI_ARCH_BUILDER) --platform linux/amd64 .  \
	--push \
	-t $(ARTIFACTORY_DOCKER_PUSH_URL)/$(IMAGE_NAME):$(IMAGE_TAG)

publish:
	docker buildx imagetools create -t $(ARTIFACTORY_DOCKER_PUSH_URL)/$(IMAGE_NAME)-new:$(IMAGE_TAG) \
		$(ARTIFACTORY_DOCKER_PUSH_URL)/$(IMAGE_NAME):$(IMAGE_TAG)

cleanup_multi_arch:
	docker buildx rm $(MULTI_ARCH_BUILDER) || true