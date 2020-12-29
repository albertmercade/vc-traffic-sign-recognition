package main

import (
	"bufio"
	"fmt"
	"io/ioutil"
	"math/rand"
	"os"
	"path/filepath"
)

func format(d int) string {
	return fmt.Sprintf("%05d", d)
}

func main() {

	os.RemoveAll("Train")
	os.RemoveAll("Test")

	f, err := os.Create("train_test_split")
	if err != nil {
		panic(err)
	}

	defer f.Close()

	w := bufio.NewWriter(f)
	defer w.Flush()

	for f := 0; f <= 42; f += 1 {
		dir := filepath.Join("All", format(f))

		files, _ := ioutil.ReadDir(dir)
		numFiles := len(files)

		keep := int(float64(numFiles) * 0.8)

		l := rand.Perm(numFiles)

		train := l[:keep]
		test := l[keep:]

		create_links("Train", f, train)
		create_links("Test", f, test)

		w.WriteString(fmt.Sprintln(f, train, test))

	}
}

func create_links(folder string, img int, files []int) {
	for _, f := range files {
		shared := filepath.Join(format(img), format(f))
		target := filepath.Join("..", "..", "All", shared)
		filename := filepath.Join(folder, shared)
		os.MkdirAll(filepath.Dir(filename), 0700)
		os.Symlink(target, filename)
	}
}
