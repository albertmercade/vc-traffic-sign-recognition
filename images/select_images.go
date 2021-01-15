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

const percent = 0.8

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

	for f := 0; f <= 42; f++ {
		dir := filepath.Join("All", format(f))

		files, _ := ioutil.ReadDir(dir)
		numFiles := len(files)

		keep := int(float64(numFiles) * percent)

		l := rand.Perm(numFiles)

		train := l[:keep]
		test := l[keep:]

		createLinks("Train", f, train)
		createLinks("Test", f, test)

		if _, err := w.WriteString(fmt.Sprintln(f, train, test)); err != nil {
			panic(err)
		}
	}
}

func createLinks(folder string, img int, files []int) {
	for _, f := range files {
		shared := filepath.Join(format(img), format(f))
		ss := fmt.Sprintf("%s/%s_%s", format(img), format(img), format(f))
		target := filepath.Join("..", "..", "All", shared)
		filename := filepath.Join(folder, ss)

		err := os.MkdirAll(filepath.Dir(filename), 0700)
		if err != nil {
			panic(err)
		}

		err = os.Symlink(target, filename)
		if err != nil {
			panic(err)
		}
	}
}
