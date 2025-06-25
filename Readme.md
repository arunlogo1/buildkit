Important Commands


## setup_multi_arch_builders_k8s:
	docker buildx rm $(MULTI_ARCH_BUILDER) || true
	docker buildx create --name buildkit-x86 --driver remote  tcp://127.0.0.1:1234
	docker buildx create --append  --name $(MULTI_ARCH_BUILDER) --driver remote  $(BUILDKTIT_X86_SVC)

# cleanup_multi_arch:
	docker buildx rm $(MULTI_ARCH_BUILDER) || true


	docker buildx build --builder $(MULTI_ARCH_BUILDER) --platform linux/amd64,linux/arm64 .  \
		--build-arg ALPINE_VERSION=$(ALPINE_VERSION) \
		--build-arg SCRATCH_VERSION=$(SCRATCH_VERSION) --push \
		-t $(ARTIFACTORY_DOCKER_PUSH_URL)/$(IMAGE_NAME):$(IMAGE_TAG)-build$(GO_PIPELINE_COUNTER)


# publish
	docker buildx imagetools create -t $(ARTIFACTORY_DOCKER_PUSH_URL)/$(IMAGE_NAME):$(IMAGE_TAG) \
		$(ARTIFACTORY_DOCKER_PUSH_URL)/$(IMAGE_NAME):$(IMAGE_TAG)-build$(GO_PIPELINE_COUNTER)


docker inspect <image-name>
