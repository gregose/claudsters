FROM mcr.microsoft.com/devcontainers/base:ubuntu-24.04

# OpenSCAD nightly snapshot with Manifold backend (10-100x faster than CGAL)
# Pinned to a specific snapshot for reproducibility. Update as needed from:
# https://files.openscad.org/snapshots/
ARG OPENSCAD_SNAPSHOT=OpenSCAD-2026.02.04-x86_64.AppImage

# System dependencies (including OpenSCAD runtime libraries and Blender)
RUN apt-get update && apt-get install -y --no-install-recommends \
    xvfb \
    squashfs-tools \
    python3 \
    python3-pip \
    python3-venv \
    libharfbuzz0b \
    libglib2.0-0 \
    libgl1 \
    libopengl0 \
    libglx-mesa0 \
    libegl1 \
    libfontconfig1 \
    libxkbcommon0 \
    libdbus-1-3 \
    blender \
    && rm -rf /var/lib/apt/lists/*

# Install OpenSCAD from AppImage snapshot.
# Cannot execute the AppImage during build (buildx doesn't have Rosetta binfmt),
# so extract the embedded squashfs directly. The squashfs starts right after the
# ELF binary — parse ELF section headers to find the exact byte offset.
RUN curl -fsSL "https://files.openscad.org/snapshots/${OPENSCAD_SNAPSHOT}" \
        -o /tmp/openscad.AppImage \
    && OFFSET=$(python3 -c "import struct;f=open('/tmp/openscad.AppImage','rb');h=f.read(64);off=struct.unpack_from('<Q',h,40)[0];n=struct.unpack_from('<H',h,60)[0];sz=struct.unpack_from('<H',h,58)[0];print(off+n*sz)") \
    && unsquashfs -d /opt/openscad -offset "$OFFSET" /tmp/openscad.AppImage \
    && ln -sf /opt/openscad/AppRun /usr/local/bin/openscad \
    && rm /tmp/openscad.AppImage

# Python dependencies for geometric validation (validate.py)
COPY requirements.txt /tmp/requirements.txt
RUN pip3 install --break-system-packages -r /tmp/requirements.txt \
    && rm /tmp/requirements.txt
