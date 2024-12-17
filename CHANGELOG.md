# Changelog

## [1.8.1](https://github.com/meysam81/ansible-collections/compare/v1.8.0...v1.8.1) (2024-12-17)


### Bug Fixes

* **kratos:** spin up the courier next to the server ([41d3463](https://github.com/meysam81/ansible-collections/commit/41d346382aa134d53dd49324f02e4652f86b8132))

## [1.8.0](https://github.com/meysam81/ansible-collections/compare/v1.7.0...v1.8.0) (2024-12-13)


### Features

* add oathkeeper ([94dbcac](https://github.com/meysam81/ansible-collections/commit/94dbcac6c98d5b121a5cbea70ed8e800c166a473))

## [1.7.0](https://github.com/meysam81/ansible-collections/compare/v1.6.0...v1.7.0) (2024-12-13)


### Features

* add kratos role ([819a4b1](https://github.com/meysam81/ansible-collections/commit/819a4b10ba502f38cca692d165d182261a0ea238))

## [1.6.0](https://github.com/meysam81/ansible-collections/compare/v1.5.5...v1.6.0) (2024-12-01)


### Features

* **k8s-oidc:** add bare-metal k8s oidc github pages ([a18a830](https://github.com/meysam81/ansible-collections/commit/a18a830dd194612e03afcb17ae15cd40073f8f4f))

## [1.5.5](https://github.com/meysam81/ansible-collections/compare/v1.5.4...v1.5.5) (2024-11-07)


### Miscellaneous Chores

* **vmagent:** upgrade to v1.106.0 ([51e564d](https://github.com/meysam81/ansible-collections/commit/51e564db055108dc938774f84f01e2a128dd5c3b))

## [1.5.4](https://github.com/meysam81/ansible-collections/compare/v1.5.4...v1.5.4) (2024-11-02)


### Features

* **CI:** add release please ([6a21aa6](https://github.com/meysam81/ansible-collections/commit/6a21aa6fcf4ca51281d27cfac266ef3203541fea))
* **CI:** create release over tag ([85f8868](https://github.com/meysam81/ansible-collections/commit/85f886857b035a1d9d78f4161e769d80cf5a21bb))
* create promtail and system user ([c9971bb](https://github.com/meysam81/ansible-collections/commit/c9971bb7ac2931a56ff0de5fc3bec9dc49faf795))
* create pushgateway role ([545d0e4](https://github.com/meysam81/ansible-collections/commit/545d0e46589fcb029c4a79d79b50ed68f90b732d))
* create the node-exporter role ([71ea899](https://github.com/meysam81/ansible-collections/commit/71ea899e0661f7342c141241a5c32bcecb581d14))
* create the vmagent role and test the vagrant in CI ([606f3da](https://github.com/meysam81/ansible-collections/commit/606f3da161260db88725d4f281389a163aedf10d))
* initial haproxy role definition ([aaf9329](https://github.com/meysam81/ansible-collections/commit/aaf932984d96aface8e60a94dd3587d70625b422))
* **vmagent:** add fail2ban to scrape config ([19197e4](https://github.com/meysam81/ansible-collections/commit/19197e45dd8772a2dbdcfaa28efee53fa92cbd9f))
* **vmagent:** allow for additional CLI flags in systemd definition ([5366058](https://github.com/meysam81/ansible-collections/commit/53660586a68921fa5cdccb925cc75e62849c3156))


### Bug Fixes

* **CI:** add the missing requirements.yml ([563f447](https://github.com/meysam81/ansible-collections/commit/563f447acd80db79b1c3d9ac8f10212f53cbd9c3))
* **CI:** address playbook schema issue ([#4](https://github.com/meysam81/ansible-collections/issues/4)) ([c544276](https://github.com/meysam81/ansible-collections/commit/c544276ed292c1a5d9f423c5123be71099e88b39))
* **CI:** create user with duplciate code even ([9c93e05](https://github.com/meysam81/ansible-collections/commit/9c93e058c26580be9a47527db928fa88f8475c90))
* **CI:** drop find altogether ([1faa145](https://github.com/meysam81/ansible-collections/commit/1faa14589df9080e19a2159f365019d4f1ee900b))
* **CI:** escape quotes properly ([e3eb6e6](https://github.com/meysam81/ansible-collections/commit/e3eb6e6106e0f79061876879ba9572f073aced62))
* **CI:** extract promtail with expected filename ([55f82dc](https://github.com/meysam81/ansible-collections/commit/55f82dc4637f2d8b390230bc6fe4027ae9cb897a))
* **CI:** fetch and parse promtail checksum ([fec7fc9](https://github.com/meysam81/ansible-collections/commit/fec7fc9bcc1ea7338e6cfeafe28e7838045f93fb))
* **CI:** find promtail explicitly ([b82718e](https://github.com/meysam81/ansible-collections/commit/b82718ed3645b87a80567ca8455c5c3aae3e6a37))
* **CI:** install dependencies before test ([4e4d6b2](https://github.com/meysam81/ansible-collections/commit/4e4d6b2df5387ccda07c8c8216f5068c6b7ac53b))
* **CI:** list unarchive files before using it ([0a19f06](https://github.com/meysam81/ansible-collections/commit/0a19f0677ece567f28532857081f83bb650b4bf5))
* **CI:** make it work ([d35cf85](https://github.com/meysam81/ansible-collections/commit/d35cf85f75e0ac1e8b3d265020cf678effc8eccd))
* **CI:** modify undefined var name ([918dd5e](https://github.com/meysam81/ansible-collections/commit/918dd5e12388d864d7617b0cb0e2ca43ad75451d))
* **CI:** now use json_query to capture the value ([26de4eb](https://github.com/meysam81/ansible-collections/commit/26de4ebd77b1ac492bf50ada85dd22225cb3b8e7))
* **CI:** pass token ([306d9cb](https://github.com/meysam81/ansible-collections/commit/306d9cba855002234b14fa8680e4b06020dc7d07))
* **CI:** place some content in requirements ([b1c241b](https://github.com/meysam81/ansible-collections/commit/b1c241bbd5c2db7ff1a61d1a3827fbb77622c94c))
* **CI:** provide name and mode ([edd6ade](https://github.com/meysam81/ansible-collections/commit/edd6adeefa016eb37fb03c236d7565ebacc9fdd5))
* **CI:** provide the promtail handler ([36b54ce](https://github.com/meysam81/ansible-collections/commit/36b54cede9d5508b509a117d692550dc896c934c))
* **CI:** remove extra opts from unarchive ([56f3f17](https://github.com/meysam81/ansible-collections/commit/56f3f1724add336044fb616a23d7ec067d06c3e3))
* **CI:** remove mode and add depth ([dee5891](https://github.com/meysam81/ansible-collections/commit/dee58916d7fc606994b9ef9394c9899a96323901))
* **CI:** run tests against the runner ([e3d0be4](https://github.com/meysam81/ansible-collections/commit/e3d0be4263e5cb4fce6aebc2dffa961748455ead))
* **CI:** run tests before publishing ([a75efc0](https://github.com/meysam81/ansible-collections/commit/a75efc04edc59af9be6279ed830905c26514ff15))
* **CI:** run tests on macos-12 ([ef14f9a](https://github.com/meysam81/ansible-collections/commit/ef14f9a427205f6dd4d6d883063b741bc551f6ec))
* **CI:** run the tests in MacOS ([7bb2422](https://github.com/meysam81/ansible-collections/commit/7bb24220732e196cbdd7a926f17c0f6ea49ff0a9))
* **CI:** specify full path to promtail binary ([bfc1273](https://github.com/meysam81/ansible-collections/commit/bfc1273294a58cca978c6268b29fd8e317ec5941))
* **CI:** specify more robust conditional on j2 template ([e9e6c8d](https://github.com/meysam81/ansible-collections/commit/e9e6c8df8fab1b3d92ff85ea96000967f9ffdc38))
* **CI:** use ansible builtin functions to extact the path ([1b712ce](https://github.com/meysam81/ansible-collections/commit/1b712ce689f33a5f510e19341da712dda143e022))
* **docs:** modify plaintext format ([aa492c9](https://github.com/meysam81/ansible-collections/commit/aa492c9b6dbca88e1b1b0704a6e83c14ae975487))
* modify detected arch for ARM64 ([1d2832b](https://github.com/meysam81/ansible-collections/commit/1d2832b429ec7b72f0b516bc82094d0ea52d6091))
* remove v from galaxy version ([ffba8e8](https://github.com/meysam81/ansible-collections/commit/ffba8e85bb826c7ebec039b3dc869ee15f70c52f))
* use the release please output tag name in galaxy version ([b8da863](https://github.com/meysam81/ansible-collections/commit/b8da86397577b9e9bc0119e8b8d024ca4cf5d5e0))
* **vmagent:** make remote write url mandatory ([0808435](https://github.com/meysam81/ansible-collections/commit/080843550c5a7cbd0ab2c3dece8db2429766e7a2))
* **vmagent:** make VM protocol optional ([bea423a](https://github.com/meysam81/ansible-collections/commit/bea423a5035f6ac8b9034e0500f58b9e7f4f36e2))
* **vmagent:** modify target password file path ([91e7025](https://github.com/meysam81/ansible-collections/commit/91e70255aba73ba9463794eb8ca3a7d1cd1688a0))
* **vmagent:** modify template indentations ([492a61b](https://github.com/meysam81/ansible-collections/commit/492a61bbffa7608aa4fa0fcb97252d51ccd757a4))
* **vmagent:** provide undefined var ([7742be0](https://github.com/meysam81/ansible-collections/commit/7742be04cc1474d8f70ec4bb88e2220e7d29d5d3))
* **vmagent:** verify the correctness before release ([a9b5984](https://github.com/meysam81/ansible-collections/commit/a9b5984cc28613f61260e47490a869c390a55762))


### Miscellaneous Chores

* release v1.5.4, again ([8d6e903](https://github.com/meysam81/ansible-collections/commit/8d6e903e956ab90bb5f9f8e633ff8a405ad6fb6a))

## [1.5.4](https://github.com/meysam81/ansible-collections/compare/v1.5.3...v1.5.4) (2024-11-02)


### Bug Fixes

* use the release please output tag name in galaxy version ([b8da863](https://github.com/meysam81/ansible-collections/commit/b8da86397577b9e9bc0119e8b8d024ca4cf5d5e0))
