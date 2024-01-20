package main

import (
	"encoding/csv"
	"encoding/json"
	"flag"
	"fmt"
	"io/ioutil"
	"log"
	"math"
	"math/rand"
	"net/http"
	"os"
	"os/exec"
	"reflect"
	"strings"
	"sync"
	"time"
)

const retriesLimit = 5
const initalConcurrentRequest = 50 // There is a X-Ratelimit-Limit of 61

var isDebug = false
var pageSize = 100
var outputDir string

func main() {
	var progressBar progressBar

	urls := getUrls()
	ch := make(chan entries, len(urls))
	progressBar.InitBar(0, len(urls))

	o := flag.String("o", "", "Absolute path of the output directory")
	flag.Parse()
	outputDir = string(*o)
	_, err := os.Stat(outputDir)
	if err != nil {
		log.Fatalf("The path `%s` is not valid\n", outputDir)
	}

	go progressBar.start(func() int {
		return len(ch)
	})

	wg := sync.WaitGroup{}
	for i, url := range urls {
		wg.Add(1)
		go start(url, ch, &wg)

		if i >= initalConcurrentRequest-1 {
			time.Sleep(1 * time.Second)
		}
	}

	var entries []entry

	wg.Wait()
	close(ch)

	for c := range ch {
		for _, e := range c {
			entries = append(entries, e)
		}
	}

	fmt.Println()
	writeToDisk(entries)
}

func fetchURL(url string) (*http.Response, error) {
	client := &http.Client{}
	req, _ := http.NewRequest("GET", url, nil)

	for retries, backoff := 0, rand.Intn(10)+1; ; {
		resp, err := client.Do(req)
		if err != nil {
			return resp, err
		}

		switch responseCode := resp.StatusCode; responseCode {
		case http.StatusOK:
			return resp, nil
		case http.StatusTooManyRequests:
		case http.StatusInternalServerError:
			if retries > retriesLimit {
				fmt.Println()
				log.Fatalf("Retry limit exceeded: \n%v", resp)
			}
		default:
			fmt.Println()
			log.Fatalf("Unexpected http status code received: \n%v", resp)
		}

		time.Sleep(time.Duration(backoff) * time.Second)
		retries++
		backoff++
	}
}

func start(url string, ch chan<- entries, wg *sync.WaitGroup) {
	defer wg.Done()

	resp, err := fetchURL(url)
	body, err := ioutil.ReadAll(resp.Body)
	if err != nil {
		log.Fatal(err)
	}
	var entries entries
	err = json.Unmarshal([]byte(body), &entries)
	if err != nil {
		log.Fatal(err)
	}

	ch <- entries
}

func getModuleCount() int {
	resp, _ := fetchURL("https://registry.terraform.io/v2/modules?&page[size]=1")

	body, err := ioutil.ReadAll(resp.Body)
	if err != nil {
		log.Fatal(err)
	}

	tmp := struct {
		Meta struct {
			Pagination struct {
				TotalCount int `json:"total-count"`
			} `json:"pagination"`
		} `json:"meta"`
	}{}
	json.Unmarshal(body, &tmp)
	return tmp.Meta.Pagination.TotalCount
}

func getModuleTotalPage() int {
	if isDebug == true {
		return 1
	}
	return int(math.Ceil(float64(getModuleCount()) / float64(pageSize)))
}

func getUrls() []string {
	var res []string
	if isDebug {
		pageSize = 5
	}
	N := getModuleTotalPage()
	for i := 1; i < N+1; i++ {
		res = append(res, fmt.Sprintf("https://registry.terraform.io/v2/modules?page[size]=%d&page[number]=%d&include=latest-version", pageSize, i))
	}
	return res
}

func writeToDisk(entries entries) {
	outputFileAbsPath := outputDir + "/modules.csv"
	csvFile, err := os.Create(outputFileAbsPath)
	if err != nil {
		log.Fatal(err)
	}
	defer csvFile.Close()
	writer := csv.NewWriter(csvFile)
	for _, entry := range entries {
		writer.Write(entry.Values())
	}
	writer.Flush()

	command := fmt.Sprintf("sort -o %s %s", outputFileAbsPath, outputFileAbsPath)
	_, err = exec.Command("bash", "-c", command).Output()
	if err != nil {
		log.Fatal(err)
	}

	log.Printf("File written to %s", string(outputFileAbsPath))
}

type entries []entry
type entry struct {
	Name         string
	Namespace    string
	ID           string
	ProviderName string
	Source       string
	// NOTE: Description may contain `,`
	Description string
}

func (entry entry) Values() []string {
	e := reflect.ValueOf(&entry).Elem()
	numField := e.NumField()

	res := make([]string, numField)
	for i := 0; i < numField; i++ {
		res[i] = fmt.Sprint(e.Field(i).Interface())
	}
	return res
}

func (e *entries) UnmarshalJSON(data []byte) error {

	tmp := struct {
		Data []struct {
			ID         string `json:"id"`
			Attributes struct {
				FullName     string `json:"full-name"`
				Name         string `json:"name"`
				Namespace    string `json:"namespace"`
				ProviderName string `json:"provider-name"`
				Source       string `json:"source"`
			} `json:"attributes"`
			Relationships struct {
				LatestVersion struct {
					Data struct {
						ID string `json:"id"`
					} `json:"data"`
				} `json:"latest-version"`
			} `json:"relationships"`
		} `json:"data"`
		Included []struct {
			ID         string `json:"id"`
			Attributes struct {
				Description string `json:"description"`
			} `json:"attributes"`
		} `json:"included"`
	}{}

	if err := json.Unmarshal(data, &tmp); err != nil {
		return err
	}

	moduleVersions := make(map[string]string)
	for _, moduleVersion := range tmp.Included {
		moduleVersions[moduleVersion.ID] = moduleVersion.Attributes.Description
	}

	for _, d := range tmp.Data {
		*e = append(*e, entry{
			Name:         d.Attributes.Name,
			Namespace:    d.Attributes.Namespace,
			ProviderName: d.Attributes.ProviderName,
			Description:  moduleVersions[d.Relationships.LatestVersion.Data.ID],
			Source:       d.Attributes.Source,
			ID:           d.ID,
		})
	}

	return nil
}

// //////////////////////////////////////////////////////////////////////////////
// Progress Bar
// //////////////////////////////////////////////////////////////////////////////
type progressBar struct {
	cur         int    // current progress
	percent     int    // current progress
	total       int    // total value for progress
	graph       string // the fill value for progress bar
	refreshRate time.Duration
}

func (bar *progressBar) setCur(cur int) {
	// Enforces that the progress should always be increasing
	if cur < bar.cur {
		return
	}
	bar.cur = cur
	bar.percent = bar.getPercent()
}

func (bar *progressBar) InitBar(cur int, total int) {
	bar.cur = cur
	bar.total = total
	bar.percent = bar.getPercent()
	bar.graph = "#"
	bar.refreshRate = 200 * time.Millisecond
}

func (bar *progressBar) getPercent() int {
	return int((float32(bar.cur) / float32(bar.total)) * 100)
}

func (bar *progressBar) progressBar() string {
	return strings.Repeat("#", bar.percent/2)
}

func (bar *progressBar) print(elapsed time.Duration) {
	fmt.Printf("\r[%-50s] %3d%%  %8d/%d [%ds]", bar.progressBar(), bar.percent, bar.cur, bar.total, int(elapsed.Seconds()))
}

type fn func() int

func (bar *progressBar) start(f fn) {
	start := time.Now()
	for bar.cur < bar.total {
		bar.setCur(f())
		time.Sleep(bar.refreshRate)
		bar.print(time.Since(start))
	}
	bar.print(time.Since(start))
}
