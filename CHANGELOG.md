# Changelog

## [1.11.1](https://github.com/meysam81/ansible-collections/compare/v1.11.0...v1.11.1) (2026-03-29)


### Features

* add dnsproxy role ([524e3f1](https://github.com/meysam81/ansible-collections/commit/524e3f129aacfd36f4486d4b5fd23eb9a1811cf3))
* add squid and blocklist role ([faea07a](https://github.com/meysam81/ansible-collections/commit/faea07aa06a4607d420f2ad677f267f31dcc15dd))
* add wireguard role and siblings ([78ddd5d](https://github.com/meysam81/ansible-collections/commit/78ddd5dc2c6e0253cb6fac00492c4fded7638adb))
* **haproxy:** update to the latest stable haproxy v3.3.6 ([2ad1d5b](https://github.com/meysam81/ansible-collections/commit/2ad1d5bd90194f288f963407d80ede536f9ef48b))


### Bug Fixes

* add assertions to crowsed, squid and blocklist ([dca555a](https://github.com/meysam81/ansible-collections/commit/dca555ad84bdd6c2821de85d0f9cd7dbc8857efb))
* **CI:** make haproxy test happy, again ([20d7475](https://github.com/meysam81/ansible-collections/commit/20d74755c1285277424bb9d4b6e397458bbb189d))
* **CI:** make linter happy ([0e3742c](https://github.com/meysam81/ansible-collections/commit/0e3742cf4b22c95a2fb0a2dfa6c7ece90dc43fd2))
* **CI:** make linter happy ([e30340e](https://github.com/meysam81/ansible-collections/commit/e30340e903dcf7847f1fe0d438be74544c141756))
* **docs:** add notes and assertions in wg role ([6413713](https://github.com/meysam81/ansible-collections/commit/641371325a9c41feb1c9171245febd9c5e08ba2e))
* drop autoincrement from domain_verifications ([ced114c](https://github.com/meysam81/ansible-collections/commit/ced114cee40d9c98255697570cb330fba81c091b))
* **haproxy:** allow for more flexibility in haproxy config ([0328715](https://github.com/meysam81/ansible-collections/commit/032871504f9ffd863ebecb6c5b9915eb4e27386e))

## [1.11.0](https://github.com/meysam81/ansible-collections/compare/v1.10.13...v1.11.0) (2026-03-28)


### Features

* add haproxy, coraza, lego and cloudflare IPs ([947d256](https://github.com/meysam81/ansible-collections/commit/947d2568aa8df3648d2afe7b35be38e809f583f1))
* add readme and harden the systemd service definitions ([e652bbf](https://github.com/meysam81/ansible-collections/commit/e652bbfea48789799eabf74d39847506afdb7525))
* **CI:** autodiscover roles for testing ([27fa439](https://github.com/meysam81/ansible-collections/commit/27fa43923fe08264f4e729a91da5026fad85f966))
* create golang role to download from go.dev ([709c56b](https://github.com/meysam81/ansible-collections/commit/709c56b8097632874e9fefbfe4e64b56912cfdac))
* **dev:** add flake for local dev ([8fd426d](https://github.com/meysam81/ansible-collections/commit/8fd426da99a592b11d095ded5104da4bdbe667b2))


### Bug Fixes

* **CI:** address failing test jobs ([33c6a2e](https://github.com/meysam81/ansible-collections/commit/33c6a2e39adea532e0dc2465b1cb2612b84a0793))
* **CI:** drop semantic-release in favor of release-please ([9bc70ad](https://github.com/meysam81/ansible-collections/commit/9bc70ad9d57d919bd279a68fe376f72f52bcf352))
* **CI:** make haproxy tests happy ([86cf1d8](https://github.com/meysam81/ansible-collections/commit/86cf1d8ef1bfb3cf639923f4c3ebac1fefe61fc7))
* **CI:** rename release please config file ([4e75f97](https://github.com/meysam81/ansible-collections/commit/4e75f976bb9b4481cad20b68500f18f026ee1559))
* **haproxy:** address cache response header invalidation ([ea479d4](https://github.com/meysam81/ansible-collections/commit/ea479d4a05dc3b83775b982aaaf9a080ea11418f))
* ignore superpowers ([2fd03e9](https://github.com/meysam81/ansible-collections/commit/2fd03e951f7f192c0f972a9ba689c22484ec2d9d))
* obscure the temp and add gpg verification where available ([d9a2b3f](https://github.com/meysam81/ansible-collections/commit/d9a2b3f1dce80a8d163cb767df11cd351af9c0dc))
* update the current version ([4c646c2](https://github.com/meysam81/ansible-collections/commit/4c646c2b7530426582f5e0d7b670531ded80e1b2))
