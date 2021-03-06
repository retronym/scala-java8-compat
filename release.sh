#! /bin/bash -e

function sbt211() {
  sbt 'set scalaVersion := "2.11.0-RC3"' 'set scalaBinaryVersion := scalaVersion.value' $@
  return $?
}
die () {
  echo "$@"
  exit 1
}

CHECK=";clean;test;publishLocal"
RELEASE=";clean;test;publish"
VERSION=`gsed -rn 's/version :=.*"(.+).*"/\1/p' build.sbt`
[[ -n "$(git status --porcelain)" ]] && die "working directory is not clean!"

sbt $CHECK
sbt $RELEASE
sbt211 $CHECK
sbt211 $RELEASE

cat <<EOM
Released! For non-snapshot releases:
 - tag: git tag -s -a v$VERSION -m "scala-java8-compat $VERSION"
 - push tag: git push origin v$VERSION
 - close and release the staging repository: https://oss.sonatype.org
 - change the version number in build.sbt to a suitable -SNAPSHOT version
EOM
