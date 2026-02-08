# 1. Terraform Backend - State dosyasını GCP'de tutar
terraform {
  backend "gcs" {
    bucket  = "camelyne-internal" # Bu bucket'ı manuel veya gsutil ile önceden oluşturmalısın
    prefix  = "terraform/state/landing-page"
  }
}

# 2. Provider Tanımı
provider "google" {
  project = "camelyne" # Buraya kendi proje ID'ni yazmalısın
  region  = "us-central1"
}

# 3. Statik Web Sitesi Bucket'ı
resource "google_storage_bucket" "static_site" {
  name          = "camelyne-landing-page" # Global olarak eşsiz bir isim seçmelisin
  location      = "US"
  force_destroy = true # Bucket dolu olsa bile terraform destroy ile silinebilir

  # Web sitesi konfigürasyonu
  website {
    main_page_suffix = "index.html"
    not_found_page   = "404.html"
  }

  # CORS ayarları (gerekli durumlarda API istekleri için)
  cors {
    origin          = ["*"]
    method          = ["GET", "HEAD"]
    response_header = ["*"]
    max_age_seconds = 3600
  }
}

# 4. Dosyaları Tüm Dünyaya Aç (Public Access)
resource "google_storage_bucket_iam_member" "public_rule" {
  bucket = google_storage_bucket.static_site.name
  role   = "roles/storage.objectViewer"
  member = "allUsers"
}

# 5. Output - Sitenin adresini terminale yazdırır
output "website_url" {
  value = "https://storage.googleapis.com/${google_storage_bucket.static_site.name}/index.html"
  description = "Camelyne Landing Page URL"
}
