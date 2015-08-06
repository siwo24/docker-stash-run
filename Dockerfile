FROM java:7

ENV STASH_HOME     /var/atlassian/stash
ENV STASH_INSTALL  /opt/atlassian/stash

RUN set -x \
    && apt-get update --quiet \
    && apt-get install --quiet --yes --no-install-recommends libtcnative-1 git-core xmlstarlet \
    && apt-get clean \
    && chmod -R 700           "${STASH_HOME}" \
    && chown -R daemon:daemon "${STASH_HOME}" \
    && chmod -R 700           "${STASH_INSTALL}/conf" \
    && chmod -R 700           "${STASH_INSTALL}/logs" \
    && chmod -R 700           "${STASH_INSTALL}/temp" \
    && chmod -R 700           "${STASH_INSTALL}/work" \
    && chown -R daemon:daemon "${STASH_INSTALL}/conf" \
    && chown -R daemon:daemon "${STASH_INSTALL}/logs" \
    && chown -R daemon:daemon "${STASH_INSTALL}/temp" \
    && chown -R daemon:daemon "${STASH_INSTALL}/work" \
    && ln --symbolic          "/usr/lib/x86_64-linux-gnu/libtcnative-1.so" "${STASH_INSTALL}/lib/native/libtcnative-1.so" \
    && sed --in-place         's/^# umask 0027$/umask 0027/g' "${STASH_INSTALL}/bin/setenv.sh" \
    && xmlstarlet             ed --inplace \
        --delete              "Server/Service/Engine/Host/@xmlValidation" \
        --delete              "Server/Service/Engine/Host/@xmlNamespaceAware" \
                              "${STASH_INSTALL}/conf/server.xml"

# Use the default unprivileged account. This could be considered bad practice
# on systems where multiple processes end up being executed by 'daemon' but
# here we only ever run one process anyway.
USER daemon:daemon

# Expose default HTTP connector port.
EXPOSE 7990 7999

CMD ["/opt/atlassian/stash/bin/start-stash.sh", "-fg"]