package main

import (
	"net/http"
	"time"
)

func Slowdown(w http.ResponseWriter, size int, delay time.Duration) http.ResponseWriter {
	return &slow{
		ResponseWriter: w,
		chunksize:      size,
		delay:          delay,
	}
}

type slow struct {
	http.ResponseWriter
	chunksize int
	delay     time.Duration
}

func (s *slow) Write(p []byte) (int, error) {
	pos := 0
	plen := len(p)
	for {
		if rem := plen - pos; s.chunksize >= rem {
			n, err := s.ResponseWriter.Write(p[pos : pos+rem])
			return pos + n, err
		}

		n, err := s.ResponseWriter.Write(p[pos : pos+s.chunksize])
		pos += n
		if err != nil {
			return pos, err
		}

		if f, ok := s.ResponseWriter.(http.Flusher); ok {
			f.Flush()
		}

		time.Sleep(s.delay)
	}
}
