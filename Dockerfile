FROM debian:buster
MAINTAINER muallin@gmail.com

WORKDIR /src/git

# Update system
RUN apt-get update && \
    apt-get -y install qt5-image-formats-plugins p7zip-full git dumb-init qt5-default libpoppler-qt5-dev libpoppler-qt5-1 wget unzip libqt5sql5-sqlite libqt5sql5 sqlite3 libqt5network5 libqt5gui5 libqt5core5a build-essential cmake zlib1g-dev liblzma-dev libbz2-dev
RUN git clone https://github.com/YACReader/yacreader.git . && \
    git checkout 9.8.2
# compile the unrar (from SteveDevOps repo)
RUN LD_LIBRARY_PATH=/usr/local/lib/ && \
    export LD_LIBRARY_PATH && \
    cd /src/git/ && \
    git clone https://github.com/selmf/unarr && \
    cd /src/git/unarr/ && \
    mkdir build && \
    cd /src/git/unarr/build && \
    cmake .. -DENABLE_7Z=ON -DBUILD_SHARED_LIBS=ON && \
    make && \
    make install && \
    printenv LD_LIBRARY_PATH && \
    ldconfig -V && \
    ln -s /src/git/unarr/unarr.h /usr/include/unarr.h && \
    ln -s /usr/local/lib/libunarr.so /usr/lib/x86_64-linux-gnu/libunarr.so && \
    ln -s /usr/local/lib/libunarr.so /usr/lib/x86_64-linux-gnu/libunarr.so.1 && \
    ln -s /usr/local/lib/libunarr.so /usr/lib/x86_64-linux-gnu/libunarr.so.1.0.1 && \
    ln -s /usr/local/lib/pkgconfig/libunarr.pc /usr/lib/x86_64-linux-gnu/pkgconfig/libunarr.pc
RUN cd /src/git/YACReaderLibraryServer && \
    qmake "CONFIG+=server_standalone" YACReaderLibraryServer.pro && \
    make  && \
    make install
RUN cd /     && \
    apt-get purge -y git wget build-essential && \
    apt-get -y autoremove &&\
    rm -rf /src && \
    rm -rf /var/cache/apt
# make the link for the configuration to make it persistent and export the volumet
# this should prevent losing the library at each update
RUN ln -s /root/.local/share/YACReader/YACReaderLibrary/ /config
#ADD YACReaderLibrary.ini /root/.local/share/YACReader/YACReaderLibrary/

# add specific volumes: configuration, comics repository, and hidden library data to separate them
VOLUME ["/comics", "/config"]

EXPOSE 8080

ENV LC_ALL=C.UTF8

ENTRYPOINT ["YACReaderLibraryServer","start"]
