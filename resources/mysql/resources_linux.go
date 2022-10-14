//go:build mysql
// +build mysql

package mysql

import "embed"

// 8f763c0d32f19d385d84eca9f90a642a is the md5 hash.
//go:generate ./fetch_mysql.sh mysql-8.0.31-linux-glibc2.17-x86_64-minimal.tar.xz 8f763c0d32f19d385d84eca9f90a642a

// To use this package in testing, download the MySQL binary first:
// go generate -tags mysql ./...
//
//go:embed mysql-8.0.31-linux-glibc2.17-x86_64-minimal.tar.xz
var resources embed.FS
