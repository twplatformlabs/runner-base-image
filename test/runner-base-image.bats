#!/usr/bin/env bats

setup() {
  if [[ -z "${TEST_CONTAINER}" ]]; then
    echo "ERROR: TEST_CONTAINER environment variable is not set"
    echo "Example:"
    echo "  TEST_CONTAINER=my-container bats tests.bats"
    exit 1
  fi
}

@test "gh installed" {
  run bash -c "docker exec ${TEST_CONTAINER} gh --help"
  [[ "${output}" =~ "Work seamlessly with GitHub" ]]
}

@test "docker buildx installed" {
  run bash -c "docker exec ${TEST_CONTAINER} docker buildx --help"
  [[ "${output}" =~ "Extended build capabilities" ]]
}

@test "1password installed" {
  run bash -c "docker exec ${TEST_CONTAINER} op --help"
  [[ "${output}" =~ "1Password CLI" ]]
}

@test "docker scout installed" {
  run bash -c "docker exec ${TEST_CONTAINER} gzip --help"
  [[ "${output}" =~ "Command line tool for Docker Scout" ]]
}

@test "teller installed" {
  run bash -c "docker exec ${TEST_CONTAINER} ls /etc/ssl/certs/"
  [[ "${output}" =~ "Usage: teller" ]]
}
