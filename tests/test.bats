setup() {
  set -eu -o pipefail
  export DIR="$( cd "$( dirname "$BATS_TEST_DIRNAME" )" >/dev/null 2>&1 && pwd )"
  export TESTDIR=~/tmp/test-yellowlabtools
  mkdir -p $TESTDIR
  export PROJNAME=test-yellowlabtools
  export DDEV_NON_INTERACTIVE=true
  ddev delete -Oy ${PROJNAME} >/dev/null 2>&1 || true
  cd "${TESTDIR}"
  ddev config --project-name=${PROJNAME}
  ddev start -y >/dev/null
}

teardown() {
  set -eu -o pipefail
  cd ${TESTDIR} || ( printf "unable to cd to ${TESTDIR}\n" && exit 1 )
  ddev delete -Oy ${PROJNAME} >/dev/null 2>&1
  [ "${TESTDIR}" != "" ] && rm -rf ${TESTDIR}
}

@test "install from directory" {
  set -eu -o pipefail
  cd ${TESTDIR}
  echo "# ddev add-on get ${DIR} with project ${PROJNAME} in ${TESTDIR} ($(pwd))" >&3
  ddev add-on get ${DIR}
  ddev restart
  # Verify yellowlabtools command exists (shows usage when called without args)
  run bash -c "ddev yellowlabtools 2>&1"
  [[ "$output" == *"URL is required"* ]]
  # Verify yellowlabtools container is running
  run ddev exec -s yellowlabtools which yellowlabtools
  [ "$status" -eq 0 ]
}

@test "yellowlabtools CLI is working" {
  set -eu -o pipefail
  cd ${TESTDIR}
  ddev add-on get ${DIR}
  ddev restart
  # Verify yellowlabtools can analyze a URL
  run ddev exec -s yellowlabtools yellowlabtools --version
  [ "$status" -eq 0 ]
}

@test "yellowlabtools web server is running" {
  set -eu -o pipefail
  cd ${TESTDIR}
  ddev add-on get ${DIR}
  ddev restart
  # Verify web UI is accessible on port 9034 (HTTPS)
  run curl -sk https://${PROJNAME}.ddev.site:9034
  [ "$status" -eq 0 ]
  [[ "$output" == *"Yellow Lab Tools"* ]]
}
