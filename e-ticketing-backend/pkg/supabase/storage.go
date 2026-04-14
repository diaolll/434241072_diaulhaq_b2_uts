package supabase

import (
    "fmt"
    "io"
    "net/http"
    "bytes"
    "io/ioutil"
    "e-ticketing-backend/internal/config"
)

type StorageClient struct {
    URL    string
    Key    string
    Bucket string
}

func NewStorageClient() *StorageClient {
    return &StorageClient{
        URL:    config.AppConfig.SupabaseURL,
        Key:    config.AppConfig.SupabaseKey,
        Bucket: config.AppConfig.SupabaseBucket,
    }
}

func (s *StorageClient) Upload(path string, file io.Reader, contentType string) (string, error) {
    data, err := ioutil.ReadAll(file)
    if err != nil {
        return "", err
    }

    url := fmt.Sprintf("%s/storage/v1/object/%s/%s", s.URL, s.Bucket, path)
    req, _ := http.NewRequest("POST", url, bytes.NewReader(data))
    req.Header.Set("Authorization", "Bearer "+s.Key)
    req.Header.Set("Content-Type", contentType)

    client := &http.Client{}
    resp, err := client.Do(req)
    if err != nil {
        return "", err
    }
    defer resp.Body.Close()

    if resp.StatusCode != http.StatusOK && resp.StatusCode != http.StatusCreated {
        return "", fmt.Errorf("upload failed with status: %d", resp.StatusCode)
    }

    publicURL := fmt.Sprintf("%s/storage/v1/object/public/%s/%s", s.URL, s.Bucket, path)
    return publicURL, nil
}