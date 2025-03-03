package main

import (
	"fmt"
	"io/fs"
	"path/filepath"
	"strings"
)

func main() {
	filepath.Walk("../../client/assets", func(path string, info fs.FileInfo, err error) error {
		if err != nil {
			return err
		}
		if info.IsDir() {
			return nil
		}
		dir := filepath.Dir(path)
		if !strings.Contains(dir, "animal") && !strings.Contains(dir, "food") && !strings.Contains(dir, "plant") {
			return nil
		}
		fmt.Println(path)
		return nil
	})
}
