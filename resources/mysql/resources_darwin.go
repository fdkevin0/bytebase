//go:build mysql
// +build mysql

package mysql

import "embed"

// 63aa98fa02e84d2d0520af0fabb0435a is the md5 hash.
//go:generate ./fetch_mysql.sh mysql-8.0.31-macos12-arm64.tar.gz 63aa98fa02e84d2d0520af0fabb0435a

// To use this package in testing, download the MySQL binary first:
// go generate -tags mysql ./...
//
//go:embed mysql-8.0.31-macos12-arm64.tar.gz
var resources embed.FS
