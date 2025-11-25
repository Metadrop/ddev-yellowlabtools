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
  [[ "$output" == *"yellowlabtools"* ]]
  # Verify yellowlabtools is installed in web container
  ddev exec which yellowlabtools
}

@test "yellowlabtools is installed and working" {
  set -eu -o pipefail
  cd ${TESTDIR}
  ddev add-on get ${DIR}
  ddev restart
  # Verify yellowlabtools version command works
  run ddev exec yellowlabtools --version
  [ "$status" -eq 0 ]
}
