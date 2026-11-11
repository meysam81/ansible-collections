# HAProxy

Builds HAProxy from the upstream source tarball (QUIC, Prometheus exporter,
Lua, kTLS, OpenSSL, PCRE2) and installs it to `haproxy_base_bin_path`.

## Version and checksum

`haproxy_build_version` defaults to `3.4.7` (the 3.4 LTS branch). The tarball
is verified against `haproxy_build_source_checksum`, which defaults to the
digest listed for that version in `haproxy_build_source_checksums`. Overriding
only the version therefore never checks a different release against the wrong
digest: an unlisted version gets no verification unless you also set the
checksum:

```yaml
        haproxy_build_version: "3.3.6"
        haproxy_build_source_checksum: "sha256:<digest from haproxy.org>"
```
