# pick the deb-based distros you want
d=ubuntu-20.04-amd64

make archive
# build local images (or swap for `docker pull registry.nic.cz/labs/bird:<distro>`)
docker build -t "bird:${d}" "misc/docker/${d}"

# build the source tarball once (skip docs if you want it faster)
docker build -t bird:docbuilder misc/docker/docbuilder
docker run --rm -v "$PWD":/src -w /src bird:docbuilder \
  bash -lc 'ARCHIVE_DOCS=false ./tools/make-archive'


docker run --rm -v "$PWD":/src -w /src "bird:${d}" bash -lc '
autoreconf
./configure
make -j"$(nproc)"
make check

if python3 -m venv /tmp/venv; then . /tmp/venv/bin/activate; fi
pip3 install apkg
apkg build -a bird-$(cat VERSION)*.tar.gz
'