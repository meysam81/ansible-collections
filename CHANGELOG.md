# Changelog

## [1.11.2](https://github.com/meysam81/ansible-collections/compare/v1.11.1...v1.11.2) (2026-04-01)


### Features

* add 6 more items to blocklist updater ([975c9f1](https://github.com/meysam81/ansible-collections/commit/975c9f16a372887956ca3c35a93e603a52b96988))
* add egress firewall for wg-squid integration ([c706c32](https://github.com/meysam81/ansible-collections/commit/c706c32527910ea032d5f5765e871759a874438d))
* add inbound-routing role ([85790ac](https://github.com/meysam81/ansible-collections/commit/85790ac626c938e6cd37f3ed2609637517c2f7c8))
* add k3s role ([04c7669](https://github.com/meysam81/ansible-collections/commit/04c76693c1e4cfa1754d353cba4679b4e197538f))
* add proxy client for system-wide config ([7db8533](https://github.com/meysam81/ansible-collections/commit/7db853370bec3610c6af49038af8625c7861f505))
* apply security hardening to systemd services ([9e5d504](https://github.com/meysam81/ansible-collections/commit/9e5d504abe9b29b5552030985ff3e600301414a3))
* complete the dnsproxy Q/A & verification ([6674ee8](https://github.com/meysam81/ansible-collections/commit/6674ee8d4de0fbd8913120667a76f500a63d35cb))
* complete the migration to DAG dependency setup ([ff530af](https://github.com/meysam81/ansible-collections/commit/ff530af3bc963f080f470f1c483aa612450fd520))
* complete the review and verification of lego and tls cert ([307367d](https://github.com/meysam81/ansible-collections/commit/307367d0562b7fd2ecbed4c8ad6608f273de55f1))
* complete the squid role with full security hardening ([4d326e9](https://github.com/meysam81/ansible-collections/commit/4d326e920cd5ee73e901a1e656d47c66594e336c))
* finalize cloudflare-ips and the haproxy suite ([7a7dfe4](https://github.com/meysam81/ansible-collections/commit/7a7dfe49bcdf7aaf319a58fa342ab9aba74f3631))
* log squid to journal in human-readable format ([556fd2f](https://github.com/meysam81/ansible-collections/commit/556fd2fd0cc3599a8bae509909247731f7175390))
* **wireguard:** add ipv6 native support ([988635e](https://github.com/meysam81/ansible-collections/commit/988635e8993dbea7578ef1490fa329112448ae04))
* **wireguard:** allow multiple clients to wg server ([4f92455](https://github.com/meysam81/ansible-collections/commit/4f9245593f2264b4bb3d11a4b12b105c34594928))


### Bug Fixes

* address missing dnsproxy binary ([328b2b0](https://github.com/meysam81/ansible-collections/commit/328b2b00ab4a544763d4f23d265cd14d76b7c4c5))
* address syntax error ([fd4dbff](https://github.com/meysam81/ansible-collections/commit/fd4dbffe323f8636eeaaf1215807adfcdbd80e97))
* always log to journal ([5f9fe7f](https://github.com/meysam81/ansible-collections/commit/5f9fe7fe35286168988afe7e8a242294e50a4b08))
* **CI:** remove tags from trigger ([55d078a](https://github.com/meysam81/ansible-collections/commit/55d078a397cf7debf612dfa166565a1c237034c9))
* **dnsproxy:** verify binary working before disabling other resolvers ([9e2b95a](https://github.com/meysam81/ansible-collections/commit/9e2b95a95dad9e52e4a8a04d64790fc3336a4a6a))
* **dnsproxy:** write sysctl without exec permission ([543feb7](https://github.com/meysam81/ansible-collections/commit/543feb72c5aa8cdf3cebc6b8c0ef6166133ce552))
* **squid:** create separate lists for blocklist ACLs ([94226be](https://github.com/meysam81/ansible-collections/commit/94226beb15bf3f32a243b1bc10eb7af45f546cb7))
* **squid:** drop the breaking dns nameserver ([e6789fa](https://github.com/meysam81/ansible-collections/commit/e6789fa2e4ffdcf2d89f8deaefa35c33b8798145))
* start haproxy after creating config ([56cb1c5](https://github.com/meysam81/ansible-collections/commit/56cb1c55c166ec3e0996c8a3c26f965d34e3c593))
* use static import task instead ([bc1bfb5](https://github.com/meysam81/ansible-collections/commit/bc1bfb558c1448ff8b826704fefbc201c4f4d353))


### Miscellaneous Chores

* **CI:** force release ([677ec39](https://github.com/meysam81/ansible-collections/commit/677ec398d3f6bcd6a1535ba20ea8c2a8a14dd4fe))
* **CI:** trigger another force release ([74579a6](https://github.com/meysam81/ansible-collections/commit/74579a68c2da7957254856e868a1795193c4c8c5))

## [1.12.0](https://github.com/meysam81/ansible-collections/compare/v1.11.1...v1.12.0) (2026-04-01)


### Features

* add 6 more items to blocklist updater ([975c9f1](https://github.com/meysam81/ansible-collections/commit/975c9f16a372887956ca3c35a93e603a52b96988))
* add egress firewall for wg-squid integration ([c706c32](https://github.com/meysam81/ansible-collections/commit/c706c32527910ea032d5f5765e871759a874438d))
* add inbound-routing role ([85790ac](https://github.com/meysam81/ansible-collections/commit/85790ac626c938e6cd37f3ed2609637517c2f7c8))
* add k3s role ([04c7669](https://github.com/meysam81/ansible-collections/commit/04c76693c1e4cfa1754d353cba4679b4e197538f))
* add proxy client for system-wide config ([7db8533](https://github.com/meysam81/ansible-collections/commit/7db853370bec3610c6af49038af8625c7861f505))
* apply security hardening to systemd services ([9e5d504](https://github.com/meysam81/ansible-collections/commit/9e5d504abe9b29b5552030985ff3e600301414a3))
* complete the dnsproxy Q/A & verification ([6674ee8](https://github.com/meysam81/ansible-collections/commit/6674ee8d4de0fbd8913120667a76f500a63d35cb))
* complete the migration to DAG dependency setup ([ff530af](https://github.com/meysam81/ansible-collections/commit/ff530af3bc963f080f470f1c483aa612450fd520))
* complete the review and verification of lego and tls cert ([307367d](https://github.com/meysam81/ansible-collections/commit/307367d0562b7fd2ecbed4c8ad6608f273de55f1))
* complete the squid role with full security hardening ([4d326e9](https://github.com/meysam81/ansible-collections/commit/4d326e920cd5ee73e901a1e656d47c66594e336c))
* finalize cloudflare-ips and the haproxy suite ([7a7dfe4](https://github.com/meysam81/ansible-collections/commit/7a7dfe49bcdf7aaf319a58fa342ab9aba74f3631))
* log squid to journal in human-readable format ([556fd2f](https://github.com/meysam81/ansible-collections/commit/556fd2fd0cc3599a8bae509909247731f7175390))
* **wireguard:** add ipv6 native support ([988635e](https://github.com/meysam81/ansible-collections/commit/988635e8993dbea7578ef1490fa329112448ae04))
* **wireguard:** allow multiple clients to wg server ([4f92455](https://github.com/meysam81/ansible-collections/commit/4f9245593f2264b4bb3d11a4b12b105c34594928))


### Bug Fixes

* address missing dnsproxy binary ([328b2b0](https://github.com/meysam81/ansible-collections/commit/328b2b00ab4a544763d4f23d265cd14d76b7c4c5))
* address syntax error ([fd4dbff](https://github.com/meysam81/ansible-collections/commit/fd4dbffe323f8636eeaaf1215807adfcdbd80e97))
* always log to journal ([5f9fe7f](https://github.com/meysam81/ansible-collections/commit/5f9fe7fe35286168988afe7e8a242294e50a4b08))
* **dnsproxy:** verify binary working before disabling other resolvers ([9e2b95a](https://github.com/meysam81/ansible-collections/commit/9e2b95a95dad9e52e4a8a04d64790fc3336a4a6a))
* **dnsproxy:** write sysctl without exec permission ([543feb7](https://github.com/meysam81/ansible-collections/commit/543feb72c5aa8cdf3cebc6b8c0ef6166133ce552))
* **squid:** create separate lists for blocklist ACLs ([94226be](https://github.com/meysam81/ansible-collections/commit/94226beb15bf3f32a243b1bc10eb7af45f546cb7))
* **squid:** drop the breaking dns nameserver ([e6789fa](https://github.com/meysam81/ansible-collections/commit/e6789fa2e4ffdcf2d89f8deaefa35c33b8798145))
* start haproxy after creating config ([56cb1c5](https://github.com/meysam81/ansible-collections/commit/56cb1c55c166ec3e0996c8a3c26f965d34e3c593))
* use static import task instead ([bc1bfb5](https://github.com/meysam81/ansible-collections/commit/bc1bfb558c1448ff8b826704fefbc201c4f4d353))

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
